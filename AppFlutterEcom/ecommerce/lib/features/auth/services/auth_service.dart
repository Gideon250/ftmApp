import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mecommerce/common/widgets/buttom_bar.dart';
import 'package:mecommerce/constants/error_handling.dart';
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/constants/utils.dart';
import 'package:mecommerce/features/admin/screens/admin_screen.dart';
import 'package:mecommerce/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:mecommerce/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/location_provider.dart';

class AuthService {
//sign up user

  void signUpUser({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      User user = User(
        id: '',
        name: name,
        email: email,
        password: password,
        address: '',
        type: '',
        token: '',
        cart: [],
      );
      EasyLoading.show(status: 'Loading....');

      http.Response res = await http.post(
        Uri.parse('$uri/api/signup'),
        body: user.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          EasyLoading.showSuccess('Account created!');

          showSnackBar(
            context,
            'Account created! Login with the same credentials!',
          );
        },
      );
    } catch (e) {
      EasyLoading.showSuccess(e.toString());
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateUserAddress(
      {required BuildContext context,
      required String email,
      required String longtude,
      required String latitude,
      required String address}) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/updateUserAddress'),
        body: json.encode({
          "email": email,
          "longtude": longtude,
          "latitude": latitude,
          "address": address
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(
            context,
            'Account updated!',
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> updateUserAddressLocation(
      {required BuildContext context,
      required String email,
      required String longtude,
      required String latitude,
      required String address}) async {
    try {
      http.Response res = await http.post(
        Uri.parse('$uri/api/updateUserAddress'),
        body: json.encode({
          "email": email,
          "longtude": longtude,
          "latitude": latitude,
          "address": address
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          print("done");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
  //sign in user

  void signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      EasyLoading.show(status: 'Loading....');
      http.Response res = await http.post(
        Uri.parse('$uri/api/signin'),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
        },
      );
      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          EasyLoading.showSuccess('You Logged In');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          Provider.of<UserProvider>(context, listen: false).setUser(res.body);
          final locationData =
              Provider.of<LocationProvider>(context, listen: false);
          await locationData.determinePosition();
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
          var data = jsonDecode(res.body);
          print(data['type']);
          if (data['type'].toString() == "admin" ||
              data['type'].toString() == "deliver") {
            Navigator.pushNamedAndRemoveUntil(
                context, AdminScreen.routeName, (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, ButtomBar.routeName, (route) => false);
          }
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
  //get user data

  void getUserData(
    BuildContext context,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null) {
        prefs.setString('x-auth-token', '');
      }
      var tokenRes = await http.post(
        Uri.parse('$uri/tokenIsValid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          'x-auth-token': token!
        },
      );
      var response = jsonDecode(tokenRes.body);

      if (response == true) {
        //get user data
        http.Response userRes = await http.get(
          Uri.parse('$uri/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
            'x-auth-token': token
          },
        );

        var userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(userRes.body);
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
