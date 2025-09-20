// Placeholder for platform advertising. flutter_blue_plus does not expose
// peripheral advertising on all platforms. This provides a facade so we can
// later add platform channels without changing higher-level code.

class MeshAdvertiser {
  bool _running = false;
  Future<void> start() async {
    _running = true;
    // TODO: Implement platform channels for Android/iOS advertising.
  }

  Future<void> stop() async {
    _running = false;
  }

  bool get isRunning => _running;
}


