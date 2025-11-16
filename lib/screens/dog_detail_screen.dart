// lib/screens/dog_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:pet_center/models/dog.dart';
import 'package:pet_center/models/user.dart';
import 'package:pet_center/services/db_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng; 

class DogDetailScreen extends StatefulWidget {
  final Dog dog;
  const DogDetailScreen({super.key, required this.dog});

  @override
  State<DogDetailScreen> createState() => _DogDetailScreenState();
}

class _DogDetailScreenState extends State<DogDetailScreen> {
  // Vamos usar um FutureBuilder para buscar o dono no banco
  late Future<User?> _ownerFuture;

  @override
  void initState() {
    super.initState();
    // Pega o DBService do Provider e inicia a busca pelo dono
    final db = Provider.of<DBService>(context, listen: false);
    _ownerFuture = db.getUserById(widget.dog.userId);
  }

  // --- FUNÇÃO PARA O BOTÃO DE CONTATO ---
  Future<void> _contactOwner(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Este usuário não cadastrou um telefone.')),
      );
      return;
    }

    // Remove a máscara (ex: "(11) 98888-7777" -> "11988887777")
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final uri =
        Uri.parse('https://wa.me/55$cleanPhone'); // Link direto para WhatsApp

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dog.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DADOS DO CÃO ---
            // Você pode usar seu DogCard aqui ou um layout customizado
            Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.dog.photoUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.dog.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${widget.dog.breed} - ${widget.dog.age} anos'),
                        const SizedBox(height: 8),
                        Text(widget.dog.description),
                        // ... Adicione mais tags de info (saúde, vacina, etc.)
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (widget.dog.latitude != null && widget.dog.longitude != null) ...[
              Text(
                'Localização Aproximada',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250, // Altura fixa para o mapa
                child: ClipRRect( // Para deixar com bordas arredondadas
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      // Usa as coordenadas salvas do cão
                      center: latLng.LatLng(widget.dog.latitude!, widget.dog.longitude!),
                      zoom: 15.0,
                    ),
                    children: [
                      // Camada do mapa (OpenStreetMap)
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      // O "pin" da localização
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: latLng.LatLng(widget.dog.latitude!, widget.dog.longitude!),
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // --- 2. DADOS DO DONO (COM FUTUREBUILDER) ---
            Text(
              'Informações do Doador',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            FutureBuilder<User?>(
              future: _ownerFuture,
              builder: (context, snapshot) {
                // Caso 1: Carregando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Caso 2: Erro ou Dono não encontrado
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data == null) {
                  return const Text(
                      'Não foi possível carregar as informações do doador.');
                }
                // Caso 3: Sucesso!
                final owner = snapshot.data!;

                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(owner.nome),
                          subtitle:
                              Text(owner.cidade ?? 'Cidade não informada'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Sobre o doador'),
                          subtitle: Text(owner.sobre ?? 'Nenhuma descrição.'),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.chat),
                            label: const Text('Entrar em Contato via WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => _contactOwner(owner.telefone),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
