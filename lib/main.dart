import 'package:flutter/material.dart';
import 'assets/colors.dart' as colors;
import 'home_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(scaffoldBackgroundColor: colors.bluegray),
      home: const HomeScreen(),
    );  
  }
}





