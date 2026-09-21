import 'package:equatable/equatable.dart';
import '../../../../core/widgets/card_display_item.dart';

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

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.recentlyPlayed,
    required this.madeForYou,
    required this.trending,
    required this.popularArtists,
  });

  final List<CardDisplayItem> recentlyPlayed;
  final List<CardDisplayItem> madeForYou;
  final List<CardDisplayItem> trending;
  final List<CardDisplayItem> popularArtists;

  @override
  List<Object?> get props => [recentlyPlayed, madeForYou, trending, popularArtists];
}

class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
