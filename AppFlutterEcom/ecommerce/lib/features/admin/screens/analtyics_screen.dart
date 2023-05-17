import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mecommerce/common/widgets/loader.dart';
import 'package:mecommerce/features/admin/model/sales.dart';
import 'package:mecommerce/features/admin/services/admin_services.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:mecommerce/features/admin/widget/category_products_chart.dart';

import '../../../api/pdf_api.dart';
import '../../../api/pdf_report_api.dart';
import '../../../constants/global_variable.dart';
import '../../../models/order.dart';
import 'package:http/http.dart' as http;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AdminServices adminServices = AdminServices();
  int? totalSales;
  List<Sales>? earnings;
  List<Order>? orders;
  List<Order> Reportorders = [];

  void fetchOrders() async {
    orders = await adminServices.fetchAllOrders(context);
    setState(() {});
  }

  @override
  void initState() {
    fetchOrders();
    super.initState();
    getEarnings();
  }

  getEarnings() async {
    var earningData = await adminServices.getEarnings(context);
    totalSales = earningData['totalEarnings'];
    earnings = earningData['sales'];
    setState(() {});
  }

  DateTime? selectedDate;

  DateTime? selectedEnd;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate != null ? selectedDate! : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTo(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedEnd != null ? selectedEnd! : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedEnd = picked;
      });
    }
  }

  Future<void> report(String from, String to) async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('GET', Uri.parse('$uri/api/reports'));
    request.body = json.encode({"from": from, "to": to});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = jsonDecode(await response.stream.bytesToString());
      for (var order in data) {
        var order1 = Order.fromJson(jsonEncode(order));
        print(order1.paymentStatus);
        setState(() {
          Reportorders.add(order1);
        });
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return earnings == null || totalSales == null
        ? const Loader()
        : Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.3),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                                "${selectedDate != null ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" : 'select starting date'}"),
                          ),
                          IconButton(
                              onPressed: () {
                                _selectDate(context);
                              },
                              icon: Icon(Icons.date_range))
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                                border: Border.all(width: 0.3),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text(
                                "${selectedEnd != null ? "${selectedEnd!.day}/${selectedEnd!.month}/${selectedEnd!.year}" : 'select end date'}"),
                          ),
                          IconButton(
                              onPressed: () {
                                _selectTo(context);
                              },
                              icon: Icon(Icons.date_range))
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                      onPressed: () async {
                        report("${selectedDate}", "${selectedEnd}")
                            .then((value) async {
                          if (Reportorders.length > 0) {
                            final pdfFile = await PdfReportApi.generate(
                                Reportorders,
                                "${selectedDate!.day}/ ${selectedDate!.month}/${selectedDate!.year}",
                                "${selectedEnd!.day}/${selectedEnd!.month}/${selectedEnd!.year}");

                            PdfApi.openFile(pdfFile);
                          } else {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: Text(
                                        "No Data Found For Selected Range"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("close"))
                                    ],
                                  );
                                });
                          }
                        });
                        // orders!.forEach((element) {
                        //   var date = DateTime.fromMillisecondsSinceEpoch(
                        //       element.orderedAt);
                        //   var newDate =
                        //       DateTime(date.year, date.month, date.day);
                        //   if (selectedDate!.compareTo(newDate) != -1 ||
                        //       selectedEnd!.compareTo(newDate) == 0) {
                        //     // print(newDate);
                        //   }
                        // });
                      },
                      child: Text("Generete report")),
                ],
              ),
              Text(
                '$totalSales\Rwf',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 250,
                child: CategoryProductsChart(seriesList: [
                  charts.Series(
                    id: 'Sales',
                    data: earnings!,
                    domainFn: (Sales sales, _) => sales.label,
                    measureFn: (Sales sales, _) => sales.earning,
                  ),
                ]),
              )
            ],
          );
  }
}
