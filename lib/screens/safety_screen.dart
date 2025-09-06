
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/shake_service.dart';
import '../services/danger_zone_service.dart';

class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  final ShakeService _shake = ShakeService(threshold: 18.0, debounceMs: 800);
  final DangerZoneService _danger = DangerZoneService();

  StreamSubscription<void>? _shakeSub;
  GoogleMapController? _map;
  Position? _me;

  final List<DangerZone> _zones = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initLocationAndData();
    _startShakeListener();
  }

  Future<void> _initLocationAndData() async {
    try {
      // ⛳ location permission নাও
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        final newPerm = await Geolocator.requestPermission();
        if (newPerm == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }
      if (await Geolocator.isLocationServiceEnabled() == false) {
        throw 'Location service is OFF';
      }

      
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _zones.clear();
      _zones.addAll(_danger.getZones()); 

      setState(() {
        _me = pos;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location error: $e')),
      );
    }
  }

  void _startShakeListener() {
    _shake.start();
    _shakeSub = _shake.tripleShakeStream.listen((_) async {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Triple shake detected! Finding police…'),
        ),
      );

      
      await _callNearestPoliceManual();
    });
  }

  Future<void> _callNearestPoliceManual() async {
    
    const tel = '999';
    final uri = Uri(scheme: 'tel', path: tel);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  }

  @override
  void dispose() {
    _shakeSub?.cancel();
    _shake.dispose();
    _map?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety')),
      body: Stack(
        children: [
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
        ),
      ),
    );
  }
}
