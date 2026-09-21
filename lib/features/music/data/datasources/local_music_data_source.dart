import '../models/album_model.dart';
import '../models/artist_model.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';

abstract class LocalMusicDataSource {
  List<SongModel> getSongs();
  List<ArtistModel> getArtists();
  List<AlbumModel> getAlbums();
  List<PlaylistModel> getPlaylists();
}

class LocalMusicDataSourceImpl implements LocalMusicDataSource {
  static const _artists = [
    ArtistModel(id: 'ar1', name: 'Nova Wave', imageUrl: 'https://picsum.photos/seed/artist1/400'),
    ArtistModel(id: 'ar2', name: 'Aria Storm', imageUrl: 'https://picsum.photos/seed/artist2/400'),
    ArtistModel(id: 'ar3', name: 'The Drift', imageUrl: 'https://picsum.photos/seed/artist3/400'),
    ArtistModel(id: 'ar4', name: 'Solstice', imageUrl: 'https://picsum.photos/seed/artist4/400'),
  ];

  static const _albums = [
    AlbumModel(
      id: 'al1',
      title: 'Neon Horizon',
      artistId: 'ar1',
      artistName: 'Nova Wave',
      coverUrl: 'https://picsum.photos/seed/album1/400',
      songIds: ['s1', 's2', 's3', 's4'],
    ),
    AlbumModel(
      id: 'al2',
      title: 'Golden Static',
      artistId: 'ar2',
      artistName: 'Aria Storm',
      coverUrl: 'https://picsum.photos/seed/album2/400',
      songIds: ['s5', 's6', 's7'],
    ),
    AlbumModel(
      id: 'al3',
      title: 'Tidal Echoes',
      artistId: 'ar3',
      artistName: 'The Drift',
      coverUrl: 'https://picsum.photos/seed/album3/400',
      songIds: ['s8', 's9', 's10', 's11'],
    ),
    AlbumModel(
      id: 'al4',
      title: 'Equinox',
      artistId: 'ar4',
      artistName: 'Solstice',
      coverUrl: 'https://picsum.photos/seed/album4/400',
      songIds: ['s12', 's13', 's14'],
    ),
  ];

