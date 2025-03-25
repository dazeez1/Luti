import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luti/view/guestScreens/account_screen.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'view/welcome_page.dart';
import 'view/signup_page.dart';
import 'view/login_page.dart';
import 'view/additional_details_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Welcome Page App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/signup': (context) => SignupPage(),
        '/login': (context) => LoginPage(),
        '/additional-details': (context) => AdditionalDetailsPage(),
        '/account_screen': (context) => AccountScreen(),
        // Add other routes here
      },
    );
  }
}
