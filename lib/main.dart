import 'package:flutter/material.dart';
import 'package:proyecto_final_construccion/screens/start_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: StartScreen(),
    );
  }
}
