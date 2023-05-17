import 'dart:io';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:mecommerce/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../features/admin/services/admin_services.dart';
import '../models/order.dart';

class PdfReportApi {
  static Future<File> generate(List<Order>? orders, plateNumber) async {
    final pdf = Document();

    pdf.addPage(
      MultiPage(
        build: (context) => [
          Header(text: "Sales Report1"),
          Table(
              border: TableBorder.all(color: PdfColors.black, width: 3),
              children: [
                TableRow(children: [
                  Text(
                    "OrderId",
                    style: TextStyle(fontSize: 15.0),
                  ),
                  Text(
                    "Product",
                    style: TextStyle(fontSize: 15.0),
                  ),
                  Text(
                    "Amount",
                    style: TextStyle(fontSize: 15.0),
                  ),
                ])
              ]),
          Table(
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
          Text(".......... /  ${DateTime.now().month} / ${DateTime.now().year}")
        ],
      ),
    );

    return PdfApi.saveDocument(name: 'salesreport.pdf', pdf: pdf);
  }
}
