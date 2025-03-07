import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Login',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), 
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
               
                Image.asset(
                  'assets/images/logoEcoQuest.png',
                  width: 200, 
                  height: 200, 
                  fit: BoxFit.contain, 
                ),
                SizedBox(height: 20), 
                SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                SizedBox(
                  width: 300,
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: 300, 
                  child: ElevatedButton(
                    onPressed: () {
                      
                    },
                    child: Text('Login'),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    
                  },
                  child: Text('Esqueci a senha'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTelalogin extends StatefulWidget {
  const AppTelalogin({super.key});

  @override
  State<AppTelalogin> createState() => _AppTelaloginState();
}

class _AppTelaloginState extends State<AppTelalogin> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}