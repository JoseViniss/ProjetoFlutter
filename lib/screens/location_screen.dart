import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String locationMessage = "Pressione o botão para ver onde você está";
  String? addressMessage;
  bool isLoading = false;

  
  Future<void> _getAddressFromApi(double lat, double long) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$long&zoom=18&addressdetails=1');

      // O OpenStreetMap pede um User-Agent para não bloquear
      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.pet_center/1.0 (aluno@faculdade.com.br)'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

       
        final address = data['address'];
        final road = address['road'] ?? 'Rua desconhecida';
        final suburb = address['suburb'] ?? address['neighbourhood'] ?? '';
        final city =
            address['city'] ?? address['town'] ?? address['municipality'] ?? '';
        final state = address['state'] ?? '';

        setState(() {
          addressMessage = "$road, $suburb\n$city - $state";
        });
      }
    } catch (e) {
      setState(() {
        addressMessage = "Não foi possível buscar o endereço na API.";
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoading = true;
      locationMessage = "Buscando GPS...";
      addressMessage = null; 
    });

    bool serviceEnabled;
    LocationPermission permission;

    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "GPS desligado. Ligue-o para continuar.";
        isLoading = false;
      });
      return;
    }

    
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Sem permissão de GPS.";
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage = "Permissão negada permanentemente.";
        isLoading = false;
      });
      return;
    }

    try {
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      setState(() {
        locationMessage =
            "Lat: ${position.latitude}\nLong: ${position.longitude}";
        
        locationMessage += "\n\nConsultando API de Mapa...";
      });

     
      await _getAddressFromApi(position.latitude, position.longitude);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        locationMessage = "Sinal de GPS fraco.\nTente ir perto de uma janela.";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Geolocalização + API')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              Icon(
                Icons.map_outlined,
                size: 100,
                color: isLoading ? Colors.grey : primaryColor,
              ),
              const SizedBox(height: 30),

              const Text("Sua Localização",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),

              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: isLoading
                    ? Column(
                        children: [
                          CircularProgressIndicator(color: primaryColor),
                          const SizedBox(height: 10),
                          Text(locationMessage, textAlign: TextAlign.center),
                        ],
                      )
                    : Column(
                        children: [
                          
                          Text(locationMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12)),

                          const Divider(height: 20),

                          
                          if (addressMessage != null)
                            Column(
                              children: [
                                const Text("Você está em:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text(
                                  addressMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          else if (!locationMessage.contains("Pressione"))
                            const Text("Endereço não encontrado na API."),
                        ],
                      ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : _getCurrentLocation,
                  icon: const Icon(Icons.satellite_alt),
                  label: const Text(
                    "Localizar Agora",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
