// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:projetoflutter/db/database_helper.dart'; // Mude o nome do projeto aqui
import 'package:projetoflutter/models/animal_model.dart'; // Mude o nome do projeto aqui
import 'package:projetoflutter/screens/add_edit_animal_screen.dart'; // Mude o nome do projeto aqui

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Uma variável para guardar a lista de animais que vem do banco
  late Future<List<Animal>> _animalList;

  @override
  void initState() {
    super.initState();
    // Inicia o "refresh" da lista assim que a tela abre
    _refreshAnimalList();
  }

  // Função que busca os dados no banco
  Future<void> _refreshAnimalList() async {
    setState(() {
      _animalList = DatabaseHelper.instance.readAllAnimals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animais para Adoção'),
      ),
      // O FutureBuilder é o widget que espera os dados chegarem do banco
      body: FutureBuilder<List<Animal>>(
        future: _animalList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erro: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final animals = snapshot.data!;
            if (animals.isEmpty) {
              return const Center(child: Text("Nenhum animal cadastrado."));
            }
            
            // O ListView.builder constrói a lista
            return ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                return ListTile(
                  title: Text(animal.name),
                  subtitle: Text("${animal.species} - ${animal.age} anos"),
                  // Botão de Excluir
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await DatabaseHelper.instance.delete(animal.id!);
                      _refreshAnimalList(); // Atualiza a lista na tela
                    },
                  ),
                  // Botão de Editar
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditAnimalScreen(animal: animal),
                      ),
                    );
                    _refreshAnimalList(); // Atualiza a lista quando voltar
                  },
                );
              },
            );
          } else {
            return const Center(child: Text("Nenhum animal cadastrado."));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navega para a tela de cadastro (sem passar animal, pois é um novo)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditAnimalScreen()),
          );
          _refreshAnimalList(); // Atualiza a lista quando voltar
        },
      ),
    );
  }
}