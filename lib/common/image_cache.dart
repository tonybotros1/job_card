import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// One cache for every car photo, thumbnail and signature the apps show.
///
/// On the phone this is a disk cache: a picture downloaded once is reused for
/// [stalePeriod] (3 days) before it is fetched again. In the browser Flutter
/// has no disk cache, so there the browser's own cache applies, driven by the
/// `Cache-Control` header set on upload (see [cacheControlHeader]).
class JobCardImageCache {
  static const stalePeriod = Duration(days: 3);

  /// `Cache-Control` metadata written on every file the app uploads, so
  /// browsers keep it for the same 3 days.
  static const cacheControlHeader = 'public, max-age=259200';

  static final CacheManager instance = CacheManager(
    Config(
      'jobCardImages',
      stalePeriod: stalePeriod,
      maxNrOfCacheObjects: 5000,
    ),
  );
}
