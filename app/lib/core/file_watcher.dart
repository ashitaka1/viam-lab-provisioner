import 'dart:async';
import 'dart:io';

class DebouncedFileWatcher {
  DebouncedFileWatcher(
    this._entity, {
    this.duration = const Duration(milliseconds: 200),
  });

  final FileSystemEntity _entity;
  final Duration duration;

  StreamSubscription<FileSystemEvent>? _subscription;
  Timer? _debounceTimer;
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream {
    _subscription ??= _entity
        .watch(events: FileSystemEvent.all, recursive: false)
        .listen((_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(duration, () => _controller.add(null));
    });
    return _controller.stream;
  }

  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _controller.close();
  }
}
