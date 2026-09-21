import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _favoritesKey = 'favorite_song_ids';
const _recentlyPlayedKey = 'recently_played_song_ids';
const _maxRecentlyPlayed = 30;

abstract class LocalStorageService {
  Future<Set<String>> getFavoriteIds();
  Future<void> setFavoriteIds(Set<String> ids);
  Future<List<String>> getRecentlyPlayedIds();
  Future<void> recordPlayed(String songId);
}

class LocalStorageServiceImpl implements LocalStorageService {
  LocalStorageServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<Set<String>> getFavoriteIds() async {
    final raw = _prefs.getString(_favoritesKey);
    if (raw == null) return {};
    return (jsonDecode(raw) as List<dynamic>).cast<String>().toSet();
  }

  @override
  Future<void> setFavoriteIds(Set<String> ids) async {
    await _prefs.setString(_favoritesKey, jsonEncode(ids.toList()));
  }

  @override
  Future<List<String>> getRecentlyPlayedIds() async {
    final raw = _prefs.getString(_recentlyPlayedKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).cast<String>();
  }

  @override
  Future<void> recordPlayed(String songId) async {
    final current = await getRecentlyPlayedIds();
    final updated = [songId, ...current.where((id) => id != songId)]
        .take(_maxRecentlyPlayed)
        .toList();
    await _prefs.setString(_recentlyPlayedKey, jsonEncode(updated));
  }
}
