import 'dart:io';
import 'dart:typed_data';

import 'package:on_audio_query_forked/on_audio_query.dart';

/// Extracts a song's embedded cover into a cache file so the media
/// notification / lock-screen player can show it (it needs a Uri, not a widget).
class NotificationArtwork {
  NotificationArtwork._();

  static final OnAudioQuery _query = OnAudioQuery();

  /// Returns a `file://` Uri for the song's artwork, or null if it has none.
  ///
  /// The native artwork query handles one request at a time, so rapid song
  /// changes used to stack up extractions (each reading embedded art out of a
  /// possibly large file). Requests now run one after another, and one whose
  /// [isCurrent] has gone false by the time its turn comes is skipped.
  static Future<Uri?> forSong(int artworkId, {bool Function()? isCurrent}) {
    final result = _tail.then((_) => (isCurrent?.call() ?? true) ? _extract(artworkId) : null);
    _tail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  static Future<void> _tail = Future<void>.value();

  static Future<Uri?> _extract(int artworkId) async {
    try {
      final file = File('${Directory.systemTemp.path}/art_$artworkId.jpg');
      if (await file.exists() && await file.length() > 0) {
        return file.uri;
      }
      final Uint8List? bytes = await _query.queryArtwork(
        artworkId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 512,
        quality: 90,
      );
      if (bytes == null || bytes.isEmpty) return null;
      await file.writeAsBytes(bytes, flush: true);
      return file.uri;
    } catch (_) {
      return null;
    }
  }
}
