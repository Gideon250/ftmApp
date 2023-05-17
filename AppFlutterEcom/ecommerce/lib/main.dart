import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mecommerce/common/widgets/buttom_bar.dart';
import 'package:mecommerce/constants/global_variable.dart';
import 'package:mecommerce/features/admin/screens/admin_screen.dart';
import 'package:mecommerce/features/auth/screens/auth_screens.dart';
import 'package:mecommerce/features/auth/services/auth_service.dart';
import 'package:mecommerce/mapScreen.dart';
import 'package:mecommerce/providers/location_provider.dart';
import 'package:mecommerce/providers/user_provider.dart';
import 'package:mecommerce/router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => LocationProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ftm Ecommerce',
      theme: ThemeData(
        scaffoldBackgroundColor: GlobalVariables.backgroundColor,
        colorScheme: const ColorScheme.light(
          primary: GlobalVariables.secondaryColor,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
        ),
      ),
      builder: EasyLoading.init(),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: Provider.of<UserProvider>(context).user.token.isNotEmpty
          ? Provider.of<UserProvider>(context).user.type == 'user'
              ? const ButtomBar()
              : const AdminScreen()
          : const AuthScreen(),
    );
  }
}
