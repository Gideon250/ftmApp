import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mecommerce/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

import '../features/admin/services/admin_services.dart';
import '../models/order.dart';

class PdfReceiptApi {
  static Future<File> generate(Order order) async {
    final pdf = Document();
    // File photo1 = File("assets/images/2000.png");
    final data = await rootBundle.load('assets/images/copafle.JGP');
    final image = pw.MemoryImage(data.buffer.asUint8List());
    final data1 = await rootBundle.load('assets/images/signature.png');
    final image1 = pw.MemoryImage(data1.buffer.asUint8List());
    pdf.addPage(
      MultiPage(
        build: (context) => [
          Center(child: pw.Image(image)),
          SizedBox(height: 15),
          Header(text: "Receipt"),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: PdfColors.black,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Date:      ${DateFormat().format(
                      DateTime.fromMillisecondsSinceEpoch(order.orderedAt),
                    )}'),
                    Text('Order ID:          ${order.id}'),
                    Text('Products:          ${order.products.length}'),
                    Column(
                        children: order.products.map((product) {
                      return Row(children: [
                        Text(product.name),
                        Text("  ${order.quantity[0]}")
                      ]);
                    }).toList()),
                    Text('Order Total:      ${order.totalPrice}\Rwf'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
              child: Container(
                  width: 200,
                  child: pw.Image(
                    image1,
                  ))),
          SizedBox(height: 15),
        ],
      ),
    );

    return PdfApi.saveDocument(name: 'receipt.pdf', pdf: pdf);
  }
}
