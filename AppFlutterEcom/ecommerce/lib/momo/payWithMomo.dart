import 'dart:convert' as convert;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/momo/paymentResponseMomo.dart';
import 'package:provider/provider.dart';

import '../features/address/services/address_services.dart';
import '../providers/location_provider.dart';
// import 'package:motarri/screens/paymentResponseMomo.dart';

class PayWithMomo extends StatefulWidget {
  final String? amount;
  final String? address;
  PayWithMomo({this.amount, this.address});

  @override
  State<PayWithMomo> createState() => _PayWithMomoState();
}

class _PayWithMomoState extends State<PayWithMomo> {
  final AddressServices addressServices = AddressServices();
  bool isLoading = false;
  String? number;
  @override
  void initState() {
    setState(() {
      number = '';
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      bottomSheet: InkWell(
        onTap: () async {
          setState(() {
            isLoading = true;
          });
          Random random = Random();
          int numbers = random.nextInt(1000000);
          String transactionId =
              "6af17b00f4b211ed8d4a97599ea65359" + numbers.toString();
          var headers = {'type': 'MOMO', 'Content-Type': 'application/json'};
          var request = http.Request('POST',
              Uri.parse('https://opay-api.oltranz.com/opay/paymentrequest'));
          request.body = convert.json.encode({
            "telephoneNumber": "$number",
            "amount": 5,
            "organizationId": "cbaf5023-e848-4900-85c9-b419c0ac58b1",
            "description": "Payment for buying products",
            "callbackUrl":
                "https://ecommerce-production-9f2a.up.railway.app/api/paymentCallBack",
            "transactionId": transactionId
          });
          request.headers.addAll(headers);

          http.StreamedResponse response = await request.send();

          if (response.statusCode == 200) {
            var jsonData =
                convert.jsonDecode(await response.stream.bytesToString());
            if (jsonData['code'] != '200') {
              setState(() {
                isLoading = false;
              });
              showDialog(
                  context: context,
                  builder: ((context) {
                    return AlertDialog(
                      title: Text("${jsonData['status']}"),
                      content: Text("${jsonData['description']}"),
                      actions: [
                        TextButton(
                            onPressed: (() {
                              Navigator.of(context).pop();
                            }),
                            child: Text("Ok"))
                      ],
                    );
                  }));
            } else {
              setState(() {
                isLoading = false;
              });
              await addressServices.placeOrder(
                context: context,
                address: widget.address!,
                paymentTransctionId: transactionId,
                totalSum: double.parse("5"),
              );

              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return PayMentResponseMomo(transactionId: transactionId);
              }));
            }
            print(number);
            // print(await response.stream.bytesToString());
          } else {
            print(response.reasonPhrase);
          }
          // isLoading.CurrentLoading = true;
        },
        child: Container(
          width: double.infinity,
          height: 56,
          color: GlobalVariables.secondaryColor,
          child: Center(
            child: Text(
              isLoading ? "Loading..." : "Pay",
              // isLoading.CurrentLoading ? 'Loading... ' : 'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Pay With Mobile Money",
          style: TextStyle(color: HexColor("2D2D2D")),
        ),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: TextField(
                  onChanged: ((value) {
                    setState(() {
                      number = value;
                    });
                  }),
                  decoration: InputDecoration(
                    hintText: "Enter your Phone Number",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1A1A1A).withOpacity(0.2494),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    // suffixIcon: Icon(
                    //   Icons.remove_red_eye_outlined,
                    //   size: 24,
                    //   color: Colors.black.withOpacity(0.1953),
                    // ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: const Color(0xFF1A1A1A).withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
