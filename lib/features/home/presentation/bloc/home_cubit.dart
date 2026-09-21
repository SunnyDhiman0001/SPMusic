import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/card_display_item.dart';
import '../../../music/domain/entities/artist_entity.dart';
import '../../../music/domain/entities/playlist_entity.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../../music/domain/repositories/music_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeInitial());

  final MusicRepository _repository;

  Future<void> loadHome() async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _repository.getRecentlyPlayed(),
        _repository.getMadeForYouPlaylists(),
        _repository.getTrendingSongs(),
        _repository.getPopularArtists(),
      ]);

      emit(HomeLoaded(
        recentlyPlayed: (results[0] as List<SongEntity>).map(_songToCard).toList(),
        madeForYou: (results[1] as List<PlaylistEntity>).map(_playlistToCard).toList(),
        trending: (results[2] as List<SongEntity>).map(_songToCard).toList(),
        popularArtists: (results[3] as List<ArtistEntity>).map(_artistToCard).toList(),
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> refresh() => loadHome();

  CardDisplayItem _songToCard(SongEntity song) => CardDisplayItem(
        id: song.id,
        imageUrl: song.artworkUrl,
        title: song.title,
        subtitle: song.artist,
      );

  CardDisplayItem _playlistToCard(PlaylistEntity playlist) => CardDisplayItem(
        id: playlist.id,
        imageUrl: playlist.coverUrl,
        title: playlist.name,
        subtitle: playlist.description,
      );

  CardDisplayItem _artistToCard(ArtistEntity artist) => CardDisplayItem(
        id: artist.id,
        imageUrl: artist.imageUrl,
        title: artist.name,
        subtitle: 'Artist',
      );
}
