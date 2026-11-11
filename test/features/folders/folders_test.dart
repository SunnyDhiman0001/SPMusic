import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spmusic/core/utils/library_change_notifier.dart';
import 'package:spmusic/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:spmusic/features/folders/data/services/folder_filter.dart';
import 'package:spmusic/features/music/data/datasources/local_music_data_source.dart';
import 'package:spmusic/features/music/data/models/album_model.dart';
import 'package:spmusic/features/music/data/models/artist_model.dart';
import 'package:spmusic/features/music/data/models/playlist_model.dart';
import 'package:spmusic/features/music/data/models/song_model.dart';
import 'package:spmusic/features/music/data/repositories/music_repository_impl.dart';
import 'package:spmusic/features/music/data/services/local_storage_service.dart';

SongModel song(String id, String folder, {String? title, int size = 1000, int seconds = 200}) => SongModel(
      id: id,
      title: title ?? 'Song $id',
      artist: 'Artist',
      artistId: 'a',
      album: 'Album',
      albumId: 'al',
      artworkId: 1,
      audioUrl: 'content://media/$id',
      duration: Duration(seconds: seconds),
      folderPath: folder,
      fileSize: size,
    );

class FakeDataSource implements LocalMusicDataSource {
  FakeDataSource(this.songs);

  List<SongModel> songs;
  int invalidations = 0;

  @override
  Future<List<SongModel>> getSongs() async => songs;
  @override
  Future<List<ArtistModel>> getArtists() async => const [];
  @override
  Future<List<AlbumModel>> getAlbums() async => const [];
  @override
  Future<List<PlaylistModel>> getPlaylists() async => const [];
  @override
  void invalidateCache() => invalidations++;
}

class FakeStorage implements LocalStorageService {
  Set<String> favorites = {};

  @override
  Future<Set<String>> getFavoriteIds() async => {...favorites};
  @override
  Future<void> setFavoriteIds(Set<String> ids) async => favorites = ids;
  @override
  Future<List<String>> getRecentlyPlayedIds() async => [];
  @override
  Future<void> recordPlayed(String songId) async {}
}

const music = '/storage/emulated/0/Music';
const downloads = '/storage/emulated/0/Download';
// Deliberately not a path the app knows about: detection is by name, not path.
const whatsapp = '/storage/1234-ABCD/Android/media/com.whatsapp/WhatsApp/Media/WhatsApp Voice Notes/202446';
const whatsappAudio = '/storage/emulated/0/Documents/WhatsApp Audio';

Future<({FolderFilter filter, FakeDataSource source, FolderRepositoryImpl folders, MusicRepositoryImpl library, LibraryChangeNotifier changes})>
    setup(List<SongModel> songs) async {
  SharedPreferences.setMockInitialValues({});
  final filter = FolderFilter(await SharedPreferences.getInstance());
  final source = FakeDataSource(songs);
  final changes = LibraryChangeNotifier();
  return (
    filter: filter,
    source: source,
    folders: FolderRepositoryImpl(source, filter, changes),
    library: MusicRepositoryImpl(source, FakeStorage(), folderFilter: filter),
    changes: changes,
  );
}

void main() {
  test('messaging/voice folders are recognised by name, anywhere on the device', () {
    expect(FolderFilter.looksLikeNonMusic(whatsapp), isTrue);
    expect(FolderFilter.looksLikeNonMusic(whatsappAudio), isTrue);
    expect(FolderFilter.looksLikeNonMusic('/storage/emulated/0/Telegram/Telegram Audio'), isTrue);
    expect(FolderFilter.looksLikeNonMusic('/storage/emulated/0/Recordings/Voice Recorder'), isTrue);
    expect(FolderFilter.looksLikeNonMusic(music), isFalse);
    expect(FolderFilter.looksLikeNonMusic(downloads), isFalse);
  });

  test('folders group songs by real location with counts, A-Z', () async {
    final t = await setup([song('1', downloads), song('2', music), song('3', music), song('4', whatsapp)]);
    final folders = await t.folders.getFolders();
    expect(folders.map((f) => f.name), ['202446', 'Download', 'Music']);
    expect(folders.firstWhere((f) => f.path == music).songCount, 2);
    expect(folders.firstWhere((f) => f.path == music).displayPath, 'Music');
  });

  test('voice-message folders are hidden from the library by default, not from the folder list', () async {
    final t = await setup([song('1', music), song('2', whatsapp), song('3', whatsappAudio)]);
    final library = await t.library.getAllSongs();
    expect(library.map((s) => s.id), ['1']);

    final folders = await t.folders.getFolders();
    expect(folders.where((f) => f.isExcluded).map((f) => f.path), containsAll([whatsapp, whatsappAudio]));
    expect(folders.firstWhere((f) => f.path == music).isExcluded, isFalse);
    // Still browsable so the user can decide.
    expect((await t.folders.getSongsInFolder(whatsapp)).map((s) => s.id), ['2']);
  });

  test('user can hide a folder and show a defaulted-hidden one; choices persist and notify', () async {
    final t = await setup([song('1', music), song('2', downloads), song('3', whatsapp)]);
    var notified = 0;
    t.changes.changes.listen((_) => notified++);

    await t.folders.setFolderExcluded(downloads, excluded: true);
    await t.folders.setFolderExcluded(whatsapp, excluded: false);
    await Future<void>.delayed(Duration.zero);

    expect((await t.library.getAllSongs()).map((s) => s.id), unorderedEquals(['1', '3']));
    expect(notified, 2);

    // A second filter over the same prefs (app restart) sees the same choices.
    final restarted = FolderFilter(await SharedPreferences.getInstance());
    expect(restarted.excludedAmong([music, downloads, whatsapp]), {downloads});
  });

  test('same file listed twice by MediaStore-level duplicates and copies appear once in All Songs', () async {
    final t = await setup([
      song('1', music, title: 'Track', size: 5000, seconds: 180),
      song('2', downloads, title: 'Track', size: 5000, seconds: 180), // copy in another folder
      song('3', music, title: 'Other', size: 5000, seconds: 180),
    ]);
    expect((await t.library.getAllSongs()).map((s) => s.id), ['1', '3']);
    // Both copies still exist for folder browsing and id lookups (favourites).
    expect((await t.folders.getSongsInFolder(downloads)).map((s) => s.id), ['2']);
    expect((await t.library.getSongsByIds(['2'])).single.id, '2');
  });

  test('refresh re-scans so added and deleted files show up', () async {
    final t = await setup([song('1', music)]);
    expect((await t.folders.getFolders()).single.songCount, 1);

    t.source.songs = [song('1', music), song('2', music), song('3', downloads)];
    await t.folders.refresh();

    expect(t.source.invalidations, 1);
    final folders = await t.folders.getFolders();
    expect(folders.firstWhere((f) => f.path == music).songCount, 2);
    expect(folders.length, 2);

    t.source.songs = [song('3', downloads)];
    await t.folders.refresh();
    expect((await t.folders.getFolders()).map((f) => f.path), [downloads]);
  });

  test('a folder with no audio left reports no songs', () async {
    final t = await setup([song('1', music)]);
    expect(await t.folders.getSongsInFolder('/storage/emulated/0/Empty'), isEmpty);
  });
}
