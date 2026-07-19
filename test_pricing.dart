import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    final response = await http.get(Uri.parse('https://parking-backend-prm.onrender.com/api/v1/vehicle-types'));
    if (response.statusCode == 200) {
      print('--- VEHICLE TYPES JSON ---');
      print(response.body);
    } else {
      print('Failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
