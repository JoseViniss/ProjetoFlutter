import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  
  Future<void> generatePdf(List<Map<String, dynamic>> rows) async {
    final doc = pw.Document();

    
    final List<List<String>> data = [
      ['ID', 'Cão', 'Adotante', 'Data'],
      ...rows.map((row) => [
            row['id'].toString(),
            row['dogName'].toString(),
            row['adopterName'].toString(),
            row['date'].toString(),
          ])
    ];

    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
            context: context,
            data: data,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
          );
        },
      ),
    );

    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  
  Future<File> generateExcel(List<Map<String, dynamic>> rows) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    
    List<CellValue?> header = [
      TextCellValue('ID'),
      TextCellValue('Cão'),
      TextCellValue('Adotante'),
      TextCellValue('Data')
    ];
    sheet.appendRow(header);

   
    for (var row in rows) {
      
      List<CellValue?> excelRow = [
        TextCellValue(row['id'].toString()),
        TextCellValue(row['dogName'].toString()),
        TextCellValue(row['adopterName'].toString()),
        TextCellValue(row['date'].toString()),
      ];
      sheet.appendRow(excelRow);
    }

   
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/relatorio_adocoes.xlsx');

    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
    }

    return file;
  }
}