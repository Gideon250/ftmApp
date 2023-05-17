import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:mecommerce/common/widgets/buttom_bar.dart';
import 'package:mecommerce/features/home/screens/home_screen.dart';
import 'package:mecommerce/constants/global_variable.dart';

class PayMentResponseMomo extends StatefulWidget {
  final String? transactionId;
  final String? plateNumber;
  final String? payFor;

  PayMentResponseMomo({this.transactionId, this.plateNumber, this.payFor});

  @override
  State<PayMentResponseMomo> createState() => _PayMentResponseMomoState();
}

class _PayMentResponseMomoState extends State<PayMentResponseMomo> {
  bool isLoading = true;
  getResponse() async {
    var request = http.Request(
        'POST',
        Uri.parse(
            '${uri}/api/paymentCallBack?transactionId=${widget.transactionId}'));
// request.body = '''''';
    Future.delayed(Duration(seconds: 3), () {});
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    // runs every 2 second
    Timer.periodic(new Duration(seconds: 5), (timer) async {
      print("hello");
      var request = http.Request(
          'GET',
          Uri.parse(
              '${uri}/api/paymentCallBack?transactionId=${widget.transactionId}'));

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var data = jsonDecode(await response.stream.bytesToString());
        print(data['paymentStatus']);
        if (data['paymentStatus'].toString().toLowerCase() != 'pending') {
          timer.cancel();
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Container(
                    height: 200,
                    child: Column(
                      children: [
                        Text(
                            "${data['paymentStatus'].toString().toLowerCase()}",
                            style: TextStyle(),
                            textAlign: TextAlign.center),
                        SizedBox(
                          height: 5,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: ((context) {
                                return ButtomBar();
                              })));
                            },
                            child: Text("Ok")),
                        SizedBox(
                          height: 5,
                        )
                      ],
                    ),
                  ),
                );
              });
        }
      } else {
        print(response.reasonPhrase);
      }

      // await firestore
      //     .collection("finesPayment")
      //     .where("transactionId", isEqualTo: widget.transactionId)
      //     .get()
      //     .then((value1) async {
      //   // String uid = value1.docs[0]['status'];
      //   if (value1.docs[0]['status'].toString().toLowerCase() != 'pending') {
      //     if (widget.payFor.toString().toLowerCase() == 'fines') {
      //       await firestore
      //           .collection("Fines")
      //           .where("PlateNumber", isEqualTo: widget.plateNumber)
      //           .where("Status", isEqualTo: "unpaid")
      //           .get()
      //           .then((value) {
      //         // String id = value.docs[0].id;
      //         value.docs.forEach((element) async {
      //           await firestore
      //               .collection("Fines")
      //               .doc(element.id)
      //               .update({"Status": "paid"}).then((value) {
      //             saveActivity(
      //                 "you have paid  ${widget.payFor} with transctionId #${widget.transactionId}",
      //                 'pool');
      //             timer.cancel();
      //             showDialog(
      //                 context: context,
      //                 builder: (context) {
      //                   return AlertDialog(
      //                     content: Container(
      //                       height: 200,
      //                       child: Column(
      //                         children: [
      //                           Text(
      //                               "${value1.docs[0]['status'].toString().toLowerCase()}",
      //                               style: TextStyle(),
      //                               textAlign: TextAlign.center),
      //                           SizedBox(
      //                             height: 5,
      //                           ),
      //                           GestureDetector(
      //                               onTap: () {
      //                                 Navigator.of(context).pushReplacement(
      //                                     MaterialPageRoute(
      //                                         builder: ((context) {
      //                                   return HomeScreen();
      //                                 })));
      //                               },
      //                               child: Text("Ok")),
      //                           SizedBox(
      //                             height: 5,
      //                           )
      //                         ],
      //                       ),
      //                     ),
      //                   );
      //                 });
      //           });
      //         });
      //       }).onError((error, stackTrace) {});
      //     } else {
      //       await firestore
      //           .collection("License")
      //           .where("PlateNumber", isEqualTo: widget.plateNumber)
      //           .where("Status", isEqualTo: "expired")
      //           .get()
      //           .then((value) {
      //         // String id = value.docs[0].id;

      //         value.docs.forEach((element) async {
      //           DateTime expiredDate = DateTime.parse("${element["ExpDate"]}");

      //           String newDate = "${expiredDate.year + 1}" +
      //               "-" +
      //               "${expiredDate.month}" +
      //               "-" +
      //               "${expiredDate.day}";
      //           await firestore
      //               .collection("License")
      //               .doc(element.id)
      //               .update({"Status": "active"}).then((value) {
      //             timer.cancel();
      //             showDialog(
      //                 context: context,
      //                 builder: (context) {
      //                   return AlertDialog(
      //                     content: Container(
      //                       height: 200,
      //                       child: Column(
      //                         children: [
      //                           Text(
      //                               "${value1.docs[0]['status'].toString().toLowerCase()}",
      //                               style: TextStyle(),
      //                               textAlign: TextAlign.center),
      //                           SizedBox(
      //                             height: 5,
      //                           ),
      //                           GestureDetector(
      //                               onTap: () {
      //                                 Navigator.of(context).pushReplacement(
      //                                     MaterialPageRoute(
      //                                         builder: ((context) {
      //                                   return BottomNavigation();
      //                                 })));
      //                               },
      //                               child: Button("Ok", "FF8A35")),
      //                           SizedBox(
      //                             height: 5,
      //                           )
      //                         ],
      //                       ),
      //                     ),
      //                   );
      //                 });
      //           });
      //         });
      //       }).onError((error, stackTrace) {});
      //     }
      //   }
      // });
      debugPrint(timer.tick.toString());
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Waiting Confirmation",
                    style: TextStyle(
                        color: HexColor("FF8A35"),
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const CircularProgressIndicator(),
                ],
              )
            : FutureBuilder(
                future: getResponse(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return const Text("");
                }),
      ),
    );
  }
}
