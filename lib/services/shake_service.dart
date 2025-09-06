import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  final double threshold; 
  final int debounceMs;

  StreamSubscription<AccelerometerEvent>? _sub;
  int _lastMs = 0;

  final _shakeController = StreamController<void>.broadcast();
  Stream<void> get tripleShakeStream => _shakeController.stream;

  ShakeService({this.threshold = 18.0, this.debounceMs = 800});

  void start() {
    _sub?.cancel();
    _sub = accelerometerEventStream().listen((e) {
      final gForce = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (gForce >= threshold) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now - _lastMs > debounceMs) {
          _lastMs = now;
          _shakeController.add(null); // void event
        }
      }
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    stop();
    _shakeController.close();
  }
}
