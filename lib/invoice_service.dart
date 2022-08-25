import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' as material;
import 'package:mvp_proex/features/point/point.model.dart';
import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:pdf_invoice_generator_flutter/model/product.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CustomRow {
  final String name;
  final String descricao;
  final String id;
  CustomRow(this.name, this.descricao, this.id);
}

class PdfInvoiceService {
  Future<Uint8List> createPDF(List<PointModel> points) {
    final pdf = pw.Document();
    pdf.addPage(pw.MultiPage(
      margin: const pw.EdgeInsets.all(50),
      //mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      pageFormat: PdfPageFormat.a4,
      orientation: pw.PageOrientation.portrait,
      build: (pw.Context context) {
        List<pw.Widget> listaWidget = <pw.Widget>[];
        for (PointModel point in points) {
          listaWidget.add(pw.Container(
            height: 370,
            width: 300,
            decoration: pw.BoxDecoration(
                border: pw.Border.all(style: pw.BorderStyle.dashed)),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    point.name,
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                  pw.SizedBox(height: 10),
                  pw.BarcodeWidget(
                    data: point.id.toString(),
                    barcode: pw.Barcode.qrCode(
                        typeNumber: 2,
                        errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high),
                    width: 150,
                    height: 150,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    point.description,
                    textAlign: pw.TextAlign.center,
                  ),
                ]),
          ));
        }
        return listaWidget;
      },
    ));
    //}
    return pdf.save();
  }

  Future<void> savePdfFile(String fileName, Uint8List byteList) async {
    final output = await getTemporaryDirectory();
    var filePath = "${output.path}/$fileName.pdf";
    final file = File(filePath);
    await file.writeAsBytes(byteList);
    await OpenDocument.openDocument(filePath: filePath);
  }
}
