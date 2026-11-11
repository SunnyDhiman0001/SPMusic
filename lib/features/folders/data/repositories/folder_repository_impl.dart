import '../../../../core/utils/library_change_notifier.dart';
import '../../../music/data/datasources/local_music_data_source.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/repositories/folder_repository.dart';
import '../services/folder_filter.dart';

class FolderRepositoryImpl implements FolderRepository {
  FolderRepositoryImpl(this._dataSource, this._filter, this._changes);

  final LocalMusicDataSource _dataSource;
  final FolderFilter _filter;
  final LibraryChangeNotifier _changes;

  @override
  Future<List<FolderEntity>> getFolders() async {
    final songs = await _dataSource.getSongs();
    final counts = <String, int>{};
    for (final song in songs) {
      counts.update(song.folderPath, (n) => n + 1, ifAbsent: () => 1);
    }
    final excluded = _filter.excludedAmong(counts.keys);
    final folders = [
      for (final entry in counts.entries)
        FolderEntity(
          path: entry.key,
          songCount: entry.value,
          isExcluded: excluded.contains(entry.key),
          isSuggestedExclusion: FolderFilter.looksLikeNonMusic(entry.key),
        ),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return folders;
  }

  @override
  Future<List<SongEntity>> getSongsInFolder(String folderPath) async {
    final songs = await _dataSource.getSongs();
    return [for (final s in songs) if (s.folderPath == folderPath) s];
  }

  @override
  Future<void> setFolderExcluded(String folderPath, {required bool excluded}) async {
    final songs = await _dataSource.getSongs();
    final current = _filter.excludedAmong({for (final s in songs) s.folderPath}).toSet();
    if (excluded) {
      current.add(folderPath);
    } else {
      current.remove(folderPath);
    }
    await _filter.setExcluded(current);
    _changes.notifyChanged();
  }

  @override
  Future<void> refresh() async {
    _dataSource.invalidateCache();
    await _dataSource.getSongs();
    _changes.notifyChanged();
  }
}
