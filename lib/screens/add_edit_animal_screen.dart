// screens/add_edit_animal_screen.dart

import 'package:flutter/material.dart';
import 'package:projetoflutter/db/database_helper.dart';
import 'package:projetoflutter/models/animal_model.dart'; 

class AddEditAnimalScreen extends StatefulWidget {
  final Animal? animal; // Animal é opcional (se for nulo, é cadastro)

  const AddEditAnimalScreen({super.key, this.animal});

  @override
  _AddEditAnimalScreenState createState() => _AddEditAnimalScreenState();
}

class _AddEditAnimalScreenState extends State<AddEditAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controladores para os campos de texto
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    // Preenche os campos se estivermos editando um animal
    _nameController = TextEditingController(text: widget.animal?.name ?? '');
    _speciesController = TextEditingController(text: widget.animal?.species ?? '');
    _ageController = TextEditingController(text: widget.animal?.age.toString() ?? '');
  }

  @override
  void dispose() {
    // Limpa os controladores
    _nameController.dispose();
    _speciesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // Função para Salvar ou Atualizar
  Future<void> _saveAnimal() async {
    if (_formKey.currentState!.validate()) {
      final isUpdating = widget.animal != null;

      final animal = Animal(
        id: widget.animal?.id,
        name: _nameController.text,
        species: _speciesController.text,
        age: int.tryParse(_ageController.text) ?? 0,
      );

      if (isUpdating) {
        await DatabaseHelper.instance.update(animal);
      } else {
        await DatabaseHelper.instance.create(animal);
      }
      
      Navigator.pop(context); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animal == null ? 'Cadastrar Animal' : 'Editar Animal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira um nome' : null,
              ),
              const SizedBox(height: 16),
              // Campo Espécie
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(labelText: 'Espécie (Cão, Gato...)'),
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira a espécie' : null,
              ),
              const SizedBox(height: 16),
              // Campo Idade
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira a idade' : null,
              ),
              const SizedBox(height: 32),
              // Botão Salvar
              ElevatedButton(
                onPressed: _saveAnimal,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}