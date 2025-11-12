import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import '../services/db_service.dart';
import '../models/dog.dart';
import '../services/api_service.dart';
import '../models/breed_model.dart';  
import 'package:provider/provider.dart';
import 'package:pet_center/providers/auth_provider.dart';

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
  final APIService _apiService = APIService();
  List<Breed> _breeds = []; // Lista de raças que virá da API
  bool _isLoadingBreeds = true; // Para mostrar um "loading"
  String? _selectedBreed; // Raça selecionada no dropdown
  double? _latitude;
  double? _longitude;
  
  final List<String> _sexOptions = ['Macho', 'Fêmea'];
  final List<String> _sizeOptions = ['Pequeno', 'Médio', 'Grande'];
  final List<String> _vaccinationOptions = ['Vacinado', 'Pendente', 'Não vacinado'];

  @override
  void initState() {
    super.initState();
    _loadBreeds();
   
    if (widget.dogToEdit != null) {
      final d = widget.dogToEdit!;
      _nameController.text = d.name;
      _photoUrlController.text = d.photoUrl;

      _selectedBreed = d.breed;
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

  Future<void> _loadBreeds() async {
    // Busca as raças na API
    final breedsList = await _apiService.getBreeds();
    
    // Se for um cão que já estava salvo com uma raça que não veio da API
    // (ex: "goudem"), adicionamos essa raça na lista para não quebrar a edição.
    if (widget.dogToEdit != null && 
        !breedsList.any((b) => b.name == widget.dogToEdit!.breed)) {
      breedsList.add(Breed(id: 'custom', name: widget.dogToEdit!.breed));
    }
    
    setState(() {
      _breeds = breedsList;
      _isLoadingBreeds = false;
    });
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

  // lib/screens/register_dog_screen.dart

  Future<void> _saveDog() async {
    if (_formKey.currentState?.validate() ?? false) {
      
      // --- A GRANDE CORREÇÃO ESTÁ AQUI ---
      // 1. Pegar o "gerente" de autenticação
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 2. Checagem de segurança (vital)
      if (!authProvider.isAuthenticated) {
        // Isso não deve acontecer (graças ao AuthWrapper), mas é bom previnir.
        _showErrorDialog("Sua sessão expirou. Por favor, faça login novamente.");
        return;
      }

      // 3. Pegar o ID do usuário que está logado!
      final int currentUserId = authProvider.currentUser!.id!;
      // --- FIM DA CORREÇÃO ---

      final newDog = Dog(
        id: widget.dogToEdit?.id,
        name: _nameController.text,
        photoUrl: _photoUrlController.text,
        breed: _selectedBreed!,
        age: int.tryParse(_ageController.text) ?? 0,
        city: _cityController.text,
        description: _descriptionController.text,
        color: _colorController.text,
        healthStatus: _healthStatusController.text,
        sex: _selectedSex!,
        size: _selectedSize!,
        vaccinationStatus: _selectedVaccination!,
        isCastrated: _isCastrated,
        latitude: _latitude,
        longitude: _longitude,
        
        // --- A LINHA QUE O ERRO PEDIU ---
        userId: currentUserId,
      );

      // O resto da sua lógica de 'try/catch' e 'modals' continua perfeita
      try {
        if (widget.dogToEdit == null) {
          await db.insertDog(newDog);
          _showSuccessDialog(newDog.name); 
        } else {
          // Lógica de update... (também funciona, pois 'newDog' tem o userId)
          await db.updateDog(newDog);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${newDog.name} atualizado!')));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      }
    }
  }

  Future<void> _deleteDog() async {
    if (widget.dogToEdit != null && widget.dogToEdit!.id != null) {
      await db.deleteDog(widget.dogToEdit!.id!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cão excluído com sucesso!')));
      Navigator.of(context).pop(true);
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
              _isLoadingBreeds
                  ? const Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: CircularProgressIndicator(),
                    ))
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedBreed,
                        decoration: InputDecoration(
                          labelText: 'Raça',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),

                        // Constrói a lista de itens do dropdown
                        items: _breeds.map((breed) {
                          return DropdownMenuItem(
                            value: breed.name, // O valor salvo será o nome da raça
                            child: Text(breed.name),
                          );
                        }).toList(),

                        onChanged: (val) => setState(() => _selectedBreed = val),
                        validator: (v) => v == null ? 'Selecione uma raça' : null,
                        isExpanded: true, // Importante para nomes compridos
                      ),
                    ),
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
  
  void _clearForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _photoUrlController.clear();
    _ageController.clear();
    _colorController.clear();
    _descriptionController.clear();
    _cityController.clear();
    _healthStatusController.clear();
    _cepController.clear();
    setState(() {
      _selectedSex = null;
      _selectedSize = null;
      _selectedVaccination = null;
      _isCastrated = false;
    });
  }

  // 2. O modal de ERRO
  Future<void> _showErrorDialog(String error) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário precisa tocar no botão
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Ops! Algo deu errado'),
          content: SingleChildScrollView(
            child: Text('Não foi possível salvar o cãozinho.\n\nErro: $error'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha só o dialog
              },
            ),
          ],
        );
      },
    );
  }

  // 3. O modal de SUCESSO (Versão "Concluir")
  Future<void> _showSuccessDialog(String dogName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário DEVE clicar no botão
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Sucesso!'),
          // Mensagem atualizada
          content: SingleChildScrollView(
            child: Text(
                '$dogName foi cadastrado com sucesso!\n'),
          ),
          actions: <Widget>[
            // --- O SEU NOVO BOTÃO ---
            TextButton(
              child: const Text('Concluir'),
              onPressed: () {
                // A função que era do "Cadastrar Outro"
                _clearForm();
                Navigator.of(dialogContext).pop(); // Fecha SÓ o dialog
              },
            ),
            // --- FIM DO BOTÃO ---
          ],
        );
      },
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