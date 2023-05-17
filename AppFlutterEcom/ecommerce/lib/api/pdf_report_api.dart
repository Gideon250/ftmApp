import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:mecommerce/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

import '../features/admin/services/admin_services.dart';
import '../models/order.dart';

class PdfReportApi {
  static Future<File> generate(
      List<Order>? orders, String start, String end) async {
    final pdf = Document();
    final data = await rootBundle.load('assets/images/copafle.JPG');
    final image = pw.MemoryImage(data.buffer.asUint8List());
    pdf.addPage(
      MultiPage(
        build: (context) => [
          Center(child: pw.Image(image)),
          SizedBox(height: 15),
          Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("from ${start}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(" to ${end}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
          ])),
          SizedBox(height: 15),
          Center(
              child: Text("Sales Report",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32))),
          SizedBox(height: 15),
          Table(
              columnWidths: {
                0: FractionColumnWidth(0.5),
                1: FractionColumnWidth(0.25),
                2: FractionColumnWidth(0.25),
              },
              tableWidth: TableWidth.max,
              border: TableBorder.all(color: PdfColors.black, width: 3),
              children: [
                TableRow(children: [
                  Text(
                    "OrderId",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontBold: Font.timesBold(),
                        color: PdfColors.red300),
                  ),
                  Text(
                    "Product",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontBold: Font.timesBold(),
                        color: PdfColors.red300),
                  ),
                  Text(
                    "Amount",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontBold: Font.timesBold(),
                        color: PdfColors.red300),
                  ),
                ])
              ]),
          Table(
            columnWidths: {
              0: FractionColumnWidth(0.5),
              1: FractionColumnWidth(0.25),
              2: FractionColumnWidth(0.25),
            },
            border: TableBorder.all(color: PdfColors.black, width: 1.5),
            children: orders!.map((order) {
              return TableRow(children: [
                Text(
                  "${order.id}",
                  style: TextStyle(fontSize: 15.0),
                ),
                Column(
                    children: order.products
                        .map(
                          (product) => Text(
                            "${product.name}",
                            style: TextStyle(fontSize: 15.0),
                          ),
                        )
                        .toList()),
                Text(
                  "${order.totalPrice}",
                  style: TextStyle(fontSize: 15.0),
                ),
              ]);
            }).toList(),
          ),
          SizedBox(
            height: 20,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(children: [
              Text("Signature ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              SizedBox(
                height: 10,
              ),
              Text(".............. ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))
            ]),
            Column(children: [
              Text("Stamp ",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
              SizedBox(
                height: 10,
              ),
              Text("",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))
            ])
          ])
        ],
      ),
    );

    return PdfApi.saveDocument(name: 'salesreport.pdf', pdf: pdf);
  }
}
