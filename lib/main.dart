import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ClickerApp());
}

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        const brandColor = Color(0xfff30069);

        return MaterialApp(
          title: 'Clicker',
          theme: ThemeData(
            colorScheme: lightDynamic != null
                ? lightDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: brandColor,
                    brightness: Brightness.light,
                  ),
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic != null
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: brandColor,
                    brightness: Brightness.dark,
                  ),
          ),
          home: ClickerHomePage(
            assetDown: 'assets/clicker-down.wav',
            assetUp: 'assets/clicker-up.wav',
          ),
        );
      },
    );
  }
}

class ClickerHomePage extends StatefulWidget {
  const ClickerHomePage({
    super.key,
    required this.assetDown,
    required this.assetUp,
  });

  final String assetDown;
  final String assetUp;

  @override
  State<ClickerHomePage> createState() => _ClickerHomePageState();
}

class _ClickerHomePageState extends State<ClickerHomePage> {
  late final SoLoud _soloud;

  late final AudioSource _audioDown;
  late final AudioSource _audioUp;

  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _soloud = SoLoud.instance;
      await _soloud.init(bufferSize: 512);
      _soloud.setGlobalVolume(1.5); // No way to disable CLIP_ROUNDOFF

      _audioDown = await _soloud.loadAsset(widget.assetDown);
      _audioUp = await _soloud.loadAsset(widget.assetUp);
    });
  }

  @override
  void dispose() {
    _soloud.deinit();
    super.dispose();
  }

  void _down() {
    if (_isTapped) return;
    setState(() => _isTapped = true);
    _soloud.play(_audioDown);
  }

  void _up() {
    if (!_isTapped) return;
    setState(() => _isTapped = false);
    _soloud.play(_audioUp);
  }

  @override
  Widget build(BuildContext context) {
    final diameter = MediaQuery.of(context).size.shortestSide * 0.5;

    return Scaffold(
      body: Center(
        child: ClipOval(
          child: Listener(
            onPointerDown: (_) => _down(),
            onPointerUp: (_) => _up(),
            onPointerCancel: (_) => _up(),
            child: AnimatedContainer(
              duration: Durations.short1,
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: !_isTapped
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
