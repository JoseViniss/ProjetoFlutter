import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/dog.dart';
import '../widgets/dog_card.dart';


class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DBService db = DBService();
  
  List<Dog> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => isLoading = true);
    
    
    final favIds = await db.getFavoriteIds(); 
    final all = await db.getDogs();           
    
   
    final list = all.where((d) => d.id != null && favIds.contains(d.id!)).toList();
    
    setState(() {
      favorites = list;
      isLoading = false;
    });
  }

  Future<void> confirmAdoption(Dog dog) async {
    final nameController = TextEditingController();
    final res = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Confirmar adoção de ${dog.name}'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome do adotante'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancelar')),
            TextButton(onPressed: () => Navigator.pop(context, nameController.text), child: const Text('Confirmar')),
          ],
        );
      },
    );
    if (res != null && res.isNotEmpty) {
      if (dog.id == null) return; 
      await db.markAdopted(dog.id!, res); 
      await loadFavorites(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos & Adoções'),
        
        
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadFavorites,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Você ainda não favoritou nenhum cãozinho.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (_, idx) {
                    final dog = favorites[idx];
                    
                    return Dismissible(
                      key: Key(dog.id.toString()), // Chave única
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        if (dog.id == null) return; // Checagem
                        await db.removeFavorite(dog.id!);
                       
                        setState(() {
                          favorites.removeAt(idx);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${dog.name} removido dos favoritos.')),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        
                        child: SizedBox(
                          height: 350, 
                          child: DogCard(
                            dog: dog,
                            
                            onConfirmAdoption: () => confirmAdoption(dog), 
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}