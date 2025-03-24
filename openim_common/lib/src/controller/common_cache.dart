import 'dart:async';

/// Represents a single cache entry storing the value and its last access timestamp.
class CacheEntry<V> {
  final V value;
  final DateTime lastAccessed;

  CacheEntry(this.value) : lastAccessed = DateTime.now();
}

/// Type alias for a batch asynchronous loader function.
/// Takes a list of keys and returns a map of keys to loaded values.
typedef BatchAsyncLoader<K, V> = Future<Map<K, V>> Function(List<K> keys);

/// Type alias for a logging function to hook into cache events.
typedef CacheLogger<K> = void Function(String event, List<K> keys);

/// A generic, asynchronous, LRU (Least Recently Used) cache system that:
/// - Supports batch asynchronous data loading.
/// - Automatically caches results with TTL expiration.
/// - Allows setting specific keys as non-expiring.
/// - Evicts least-recently-used entries when exceeding capacity.
/// - Prevents duplicate loads via internal request locking.
class BatchLruAsyncCache<K, V> {
  final int capacity;
  final Duration ttl;
  final BatchAsyncLoader<K, V> loader;
  final CacheLogger<K>? logger;

  final _cache = <K, CacheEntry<V>>{};
  final _locks = <K, Completer<V>>{};
  final _noExpireKeys = <K>{};

  BatchLruAsyncCache({
    required this.capacity,
    required this.ttl,
    required this.loader,
    this.logger,
  });

  /// Retrieves values for the provided keys.
  /// Cached values are returned directly if not expired.
  /// Missing values are fetched using the async loader and then cached.
  Future<Map<K, V>> getMany(List<K> keys) async {
    final now = DateTime.now();
    final hits = <K, V>{};
    final misses = <K>[];

    // Step 1: Separate hits and misses
    for (final key in keys) {
      final entry = _cache[key];
      if (entry != null && !_isExpired(key, entry)) {
        hits[key] = entry.value;
        _cache[key] = CacheEntry(entry.value); // Refresh access time
      } else {
        misses.add(key);
      }
    }

    if (hits.isNotEmpty) {
      logger?.call("cache_hit", hits.keys.toList());
    }

    if (misses.isEmpty) return hits;

    logger?.call("cache_miss", misses);

    final results = <K, V>{};
    final toLoad = <K>[];
    final waitFutures = <Future<void>>[];

    // Step 2: Handle concurrent loads
    for (final key in misses) {
      if (_locks.containsKey(key)) {
        waitFutures.add(_locks[key]!.future.then((v) => results[key] = v));
      } else {
        final completer = Completer<V>();
        _locks[key] = completer;
        toLoad.add(key);
      }
    }

    // Step 3: Load missing keys
    if (toLoad.isNotEmpty) {
      try {
        final loadedMap = await loader(toLoad);
        logger?.call("cache_loaded", loadedMap.keys.toList());

        for (final entry in loadedMap.entries) {
          _cache[entry.key] = CacheEntry(entry.value);
          _locks[entry.key]?.complete(entry.value);
          results[entry.key] = entry.value;
        }

        for (final key in toLoad) {
          if (!loadedMap.containsKey(key)) {
            final err = Exception("Loader didn't return value for key: $key");
            _locks[key]?.completeError(err);
            logger?.call("cache_error", [key]);
          }
        }

        _ensureCapacity();
      } finally {
        for (final key in toLoad) {
          _locks.remove(key);
        }
      }
    }

    // Step 4: Wait for concurrent loads to complete
    await Future.wait(waitFutures);

    return {...hits, ...results};
  }

  /// Marks a specific key as non-expiring.
  /// This entry will not be affected by TTL expiration.
  void setNoExpireForKey(K key) {
    _noExpireKeys.add(key);
  }

  /// Removes the non-expiring status for a key.
  /// This key will now be subject to normal TTL checks.
  void removeNoExpireForKey(K key) {
    _noExpireKeys.remove(key);
  }

  /// Checks if the given key is set to never expire.
  bool isNoExpireKey(K key) {
    return _noExpireKeys.contains(key);
  }

  /// Explicitly removes a cached value for the given key.
  void remove(K key) {
    logger?.call("cache_remove", [key]);
    _cache.remove(key);
    _noExpireKeys.remove(key);
  }

  /// Clears all cache entries and resets expiration settings.
  void clear() {
    logger?.call("cache_clear", _cache.keys.toList());
    _cache.clear();
    _noExpireKeys.clear();
  }

  /// Determines if the cache entry for a key is expired.
  bool _isExpired(K key, CacheEntry entry) {
    if (_noExpireKeys.contains(key)) return false;
    if (ttl == Duration.zero || ttl.inDays > 1000) return false;
    return DateTime.now().difference(entry.lastAccessed) >= ttl;
  }

  /// Ensures the cache stays within the specified capacity.
  /// Evicts the least-recently-used items if necessary.
  void _ensureCapacity() {
    while (_cache.length > capacity) {
      final oldestKey = _cache.keys.first;
      if (!_noExpireKeys.contains(oldestKey)) {
        _cache.remove(oldestKey);
        logger?.call("cache_evict", [oldestKey]);
      } else {
        // Move non-expiring keys to the end of the list to avoid eviction repeatedly
        final entry = _cache.remove(oldestKey);
        if (entry != null) {
          _cache[oldestKey] = entry;
        }
      }
    }
  }
}
