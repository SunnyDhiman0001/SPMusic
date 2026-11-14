import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spmusic/core/widgets/local_artwork.dart';
import 'package:spmusic/core/widgets/now_playing_bars.dart';
import 'package:spmusic/features/music/domain/entities/song_entity.dart';
import 'package:spmusic/features/search/presentation/widgets/search_song_tile.dart';

const _song = SongEntity(
  id: '1',
  title: 'Chasing Sunsets',
  artist: 'Unknown Artist',
  artistId: 'a',
  album: 'Album',
  albumId: 'al',
  artworkId: 1,
  audioUrl: 'content://media/1',
  duration: Duration(seconds: 20),
);

Widget _host({required bool isCurrent, required bool isPlaying}) => MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        body: SearchSongTile(
          song: _song,
          onTap: () {},
          isCurrent: isCurrent,
          isPlaying: isPlaying,
        ),
      ),
    );

void main() {
  testWidgets('not current: real artwork, no bars', (tester) async {
    await tester.pumpWidget(_host(isCurrent: false, isPlaying: false));
    expect(find.byType(LocalArtwork), findsOneWidget);
    expect(find.byType(NowPlayingBars), findsNothing);
  });

  testWidgets('current but paused: real artwork, no bars', (tester) async {
    await tester.pumpWidget(_host(isCurrent: true, isPlaying: false));
    expect(find.byType(LocalArtwork), findsOneWidget);
    expect(find.byType(NowPlayingBars), findsNothing);
  });

  testWidgets('current and playing: artwork is kept and bars overlay it', (tester) async {
    await tester.pumpWidget(_host(isCurrent: true, isPlaying: true));
    expect(find.byType(LocalArtwork), findsOneWidget);
    expect(find.byType(NowPlayingBars), findsOneWidget);
    expect(find.text('Chasing Sunsets'), findsOneWidget);
  });
}
