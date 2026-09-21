import 'package:equatable/equatable.dart';

class SpotifyUserEntity extends Equatable {
  const SpotifyUserEntity({
    required this.id,
    required this.displayName,
    required this.email,
  });

  final String id;
  final String displayName;
  final String email;

  @override
  List<Object?> get props => [id, displayName, email];
}
