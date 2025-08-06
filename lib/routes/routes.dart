import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_front/pages/home/home_page.dart';
import 'package:test_front/pages/login/login_page.dart';


class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    '/login': (context) => LoginPage(),
    '/homepage': (context) => HomePage(user: FirebaseAuth.instance.currentUser!), // Pass the current user instance
  };
}