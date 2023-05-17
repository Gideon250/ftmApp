import 'package:flutter/material.dart';
import 'package:mecommerce/common/widgets/customer_textField.dart';
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/constants/utils.dart';
import 'package:mecommerce/features/address/services/address_services.dart';
import 'package:mecommerce/momo/payWithMomo.dart';
import 'package:mecommerce/providers/user_provider.dart';
import 'package:pay/pay.dart';
import 'package:provider/provider.dart';

import '../../../providers/location_provider.dart';

class AddressScreen extends StatefulWidget {
  static const String routeName = '/address';
  final String totalAmount;
  const AddressScreen({super.key, required this.totalAmount});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController flatBuildingController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final _addressFormKey = GlobalKey<FormState>();

  String addressToBeUsed = "";
  List<PaymentItem> paymentItems = [];
  final AddressServices addressServices = AddressServices();

  @override
  void initState() {
    super.initState();
    paymentItems.add(
      PaymentItem(
        amount: widget.totalAmount,
        label: 'Total Amount',
        status: PaymentItemStatus.final_price,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    flatBuildingController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    cityController.dispose();
  }

  void onGooglePayResult(res) {
    if (Provider.of<UserProvider>(context, listen: false)
        .user
        .address
        .isEmpty) {
      addressServices.saveUserAddress(
          context: context, address: addressToBeUsed);
    }
    // addressServices.placeOrder(
    //   context: context,
    //   address: addressToBeUsed,
    //   totalSum: double.parse(widget.totalAmount),
    // );
  }

  void payPressed(String addressFromProvider) {
    addressToBeUsed = "";

    bool isForm = flatBuildingController.text.isNotEmpty ||
        areaController.text.isNotEmpty ||
        pincodeController.text.isNotEmpty ||
        cityController.text.isNotEmpty;

    if (isForm) {
      if (_addressFormKey.currentState!.validate()) {
        addressToBeUsed =
            '${flatBuildingController.text}, ${areaController.text}, ${cityController.text} - ${pincodeController.text}';
      } else {
        throw Exception('Please enter all the values!');
      }
    } else if (addressFromProvider.isNotEmpty) {
      addressToBeUsed = addressFromProvider;
    } else {
      showSnackBar(context, 'ERROR');
    }
  }

  @override
  Widget build(BuildContext context) {
    var address = context.watch<UserProvider>().user.address == ""
        ? context.watch<LocationProvider>().selectedAddress.addressLine
        : context.watch<UserProvider>().user.address;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (address.isNotEmpty)
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              // Form(
              //   key: _addressFormKey,
              //   child: Column(
              //     children: [
              //       CustomTextField(
              //         controller: flatBuildingController,
              //         hintText: 'Flat, House no, Building',
              //       ),
              //       const SizedBox(height: 10),
              //       CustomTextField(
              //         controller: areaController,
              //         hintText: 'Area, Street',
              //       ),
              //       const SizedBox(height: 10),
              //       CustomTextField(
              //         controller: pincodeController,
              //         hintText: 'Pincode',
              //       ),
              //       const SizedBox(height: 10),
              //       CustomTextField(
              //         controller: cityController,
              //         hintText: 'Town/City',
              //       ),
              //       const SizedBox(height: 10),
              //     ],
              //   ),
              // ),
              //const SizedBox(height: 10),
              TextButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          GlobalVariables.secondaryColor)),
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: ((context) {
                      return PayWithMomo(address: address);
                    })));
                  },
                  icon: Icon(
                    Icons.payments_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Momo",
                    style: TextStyle(color: Colors.white),
                  ))
              // GooglePayButton(
              //   onPressed: () => payPressed(address),
              //   paymentConfigurationAsset: 'gpay.json',
              //   onPaymentResult: onGooglePayResult,
              //   paymentItems: paymentItems,
              //   height: 50,
              //   //style: GooglePayButtonStyle.black,
              //   type: GooglePayButtonType.buy,
              //   margin: const EdgeInsets.only(top: 15),
              //   loadingIndicator: const Center(
              //     child: CircularProgressIndicator(),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
