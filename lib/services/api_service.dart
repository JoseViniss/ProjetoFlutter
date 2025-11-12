import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/breed_model.dart';

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

  final String _apiKey = "live_qAtT6ilnolAXHIBvvVlXqmGvo3tWjVNQXl9eS3hZPADkCZdRz59OJToBlHpBDfoO";

  final String _baseUrl = "https://api.thedogapi.com/v1";

  Future<List<Breed>> getBreeds() async {
    final url = Uri.parse('$_baseUrl/breeds');
    
    try {
      final response = await http.get(
        url,
        headers: {'x-api-key': _apiKey}, // Autenticação
      );

      if (response.statusCode == 200) {
        // Converte a resposta (uma lista de JSON) em uma Lista de Objetos Breed
        final List<dynamic> jsonData = json.decode(response.body);
        
        // Adiciona "SRD (Vira-lata)" manualmente, pois a API não tem
        List<Breed> breeds = [Breed(id: "srd", name: "SRD (Vira-lata)")]; 
        
        breeds.addAll(jsonData.map((item) => Breed.fromMap(item)).toList());
        return breeds;
        
      } else {
        // Se a API falhar, retorna uma lista com "SRD" pelo menos
        print('Falha ao carregar raças: ${response.statusCode}');
        return [Breed(id: "srd", name: "SRD (Vira-lata)")];
      }
    } catch (e) {
      // Se a internet falhar, retorna uma lista com "SRD" pelo menos
      print('Erro de rede ao carregar raças: $e');
      return [Breed(id: "srd", name: "SRD (Vira-lata)")];
    }
  }
}
