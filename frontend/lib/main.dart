import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(BlinkitApp());
}

class BlinkitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blinkit Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: LoginScreen(),
    );
  }
}