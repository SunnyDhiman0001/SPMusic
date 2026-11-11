import 'dart:async';

/// Broadcasts "the visible music library changed" (e.g. a folder was hidden
/// or shown) so screens that already loaded songs can reload.
class LibraryChangeNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  void notifyChanged() => _controller.add(null);
}
