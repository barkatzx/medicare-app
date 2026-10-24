import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../entity/location_entity.dart';

class LocationRepository {
  final http.Client client;

  LocationRepository({required this.client});

  Future<List<LocationEntity>> getDivisions() {
    return _fetch(ApiConstants.divisions);
  }

  Future<List<LocationEntity>> getDistricts(String divisionId) {
    return _fetch(ApiConstants.districts, {'divisionId': divisionId});
  }

  Future<List<LocationEntity>> getUpazilas(String districtId) {
    return _fetch(ApiConstants.upazilas, {'districtId': districtId});
  }

  Future<List<LocationEntity>> _fetch(
    String url, [
    Map<String, String>? query,
  ]) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    final response = await client
        .get(uri, headers: ApiConstants.getHeaders())
        .timeout(ApiConstants.connectionTimeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load locations');
    }

    final body = json.decode(response.body);
    final data = body['data'];
    if (data is! List) {
      throw Exception('Invalid locations response');
    }
    return data
        .map((e) => LocationEntity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
