import 'package:flutter/material.dart';
import '../models/dog.dart';

class DogCard extends StatelessWidget {
  final Dog dog;
  
  final VoidCallback? onConfirmAdoption;

 
  const DogCard({
    Key? key,
    required this.dog,
    this.onConfirmAdoption, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              child: Image.network(
                dog.photoUrl,
                fit: BoxFit.cover,
                
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
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
          
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dog.name,
                        style: TextStyle(
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
                  
                  Text(
                    '${dog.breed}, ${dog.sex}, ${dog.size}, ${dog.color}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  
                  Text(
                    dog.description,
                    style: TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                 
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

                  
                  if (onConfirmAdoption != null) ...[
                    Spacer(), 
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onConfirmAdoption,
                        icon: Icon(Icons.check_circle_outline),
                        label: Text('Confirmar Adoção'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
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
      label: Text(text, style: TextStyle(fontSize: 10)),
      backgroundColor: color.withOpacity(0.1),
      labelPadding: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.zero,
    );
  }
}