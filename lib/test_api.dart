import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/core/constants/api_constants.dart';

void main() async {
  final url = Uri.parse('${ApiConstants.products}?page=2&limit=20');
  final response = await http.get(url, headers: {'Accept': 'application/json'});
  print('Status: ${response.statusCode}');
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final products = data['data']['products'] as List;
    final pagination = data['data']['pagination'];
    print('Products count: ${products.length}');
    print('Pagination: $pagination');
  } else {
    print('Error: ${response.body}');
  }
}
