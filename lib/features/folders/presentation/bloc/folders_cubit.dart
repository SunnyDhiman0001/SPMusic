import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../music/data/services/music_permission_service.dart';
import '../../../music/domain/entities/song_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/repositories/folder_repository.dart';

sealed class FoldersState extends Equatable {
  const FoldersState();

  @override
  List<Object?> get props => [];
}

class FoldersLoading extends FoldersState {
  const FoldersLoading();
}

class FoldersPermissionDenied extends FoldersState {
  const FoldersPermissionDenied();
}

class FoldersLoaded extends FoldersState {
  const FoldersLoaded(this.folders);

  final List<FolderEntity> folders;

  @override
  List<Object?> get props => [folders];
}

class FoldersError extends FoldersState {
  const FoldersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class FoldersCubit extends Cubit<FoldersState> {
  FoldersCubit(this._repository, this._permissionService) : super(const FoldersLoading());

  final FolderRepository _repository;
  final MusicPermissionService _permissionService;

  Future<void> load() async {
    try {
      if (await _permissionService.check() != MusicPermissionStatus.granted) {
        emit(const FoldersPermissionDenied());
        return;
      }
      emit(FoldersLoaded(await _repository.getFolders()));
    } catch (e) {
      emit(FoldersError(e.toString()));
    }
  }

  /// Pull-to-refresh: re-scan so added and deleted files are picked up.
  Future<void> refresh() async {
    try {
      if (await _permissionService.check() != MusicPermissionStatus.granted) {
        emit(const FoldersPermissionDenied());
        return;
      }
      await _repository.refresh();
      emit(FoldersLoaded(await _repository.getFolders()));
    } catch (e) {
      emit(FoldersError(e.toString()));
    }
  }

  Future<void> setExcluded(FolderEntity folder, {required bool excluded}) async {
    await _repository.setFolderExcluded(folder.path, excluded: excluded);
    if (isClosed) return;
    emit(FoldersLoaded(await _repository.getFolders()));
  }
}

sealed class FolderSongsState extends Equatable {
  const FolderSongsState();

  @override
  List<Object?> get props => [];
}

class FolderSongsLoading extends FolderSongsState {
  const FolderSongsLoading();
}

class FolderSongsLoaded extends FolderSongsState {
  const FolderSongsLoaded(this.songs);

  final List<SongEntity> songs;

  @override
  List<Object?> get props => [songs];
}

class FolderSongsError extends FolderSongsState {
  const FolderSongsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class FolderSongsCubit extends Cubit<FolderSongsState> {
  FolderSongsCubit(this._repository) : super(const FolderSongsLoading());

  final FolderRepository _repository;

  Future<void> load(String folderPath, {bool rescan = false}) async {
    try {
      if (rescan) await _repository.refresh();
      emit(FolderSongsLoaded(await _repository.getSongsInFolder(folderPath)));
    } catch (e) {
      emit(FolderSongsError(e.toString()));
    }
  }
}
