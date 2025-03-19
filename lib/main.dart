import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'screens/welcome_page.dart';
import 'screens/signup_page.dart';
import 'screens/login_page.dart';
import 'screens/additional_details_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        // Add other routes here
      },
    );
  }
}