  static const _songs = [
    SongModel(
      id: 's1',
      title: 'Midnight Drive',
      artist: 'Nova Wave',
      artistId: 'ar1',
      album: 'Neon Horizon',
      albumId: 'al1',
      artworkUrl: 'https://picsum.photos/seed/album1/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      duration: Duration(minutes: 3, seconds: 24),
    ),
    SongModel(
      id: 's2',
      title: 'Electric Skyline',
      artist: 'Nova Wave',
      artistId: 'ar1',
      album: 'Neon Horizon',
      albumId: 'al1',
      artworkUrl: 'https://picsum.photos/seed/album1/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      duration: Duration(minutes: 4, seconds: 2),
    ),
    SongModel(
      id: 's3',
      title: 'Chrome Rain',
      artist: 'Nova Wave',
      artistId: 'ar1',
      album: 'Neon Horizon',
      albumId: 'al1',
      artworkUrl: 'https://picsum.photos/seed/album1/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      duration: Duration(minutes: 2, seconds: 58),
    ),
    SongModel(
      id: 's4',
      title: 'City Lights',
      artist: 'Nova Wave',
      artistId: 'ar1',
      album: 'Neon Horizon',
      albumId: 'al1',
      artworkUrl: 'https://picsum.photos/seed/album1/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      duration: Duration(minutes: 3, seconds: 47),
    ),
    SongModel(
      id: 's5',
      title: 'Golden Hour',
      artist: 'Aria Storm',
      artistId: 'ar2',
      album: 'Golden Static',
      albumId: 'al2',
      artworkUrl: 'https://picsum.photos/seed/album2/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
      duration: Duration(minutes: 4, seconds: 30),
    ),
    SongModel(
      id: 's6',
      title: 'Paper Planes',
      artist: 'Aria Storm',
      artistId: 'ar2',
      album: 'Golden Static',
      albumId: 'al2',
      artworkUrl: 'https://picsum.photos/seed/album2/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
      duration: Duration(minutes: 3, seconds: 12),
    ),
    SongModel(
      id: 's7',
      title: 'Static Bloom',
      artist: 'Aria Storm',
      artistId: 'ar2',
      album: 'Golden Static',
      albumId: 'al2',
      artworkUrl: 'https://picsum.photos/seed/album2/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      duration: Duration(minutes: 2, seconds: 50),
    ),
    SongModel(
      id: 's8',
      title: 'Afterglow',
      artist: 'The Drift',
      artistId: 'ar3',
      album: 'Tidal Echoes',
      albumId: 'al3',
      artworkUrl: 'https://picsum.photos/seed/album3/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      duration: Duration(minutes: 3, seconds: 39),
    ),
    SongModel(
      id: 's9',
      title: 'Undertow',
      artist: 'The Drift',
      artistId: 'ar3',
      album: 'Tidal Echoes',
      albumId: 'al3',
      artworkUrl: 'https://picsum.photos/seed/album3/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3',
      duration: Duration(minutes: 4, seconds: 15),
    ),
    SongModel(
      id: 's10',
      title: 'Salt Air',
      artist: 'The Drift',
      artistId: 'ar3',
      album: 'Tidal Echoes',
      albumId: 'al3',
      artworkUrl: 'https://picsum.photos/seed/album3/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      duration: Duration(minutes: 3, seconds: 5),
    ),
    SongModel(
      id: 's11',
      title: 'Low Tide',
      artist: 'The Drift',
      artistId: 'ar3',
      album: 'Tidal Echoes',
      albumId: 'al3',
      artworkUrl: 'https://picsum.photos/seed/album3/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3',
      duration: Duration(minutes: 2, seconds: 55),
    ),
    SongModel(
      id: 's12',
      title: 'Solstice Fire',
      artist: 'Solstice',
      artistId: 'ar4',
      album: 'Equinox',
      albumId: 'al4',
      artworkUrl: 'https://picsum.photos/seed/album4/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-12.mp3',
      duration: Duration(minutes: 3, seconds: 58),
    ),
    SongModel(
      id: 's13',
      title: 'Winter Bloom',
      artist: 'Solstice',
      artistId: 'ar4',
      album: 'Equinox',
      albumId: 'al4',
      artworkUrl: 'https://picsum.photos/seed/album4/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-13.mp3',
      duration: Duration(minutes: 4, seconds: 22),
    ),
    SongModel(
      id: 's14',
      title: 'Equinox Sky',
      artist: 'Solstice',
      artistId: 'ar4',
      album: 'Equinox',
      albumId: 'al4',
      artworkUrl: 'https://picsum.photos/seed/album4/400',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-14.mp3',
      duration: Duration(minutes: 3, seconds: 30),
    ),
  ];

  static const _playlists = [
    PlaylistModel(
      id: 'p1',
      name: 'Focus Flow',
      description: 'Steady beats to help you concentrate.',
      coverUrl: 'https://picsum.photos/seed/playlist1/400',
      songIds: ['s1', 's3', 's5', 's8', 's12'],
      creator: 'spmusic',
    ),
    PlaylistModel(
      id: 'p2',
      name: 'Late Night Chill',
      description: 'Mellow tracks for winding down after dark.',
      coverUrl: 'https://picsum.photos/seed/playlist2/400',
      songIds: ['s6', 's7', 's9', 's11'],
      creator: 'spmusic',
    ),
    PlaylistModel(
      id: 'p3',
      name: 'Weekend Anthems',
      description: 'High-energy songs to soundtrack your weekend.',
      coverUrl: 'https://picsum.photos/seed/playlist3/400',
      songIds: ['s2', 's4', 's10', 's13', 's14'],
      creator: 'spmusic',
    ),
    PlaylistModel(
      id: 'p4',
      name: 'Throwback Mix',
      description: 'A nostalgic blend from across every album.',
      coverUrl: 'https://picsum.photos/seed/playlist4/400',
      songIds: ['s1', 's5', 's8', 's12', 's14', 's6'],
      creator: 'spmusic',
    ),
  ];

  @override
  List<SongModel> getSongs() => _songs;

  @override
  List<ArtistModel> getArtists() => _artists;

  @override
  List<AlbumModel> getAlbums() => _albums;

  @override
  List<PlaylistModel> getPlaylists() => _playlists;
}
