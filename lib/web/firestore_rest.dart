import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import 'models/web_job_card.dart';

/// Plain HTTPS access to Firestore for the portal's first page.
///
/// The SDK's live channel occasionally never delivers its first snapshot in
/// a browser, while ordinary HTTPS requests to the same database work. This
/// reads the first page of a list through the REST API so the portal can show
/// cards whatever the live channel is doing.
class FirestoreRest {
  FirestoreRest._();

  static String get _base {
    final p = Firebase.app().options.projectId;
    return 'https://firestore.googleapis.com/v1/projects/$p/databases/(default)/documents';
  }

  /// First page of cards for [userId] with the given [open] status, newest
  /// first, same order as the SDK query the lists use.
  static Future<List<WebJobCard>> firstPage({
    required String userId,
    required bool open,
    required int limit,
  }) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw StateError('not signed in');
    final body = {
      'structuredQuery': {
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
        'limit': limit,
      }
    };
    final res = await http
        .post(
          Uri.parse('$_base:runQuery'),
          headers: {'content-type': 'application/json', 'authorization': 'Bearer $token'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw StateError('HTTP ${res.statusCode}');
    final rows = jsonDecode(res.body);
    if (rows is! List) return const [];
    final out = <WebJobCard>[];
    for (final row in rows) {
      final doc = row is Map ? row['document'] : null;
      if (doc is! Map) continue;
      final name = doc['name'].toString();
      final id = name.substring(name.lastIndexOf('/') + 1);
      final fields = doc['fields'];
      out.add(WebJobCard.fromMap(id, fields is Map ? decodeFields(fields) : const {}));
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
