// lib/widgets/dog_card.dart

import 'package:flutter/material.dart';
import '../models/dog.dart';

class DogCard extends StatelessWidget {
  final Dog dog;
  final VoidCallback? onConfirmAdoption;
  final VoidCallback? onEdit; // O botão de editar que já adicionamos

  const DogCard({
    Key? key,
    required this.dog,
    this.onConfirmAdoption,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      
      // --- VOLTAMOS À LÓGICA ORIGINAL DO 'Expanded' ---
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. A IMAGEM (com flex: 6)
          Expanded(
            flex: 6, // Dá 60% da altura para a imagem
            child: Container(
              width: double.infinity,
              child: Image.network(
                dog.photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.broken_image,
                        color: Colors.grey[400], size: 60),
                  );
                },
              ),
            ),
          ),
          
          // 2. O TEXTO (com flex: 4)
          Expanded(
            flex: 4, // Dá 40% da altura para o texto e botões
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Empurra o conteúdo
                children: [
                  
                  // Bloco de Título e Idade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dog.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${dog.age} ${dog.age == 1 ? "ano" : "anos"}',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  
                  // Bloco de tags
                  Text(
                    '${dog.breed}, ${dog.sex}, ${dog.size}, ${dog.color}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Bloco de descrição
                  Text(
                    dog.description,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Bloco de chips de saúde
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoTag(dog.vaccinationStatus,
                          Icons.vaccines, Colors.blue),
                      _buildInfoTag(
                          dog.isCastrated ? 'Castrado' : 'Não Castrado',
                          Icons.pets,
                          Colors.orange),
                      _buildInfoTag(dog.healthStatus,
                          Icons.health_and_safety, Colors.green),
                    ],
                  ),

                  // --- NOSSOS BOTÕES ---
                  // (Sem 'Spacer', pois o mainAxisAlignment já faz o trabalho)
                  if (onConfirmAdoption != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onConfirmAdoption,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Confirmar Adoção'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],

                  if (onEdit != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar Anúncio'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                          side: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 10)),
      backgroundColor: color.withOpacity(0.1),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
    );
  }
}