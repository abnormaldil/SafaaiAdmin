import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyAgjDoLAlRI-dmsvGEIAIwjAbMcukznaHc",
    appId: "1:618311522744:web:cd6c9db96c9c6bebfc174d",
    messagingSenderId: "618311522744",
    projectId: "rit24safaai",
  ));
  assert(() {
    // This is just a workaround to keep assert in debug mode
    return true;
  }());
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Page',
      debugShowCheckedModeBanner: false, // Set debug to false
      initialRoute: '/home',
      routes: {
        '/home': (context) => Home(),
      },
    );
  }
}
