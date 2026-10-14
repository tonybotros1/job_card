import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'models/web_job_card.dart';

/// Plain HTTPS access to Firestore.
///
/// The SDK's live channel can be slow to deliver its first answer in some
/// browsers, while ordinary HTTPS requests to the same database are fast.
/// The lists read their first page and their search data through here.
class FirestoreRest {
  FirestoreRest._();

  /// Fields search needs (see [WebJobCard.matches]) plus what a result row
  /// shows before the full card is loaded. Leaving out the photo links makes
  /// the download about 8 times smaller.
  static const searchFields = [
    'customer_name',
    'car_brand',
    'car_model',
    'plate_number',
    'date',
    'color',
    'timestamp',
    'status',
  ];

  static String get _project => Firebase.app().options.projectId;

  static String get _base =>
      'https://firestore.googleapis.com/v1/projects/$_project/databases/(default)/documents';

  static Future<Map<String, String>> _headers() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw StateError('not signed in');
    return {'content-type': 'application/json', 'authorization': 'Bearer $token'};
  }

  static Map<String, dynamic> _listQuery(String userId, bool open) => {
        'from': [
          {'collectionId': 'car_card'}
        ],
        'where': {
          'compositeFilter': {
            'op': 'AND',
            'filters': [
              {
                'fieldFilter': {
                  'field': {'fieldPath': 'user_id'},
                  'op': 'EQUAL',
                  'value': {'stringValue': userId},
                }
              },
              {
                'fieldFilter': {
                  'field': {'fieldPath': 'status'},
                  'op': 'EQUAL',
                  'value': {'booleanValue': open},
                }
              },
            ],
          }
        },
        'orderBy': [
          {
            'field': {'fieldPath': 'timestamp'},
            'direction': 'DESCENDING',
          }
        ],
      };

  static Future<List<WebJobCard>> _runQuery(
    Map<String, dynamic> structuredQuery, {
    bool partial = false,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final res = await http
        .post(
          Uri.parse('$_base:runQuery'),
          headers: await _headers(),
          body: jsonEncode({'structuredQuery': structuredQuery}),
        )
        .timeout(timeout);
    if (res.statusCode != 200) throw StateError('HTTP ${res.statusCode}');
    final rows = jsonDecode(res.body);
    if (rows is! List) return const [];
    final out = <WebJobCard>[];
    for (final row in rows) {
      final doc = row is Map ? row['document'] : null;
      if (doc is Map) out.add(_card(doc, partial: partial));
    }
    return out;
  }

  static WebJobCard _card(Map doc, {bool partial = false}) {
    final name = doc['name'].toString();
    final id = name.substring(name.lastIndexOf('/') + 1);
    final fields = doc['fields'];
    return WebJobCard.fromMap(id, fields is Map ? decodeFields(fields) : const {},
        partial: partial);
  }

  /// First page of cards for [userId] with the given [open] status, newest
  /// first, same order as the SDK query the lists use.
  static Future<List<WebJobCard>> firstPage({
    required String userId,
    required bool open,
    required int limit,
  }) {
    return _runQuery({..._listQuery(userId, open), 'limit': limit});
  }

  /// Every card of the list with only [searchFields], newest first. The cards
  /// come back marked `partial`.
  static Future<List<WebJobCard>> searchIndex({
    required String userId,
    required bool open,
  }) {
    return _runQuery(
      {
        ..._listQuery(userId, open),
        'select': {
          'fields': [
            for (final f in searchFields) {'fieldPath': f}
          ],
        },
      },
      partial: true,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Full cards for [ids]; ids of deleted cards are left out of the result.
  static Future<Map<String, WebJobCard>> getCards(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final root = 'projects/$_project/databases/(default)/documents/car_card';
    final res = await http
        .post(
          Uri.parse('$_base:batchGet'),
          headers: await _headers(),
          body: jsonEncode({
            'documents': [for (final id in ids) '$root/$id'],
          }),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw StateError('HTTP ${res.statusCode}');
    final rows = jsonDecode(res.body);
    final out = <String, WebJobCard>{};
    if (rows is! List) return out;
    for (final row in rows) {
      final found = row is Map ? row['found'] : null;
      if (found is Map) {
        final card = _card(found);
        out[card.id] = card;
      }
    }
    return out;
  }

  /// Converts a REST `fields` map into the plain values the SDK would give.
  static Map<String, dynamic> decodeFields(Map fields) {
    final out = <String, dynamic>{};
    fields.forEach((k, v) => out[k.toString()] = _value(v));
    return out;
  }

  static dynamic _value(dynamic v) {
    if (v is! Map) return null;
    if (v.containsKey('stringValue')) return v['stringValue'];
    if (v.containsKey('booleanValue')) return v['booleanValue'];
    if (v.containsKey('integerValue')) return int.tryParse(v['integerValue'].toString());
    if (v.containsKey('doubleValue')) return (v['doubleValue'] as num).toDouble();
    if (v.containsKey('timestampValue')) {
      final d = DateTime.tryParse(v['timestampValue'].toString());
      return d == null ? null : Timestamp.fromDate(d);
    }
    if (v.containsKey('arrayValue')) {
      final values = (v['arrayValue'] as Map)['values'];
      return values is List ? values.map(_value).toList() : <dynamic>[];
    }
    if (v.containsKey('mapValue')) {
      final f = (v['mapValue'] as Map)['fields'];
      return f is Map ? decodeFields(f) : <String, dynamic>{};
    }
    return null; // nullValue, references, geo points: not used by cards
  }
}
