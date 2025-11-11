import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
 
  Future<String?> randomDogImage() async {
    try {
      final res = await http.get(Uri.parse('https://dog.ceo/api/breeds/image/random'));
      if (res.statusCode == 200) {
        final j = json.decode(res.body);
        return j['message'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  
  Future<Map<String,double>?> geocodeCity(String city) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(city)}&limit=1');
      final res = await http.get(url, headers: {'User-Agent': 'AdopetMatchApp/1.0'});
      if (res.statusCode == 200) {
        final list = json.decode(res.body) as List;
        if (list.isNotEmpty) {
          final first = list.first;
          return {
            'lat': double.parse(first['lat']),
            'lon': double.parse(first['lon']),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
