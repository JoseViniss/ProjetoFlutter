import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import '../services/db_service.dart';
import '../models/dog.dart';

class RegisterDogScreen extends StatefulWidget {
  final Dog? dogToEdit;

  const RegisterDogScreen({Key? key, this.dogToEdit}) : super(key: key);

  @override
  _RegisterDogScreenState createState() => _RegisterDogScreenState();
}

class _RegisterDogScreenState extends State<RegisterDogScreen> {
  final DBService db = DBService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _healthStatusController = TextEditingController();
  final _cepController = TextEditingController(); 

  String? _selectedSex;
  String? _selectedSize;
  String? _selectedVaccination;
  bool _isCastrated = false;

  
  final List<String> _sexOptions = ['Macho', 'Fêmea'];
  final List<String> _sizeOptions = ['Pequeno', 'Médio', 'Grande'];
  final List<String> _vaccinationOptions = ['Vacinado', 'Pendente', 'Não vacinado'];

  @override
  void initState() {
    super.initState();
   
    if (widget.dogToEdit != null) {
      final d = widget.dogToEdit!;
      _nameController.text = d.name;
      _photoUrlController.text = d.photoUrl;

      _breedController.text = d.breed;
      _ageController.text = d.age.toString(); 
      _colorController.text = d.color;
      _descriptionController.text = d.description;
      _cityController.text = d.city;
      _healthStatusController.text = d.healthStatus;
      _selectedSex = d.sex;
      _selectedSize = d.size;
      _selectedVaccination = d.vaccinationStatus;
      _isCastrated = d.isCastrated;
    }
  }

  // --- API 2: VIACEP ---
  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CEP inválido')));
      return;
    }
    
    try {
      final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro')) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CEP não encontrado')));
        } else {
          setState(() {
           
            _cityController.text = data['localidade'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao buscar CEP')));
    }
  }

  Future<void> _saveDog() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newDog = Dog(
        id: widget.dogToEdit?.id, // Mantém o ID se for edição
        name: _nameController.text,
        photoUrl: _photoUrlController.text,
        breed: _breedController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        city: _cityController.text,
        description: _descriptionController.text,
        color: _colorController.text,
        healthStatus: _healthStatusController.text,
        sex: _selectedSex!,
        size: _selectedSize!,
        vaccinationStatus: _selectedVaccination!,
        isCastrated: _isCastrated,
      );

      if (widget.dogToEdit == null) {
        await db.insertDog(newDog); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${newDog.name} cadastrado!')));
      } else {
        await db.updateDog(newDog); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${newDog.name} atualizado!')));
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteDog() async {
    if (widget.dogToEdit != null && widget.dogToEdit!.id != null) {
      await db.deleteDog(widget.dogToEdit!.id!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cão excluído com sucesso!')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.dogToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cão' : 'Cadastrar Novo Cão'),
        actions: isEditing
            ? [IconButton(onPressed: _deleteDog, icon: const Icon(Icons.delete))]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('Informações Básicas'),
              _buildTextFormField(_nameController, 'Nome', validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              _buildTextFormField(_photoUrlController, 'URL da Foto', validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              
              // --- BUSCA DE CEP (API) ---
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(_cepController, 'CEP (Só números)', keyboardType: TextInputType.number),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _buscarCep,
                    tooltip: 'Buscar Cidade',
                  )
                ],
              ),
              
              _buildTextFormField(_cityController, 'Cidade (Preenchimento auto)', validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              
              _buildTextFormField(_breedController, 'Raça', validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              _buildTextFormField(_ageController, 'Idade', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], validator: (v) => v!.isEmpty ? 'Obrigatório' : null),

              const SizedBox(height: 16),
              _buildSectionTitle('Detalhes Físicos'),
             
              _buildDropdown(_sexOptions, 'Sexo', _selectedSex, (val) => setState(() => _selectedSex = val)),
              _buildDropdown(_sizeOptions, 'Tamanho', _selectedSize, (val) => setState(() => _selectedSize = val)),
              _buildTextFormField(_colorController, 'Cor', validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              
              const SizedBox(height: 16),
              _buildSectionTitle('Saúde'),
            
              _buildDropdown(_vaccinationOptions, 'Vacinação', _selectedVaccination, (val) => setState(() => _selectedVaccination = val)),
              _buildTextFormField(_healthStatusController, 'Saúde', validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              SwitchListTile(title: const Text('Castrado?'), value: _isCastrated, onChanged: (v) => setState(() => _isCastrated = v)),

              const SizedBox(height: 16),
              _buildSectionTitle('Bio'),
              _buildTextFormField(_descriptionController, 'Descrição', maxLines: 3, validator: (v) => v!.isEmpty ? 'Obrigatório' : null),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveDog,
                icon: const Icon(Icons.save),
                label: Text(isEditing ? 'Atualizar' : 'Salvar'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController c, String l, {String? Function(String?)? validator, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(controller: c, decoration: InputDecoration(labelText: l, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[100]), validator: validator, keyboardType: keyboardType, inputFormatters: inputFormatters, maxLines: maxLines),
    );
  }

  Widget _buildDropdown(List<String> opts, String l, String? val, void Function(String?) change) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: val, 
        decoration: InputDecoration(labelText: l, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey[100]), 
        items: opts.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), 
        onChanged: change, 
        validator: (v) => v == null ? 'Selecione' : null
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(top: 8, bottom: 4), child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)));
  }
}