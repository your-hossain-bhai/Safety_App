import 'dart:convert';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class PlacesService {
  final _baseNearby =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  final _baseDetails =
      'https://maps.googleapis.com/maps/api/place/details/json';

  Future<String?> findNearestPolicePhone({
    required double lat,
    required double lon,
  }) async {
    final nearbyUrl = Uri.parse(
      '$_baseNearby?location=$lat,$lon&radius=3000&type=police&keyword=police%20station&key=${Secrets.googleApiKey}',
    );
    final r = await http.get(nearbyUrl);
    if (r.statusCode != 200) return null;
    final data = jsonDecode(r.body) as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? [];
    if (results.isEmpty) return null;

    final placeId = results.first['place_id'];
    if (placeId == null) return null;

    final detailsUrl = Uri.parse(
      '$_baseDetails?place_id=$placeId&fields=name,formatted_phone_number,international_phone_number&key=${Secrets.googleApiKey}',
    );
    final d = await http.get(detailsUrl);
    if (d.statusCode != 200) return null;
    final det = jsonDecode(d.body) as Map<String, dynamic>;
    final result = det['result'] as Map<String, dynamic>?;
    return result?['formatted_phone_number'] ??
        result?['international_phone_number'];
  }
}
