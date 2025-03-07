import 'package:flutter/material.dart';

import 'pages/forgetPasswordScreen.dart';
import 'pages/loginScreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ForgotPasswordScreen(), 
    );
  }
}