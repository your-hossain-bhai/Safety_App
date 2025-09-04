import 'package:url_launcher/url_launcher.dart';
import 'places_service.dart';

class EmergencyService {
  final _places = PlacesService();

  Future<void> callNearestPoliceOrFallback(Object latLng) async {
    final double lat = (latLng as dynamic).latitude;
    final double lon = (latLng as dynamic).longitude;

    final phone = await _places.findNearestPolicePhone(lat: lat, lon: lon);
    final fallback = '999'; // তোমার দেশের ডিফল্টে বদলে দাও (৯৯৯/৯১১ ইত্যাদি)
    final toCall = (phone != null && phone.toString().trim().isNotEmpty)
        ? phone
        : fallback;

    final uri = Uri(scheme: 'tel', path: toCall);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      ); // dialer খুলবে
    }
  }
}
