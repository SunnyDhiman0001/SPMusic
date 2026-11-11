import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../music/data/services/music_permission_service.dart';
import '../../../music/domain/repositories/music_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._permissionService, {Stream<void>? libraryChanges})
      : super(const HomeInitial()) {
    // A folder was hidden/shown elsewhere: reload without a loading flash.
    _changesSubscription = libraryChanges?.listen((_) {
      if (state is HomeLoaded) unawaited(_loadSongs());
    });
  }

  final MusicRepository _repository;
  final MusicPermissionService _permissionService;
  StreamSubscription<void>? _changesSubscription;

  @override
  Future<void> close() async {
    await _changesSubscription?.cancel();
    return super.close();
  }

  Future<void> loadHome() async {
    emit(const HomeLoading());

    final status = await _permissionService.check();
    if (status != MusicPermissionStatus.granted) {
      emit(HomePermissionDenied(permanentlyDenied: status == MusicPermissionStatus.permanentlyDenied));
      return;
    }

    await _loadSongs();
  }

  Future<void> requestPermission() async {
    final status = await _permissionService.request();
    if (status == MusicPermissionStatus.granted) {
      await _repository.refresh();
      await _loadSongs();
    } else {
      emit(HomePermissionDenied(permanentlyDenied: status == MusicPermissionStatus.permanentlyDenied));
    }
  }

  Future<void> openPermissionSettings() => _permissionService.openSettings();

  Future<void> refresh() => loadHome();

  Future<void> _loadSongs() async {
    try {
      final songs = await _repository.getAllSongs();
      emit(HomeLoaded(songs: songs, isEmpty: songs.isEmpty));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
