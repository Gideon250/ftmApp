import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mecommerce/features/admin/services/admin_services.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/customer_textField.dart';
import '../../../constants/global_variable.dart';
import '../../auth/services/auth_service.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  //  Auth _auth = Auth.signin;
  final _sinUpFormKey = GlobalKey<FormState>();
  final _signInFormKey = GlobalKey<FormState>();
  final AdminServices adminServices = AdminServices();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.greyBackgroundCOlor,
      appBar: AppBar(
        title: Text("add user"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                tileColor: GlobalVariables.greyBackgroundCOlor,
                title: const Text(
                  'Create account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                color: GlobalVariables.backgroundColor,
                child: Form(
                  key: _sinUpFormKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _nameController,
                        hintText: 'Name',
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email',
                      ),
                      const SizedBox(height: 5),
                      // CustomTextField(
                      //   controller: _passwordController,
                      //   hintText: 'Password',
                      // ),
                      // const SizedBox(height: 5),
                      CustomButton(
                        text: 'Create User',
                        onTap: () async {
                          if (_sinUpFormKey.currentState!.validate()) {
                            EasyLoading.show(status: 'Adding User...');
                            await adminServices.createUser(
                                context: context,
                                email: _emailController.text,
                                name: _nameController.text,
                                password: "123456");
                            EasyLoading.showSuccess('user added successfully');
                            Navigator.pop(context);
                          }
                        },
                      )
                    ],
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
