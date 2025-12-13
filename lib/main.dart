import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ClickerApp());
}

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        const brandColor = Colors.red;

        return MaterialApp(
          title: 'Clicker',
          theme: ThemeData(
            colorScheme: lightDynamic != null
                ? lightDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: brandColor,
                    brightness: Brightness.light,
                  ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic != null
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: brandColor,
                    brightness: Brightness.dark,
                  ),
            useMaterial3: true,
          ),
          home: const ClickerHomePage(),
        );
      },
    );
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
