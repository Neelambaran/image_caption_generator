import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:generatelivecaptions/login_screen/login_screen.dart';
import 'splashscreen.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Generate Live Captions',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
