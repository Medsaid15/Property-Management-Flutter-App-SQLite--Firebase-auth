import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:property_management/screens/home_screen.dart';
import 'package:property_management/screens/login/login.dart';
import 'package:property_management/firebase_options.dart';
import 'package:property_management/screens/signup/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Property Management',
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/home': (context) => const HomeScreen(), // Your home screen after login
      },
    );
  }
}
