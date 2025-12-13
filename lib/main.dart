import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ClickerApp());
}

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Clicker', home: const ClickerHomePage());
  }
}

class ClickerHomePage extends StatefulWidget {
  const ClickerHomePage({super.key});

  @override
  State<ClickerHomePage> createState() => _ClickerHomePageState();
}

class _ClickerHomePageState extends State<ClickerHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center());
  }
}
