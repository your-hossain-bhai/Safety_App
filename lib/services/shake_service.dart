import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeService {
  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get tripleShakeStream => _controller.stream;

  static const double _shakeThresholdG = 2.2; // দরকার হলে টিউন করো
  static const int _windowMs = 1500; // 1.5s উইন্ডোতে 3 বার শেক

  int _count = 0;
  int _windowStart = DateTime.now().millisecondsSinceEpoch;
  StreamSubscription? _sub;

  ShakeService() {
    _sub = accelerometerEvents.listen(_onData);
  }

  void _onData(AccelerometerEvent e) {
    final gX = e.x / 9.80665, gY = e.y / 9.80665, gZ = e.z / 9.80665;
    final gForce = sqrt(gX * gX + gY * gY + gZ * gZ);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - _windowStart > _windowMs) {
      _windowStart = now;
      _count = 0;
    }

    if (gForce > _shakeThresholdG) {
      _count++;
      if (_count >= 3) {
        _controller.add(true);
        _count = 0;
        _windowStart = now;
      }
    }
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}
