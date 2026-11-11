import '../../../music/domain/entities/song_entity.dart';
import '../entities/folder_entity.dart';

abstract class FolderRepository {
  /// Every folder that holds audio, including hidden ones (flagged), A-Z.
  Future<List<FolderEntity>> getFolders();

  /// Audio files in one folder. Works for hidden folders too, so a folder
  /// can be inspected before deciding to show it.
  Future<List<SongEntity>> getSongsInFolder(String folderPath);

  Future<void> setFolderExcluded(String folderPath, {required bool excluded});

  /// Re-scans the device so added or deleted files show up.
  Future<void> refresh();
}
