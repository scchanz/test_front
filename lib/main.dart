import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:test_front/pages/login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Firebase App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login' : (context) => const LoginPage(),
      },
    );
  }
}
