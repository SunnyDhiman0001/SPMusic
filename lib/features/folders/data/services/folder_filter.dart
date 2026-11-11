import 'package:shared_preferences/shared_preferences.dart';

const _excludedFoldersKey = 'excluded_folder_paths';

/// Decides which folders are kept out of the music library.
///
/// Folder locations are read from MediaStore at scan time, never hardcoded.
/// Until the user changes anything, folders that look like messaging or voice
/// recordings (judged by their name, wherever they live on the device) are
/// hidden by default. After the first change the user's own choices are
/// stored and win.
class FolderFilter {
  FolderFilter(this._prefs);

  final SharedPreferences _prefs;

  static final _nameContains = RegExp(r'whatsapp|telegram|voice|messenger', caseSensitive: false);
  static final _nameIs = RegExp(r'^(ptt|signal)$', caseSensitive: false);

  /// True for folders that typically hold voice messages / forwarded audio.
  static bool looksLikeNonMusic(String folderPath) {
    for (final segment in folderPath.split('/')) {
      if (segment.isEmpty) continue;
      if (_nameContains.hasMatch(segment) || _nameIs.hasMatch(segment)) return true;
    }
    return false;
  }

  List<String>? get _stored => _prefs.getStringList(_excludedFoldersKey);

  /// Folder paths hidden from the library, given every folder currently known.
  Set<String> excludedAmong(Iterable<String> folderPaths) {
    final stored = _stored;
    if (stored != null) return stored.toSet();
    return {for (final p in folderPaths) if (looksLikeNonMusic(p)) p};
  }

  /// Persists the full exclusion set (including defaults the user hasn't
  /// touched) so later changes are never mixed with the name heuristic.
  Future<void> setExcluded(Set<String> paths) =>
      _prefs.setStringList(_excludedFoldersKey, paths.toList()..sort());
}
