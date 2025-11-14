// lib/services/pdf_service.dart

import 'package:pet_center/models/dog.dart';
import 'package:pet_center/models/user.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Usamos 'pw' para evitar conflito
import 'package:printing/printing.dart';

class PdfService {
  
  // Função principal que gera o relatório
  Future<void> generateMyDogsReport(List<Dog> dogs, User user) async {
    
    // 1. Cria o documento PDF
    final pdf = pw.Document();

    // 2. Adiciona uma página
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          // Lista de widgets que irão na página
          return [
            _buildHeader(context, user), // Cabeçalho
            _buildDogList(context, dogs), // A lista de cães
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Widget auxiliar para o cabeçalho
  pw.Widget _buildHeader(pw.Context context, User user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Relatório de Cães Cadastrados',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Doador: ${user.nome}'),
        pw.Text('E-mail: ${user.email}'),
        pw.Text('Telefone: ${user.telefone ?? "Não informado"}'),
        pw.Divider(height: 20, thickness: 2),
      ],
    );
  }

  // Widget auxiliar para a lista de cães
  pw.Widget _buildDogList(pw.Context context, List<Dog> dogs) {
    if (dogs.isEmpty) {
      return pw.Center(child: pw.Text('Nenhum cão cadastrado.'));
    }

    // Criamos uma lista de "mini-fichas"
    return pw.ListView.builder(
      itemCount: dogs.length,
      itemBuilder: (context, index) {
        final dog = dogs[index];
        return pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 16),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 1),
            borderRadius: pw.BorderRadius.circular(5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                dog.name,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Raça: ${dog.breed}'),
              pw.Text('Idade: ${dog.age} anos'),
              pw.Text('Local: ${dog.city}'),
              pw.SizedBox(height: 4),
              pw.Text('Status de Saúde: ${dog.healthStatus}'),
              pw.Text('Vacinação: ${dog.vaccinationStatus}'),
            ],
          ),
        );
      },
    );
  }
}