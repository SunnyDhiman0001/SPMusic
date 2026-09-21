import 'package:equatable/equatable.dart';
import '../../../music/domain/entities/song_entity.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomePermissionDenied extends HomeState {
  const HomePermissionDenied({required this.permanentlyDenied});

  final bool permanentlyDenied;

  @override
  List<Object?> get props => [permanentlyDenied];
}

class HomeLoaded extends HomeState {
  const HomeLoaded({required this.songs, required this.isEmpty});

  final List<SongEntity> songs;
  final bool isEmpty;

  @override
  List<Object?> get props => [songs, isEmpty];
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
