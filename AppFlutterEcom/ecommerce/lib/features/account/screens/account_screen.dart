import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/features/account/widgets/below_app_bar.dart';
import 'package:mecommerce/features/account/widgets/orders.dart';
import 'package:mecommerce/features/account/widgets/top_buttons.dart';
import 'package:mecommerce/features/admin/model/user.dart';
import 'package:mecommerce/features/admin/screens/add_user_screen.dart';
import 'package:mecommerce/mapScreen.dart';
import 'package:provider/provider.dart';

import '../../../providers/location_provider.dart';
import '../../../providers/user_provider.dart';
import '../services/account_services.dart';
import '../widgets/account_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<User> usersList = <User>[];

  getUsers() async {
    var request = http.Request('GET', Uri.parse('$uri/users'));

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = convert.jsonDecode(await response.stream.bytesToString());
      for (var item in data['users']) {
        User user = User.fromJson(item);
        setState(() {
          usersList.add(user);
        });
      }
    } else {
      print(response.reasonPhrase);
      print("heelo");
    }
  }

  @override
  void initState() {
    getUsers();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var type = Provider.of<UserProvider>(context).user.type;
    final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: type == "admin"
            ? const Size.fromHeight(0)
            : const Size.fromHeight(50),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: GlobalVariables.appBarGradient,
            ),
          ),
          title: type == "admin" ? Text('') : BelowAppBar(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            if (type.toString() != "admin") TopButtons(),
            ListTile(
              title: Text("Address"),
              subtitle: Text(locationData.selectedAddress != null
                  ? "${locationData.selectedAddress.addressLine}"
                  : ""),
              leading: Icon(Icons.location_pin),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return MapScreen();
                  }));
                },
              ),
            ),
            SizedBox(height: 20),
            if (type.toString() == "user") Orders(),
            if (type.toString() == "admin")
              Row(
                children: [
                  AccountButton(
                    text: 'Add User',
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: ((context) {
                      return AddUserScreen();
                    }))),
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (type.toString() == "admin")
              Container(
                height: MediaQuery.of(context).size.height * .35,
                child: ListView.builder(
                    itemCount: usersList.length,
                    itemBuilder: ((context, index) {
                      return ListTile(
                        title: Text(usersList[index].name!),
                        subtitle: Text(usersList[index].email!),
                        leading: Icon(Icons.account_box),
                      );
                    })),
              ),
            SizedBox(height: 20),
            if (type.toString() == "admin")
              Container(
                height: 200,
                child: Column(
                  children: [
                    Row(
                      children: [
                        AccountButton(
                          text: 'Log Out',
                          onTap: () => AccountServices().logOut(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
