
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_me == null)
              ? const Center(child: Text('Location not available'))
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_me!.latitude, _me!.longitude),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (c) => _map = c,
              
                  circles: _danger.circlesForMap(_zones),
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: ElevatedButton.icon(
          onPressed: _callNearestPoliceManual,
          icon: const Icon(Icons.shield),
          label: const Text('Call nearest police (manual)'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
    );
  }
}
