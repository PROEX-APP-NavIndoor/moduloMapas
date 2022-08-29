import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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
    final image = pw.MemoryImage(
      File('assets/images/logo.png').readAsBytesSync(),
    );
    for (PointModel point in points) {
      pdf.addPage(pw.Page(
          margin: const pw.EdgeInsets.all(50),
          //mainAxisAlignment: pw.MainAxisAlignment.center,
          //crossAxisAlignment: pw.CrossAxisAlignment.center,
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.portrait,
          build: (pw.Context context) {
            return pw.Container(
              height: 370 * 2,
              width: 300 * 2,
              decoration: pw.BoxDecoration(
                  border: pw.Border.all(style: pw.BorderStyle.solid)),
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  children: [
                    pw.Text("MarleyApp",
                        style: pw.TextStyle(
                            //decoration: pw.TextDecoration.underline,
                            //decorationStyle: pw.TextDecorationStyle.solid,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 25)),
                    pw.Image(
                      image,
                      height: 125,
                      width: 125,
                    ),
                    pw.Text(
                      point.name,
                      style: pw.TextStyle(
                          decoration: pw.TextDecoration.underline,
                          decorationStyle: pw.TextDecorationStyle.solid,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 25),
                    ),
                    pw.SizedBox(height: 20),
                    pw.BarcodeWidget(
                      data: point.id.toString(),
                      barcode: pw.Barcode.qrCode(
                          typeNumber: 2,
                          errorCorrectLevel: pw.BarcodeQRCorrectionLevel.high),
                      width: 300,
                      height: 300,
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      point.description,
                      style: const pw.TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ]),
            );
          }));
    }
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
