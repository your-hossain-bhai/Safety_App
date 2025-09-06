import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/danger_zone_service.dart';
import '../services/shake_service.dart';
import '../services/emergency_service.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});
  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final _location = LocationService();
  final _danger = DangerZoneService();
  final _shake = ShakeService();
  final _emergency = EmergencyService();

  static const LatLng _fallbackCenter =
      LatLng(23.7808875, 90.2792371); // Dhaka as default

  GoogleMapController? _mapController;
  LatLng? _me;
  bool _inDanger = false;
  bool _serviceOn = true;
  bool _permOk = true;
  String? _status;
  StreamSubscription? _posSub;
  StreamSubscription<bool>? _shakeSub;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Check service + permissions first
    final serviceOn = await _location.isServiceEnabled();
    final permOk = await _location.ensurePermissions();

    setState(() {
      _serviceOn = serviceOn;
      _permOk = permOk;
      _status = (!serviceOn)
          ? 'Location service is OFF'
          : (!permOk ? 'Location permission needed' : null);
    });

    // Try to get a fix (with fallback)
    final pos = await _location.getCurrentPosition();
    if (pos != null) {
      setState(() => _me = LatLng(pos.latitude, pos.longitude));
      _checkDanger(_me!);
    }

    // Start live updates
    _posSub = _location.positionStream().listen((p) {
      final here = LatLng(p.latitude, p.longitude);
      setState(() => _me = here);
      _checkDanger(here);
      _mapController?.animateCamera(CameraUpdate.newLatLng(here));
    });

    // Triple-shake listener
    _shakeSub = _shake.tripleShakeStream.listen((triggered) async {
      if (!triggered || _me == null) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Triple shake detected! Finding police…')),
      );
      await _emergency.callNearestPoliceOrFallback(_me!);
    });
  }

  void _checkDanger(LatLng p) {
    final zone = _danger.getDangerAt(p.latitude, p.longitude);
    setState(() => _inDanger = zone != null);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _shakeSub?.cancel();
    _shake.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _openSettingsAndRetry() async {
    // Open device location settings and return to app, then retry boot
    await _location.openLocationSettings();
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _me = null;
      _status = 'Retrying…';
    });
    await _boot();
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = CameraPosition(
      target: _me ?? _fallbackCenter,
      zoom: _me != null ? 16 : 12,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Safety')),
      body: Stack(
        children: [
          // Add logo at the top center
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/logo.jpg',
                height: 80,
              ),
            ),
          ),
          // Show the map even if we don't have a fix yet
          GoogleMap(
            initialCameraPosition: initialCamera,
            myLocationEnabled: _permOk, // only if permission ok
            myLocationButtonEnabled: true,
            onMapCreated: (c) => _mapController = c,
            circles: _danger.circlesForMap(),
            markers: {
              if (_me != null)
                Marker(markerId: const MarkerId('me'), position: _me!),
            },
          ),

          // Status card when service is off or permission missing
          if (!_serviceOn || !_permOk)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.amber.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        _status ?? 'Location unavailable',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _openSettingsAndRetry,
                            child: const Text('Enable location'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _boot,
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_inDanger)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.red,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Danger zone nearby! Stay alert.',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Manual call button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: _me == null
                  ? null
                  : () async {
                      await _emergency.callNearestPoliceOrFallback(_me!);
                    },
              icon: const Icon(Icons.local_police),
              label: const Text('Call nearest police (manual)'),
            ),
          ),
        ],
      ),
    );
  }
}
