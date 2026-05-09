import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/core/constants/api_constants.dart';
import 'package:medicare_app/domain/entities/product_entity.dart';

void main() async {
  final url = Uri.parse('${ApiConstants.products}?page=2&limit=20');
  final response = await http.get(url, headers: {'Accept': 'application/json'});
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final productsData = data['data']['products'] as List;
    for (var i = 0; i < productsData.length; i++) {
      try {
        ProductEntity.fromJson(productsData[i]);
      } catch (e) {
        print('Error parsing product $i: $e');
        return;
      }
    }
    print('All page 2 products parsed successfully!');
  } else {
    print('Error: ${response.body}');
  }
}
