
import 'package:flutter/material.dart';
import 'package:pet_center/models/dog.dart';
import 'package:pet_center/providers/auth_provider.dart';
import 'package:pet_center/services/db_service.dart';
import 'package:pet_center/widgets/dog_card.dart';
import 'package:pet_center/screens/register_dog_screen.dart';
import 'package:provider/provider.dart';
import 'package:pet_center/services/pdf_service.dart';

class MyDogsScreen extends StatefulWidget {
  const MyDogsScreen({super.key});

  @override
  State<MyDogsScreen> createState() => _MyDogsScreenState();
}

class _MyDogsScreenState extends State<MyDogsScreen> {
  final DBService db = DBService();
  List<Dog> myDogs = [];
  bool isLoading = true;
  bool _isInit = true; // Flag para o didChangeDependencies
  bool _isExportingPdf = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      loadMyDogs();
    }
    _isInit = false;
  }

  Future<void> loadMyDogs() async {
    setState(() => isLoading = true);
    
    // Pega o ID do usuário logado
    final userId = Provider.of<AuthProvider>(context, listen: false).currentUser?.id;
    if (userId == null) {
       setState(() => isLoading = false);
       return; // Segurança
    }

    // Busca no banco os cães APENAS desse usuário
    final list = await db.getDogsForUser(userId);
    
    setState(() {
      myDogs = list;
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
      loadMyDogs(); // Recarrega esta tela
    }
  }

  void _editDog(Dog dogToEdit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Leva para a tela de cadastro, mas no modo "Edição"
        builder: (context) => RegisterDogScreen(dogToEdit: dogToEdit),
      ),
    ).then((_) {
      // Quando a edição for salva, recarrega a lista
      loadMyDogs();
    });
  }
  
  Future<void> _exportToPdf() async {
    setState(() => _isExportingPdf = true);

    // Pega o usuário logado (para o cabeçalho do relatório)
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      setState(() => _isExportingPdf = false);
      return; // Segurança
    }
    
    // Pega a lista de cães que já foi carregada
    final dogsToExport = myDogs; 

    try {
      // Chama o nosso novo serviço de PDF
      final pdfService = PdfService();
      await pdfService.generateMyDogsReport(dogsToExport, user);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    }

    setState(() => _isExportingPdf = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Cães Cadastrados'), // 1. Título novo
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadMyDogs, // 2. Botão de recarregar
          ),

          IconButton(
            icon: _isExportingPdf
                ? const SizedBox( // Mostra um "loading"
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : const Icon(Icons.picture_as_pdf), // O ícone de PDF
            tooltip: 'Exportar para PDF',
            onPressed: _isExportingPdf ? null : _exportToPdf, // Desativa se já estiver carregando
          ),

        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : myDogs.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Você ainda não cadastrou nenhum cão.', // 3. Texto novo
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ),
                )
              : ListView.builder( // 4. Um ListView simples, sem bugs
                  itemCount: myDogs.length,
                  padding: const EdgeInsets.all(8.0), // Espaçamento
                  itemBuilder: (_, idx) {
                    final dog = myDogs[idx];
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(
                        height: 670,
                        child: DogCard(
                          dog: dog,
                          onEdit: () => _editDog(dog),
                          onConfirmAdoption: () => confirmAdoption(dog),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}