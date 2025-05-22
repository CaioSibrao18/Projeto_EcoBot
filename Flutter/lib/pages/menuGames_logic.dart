import 'package:flutter/material.dart';

class GameNavigator {
  static void navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }
}
