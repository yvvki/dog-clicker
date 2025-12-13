import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ClickerApp());
}

class ClickerApp extends StatefulWidget {
  const ClickerApp({super.key});

  @override
  State<ClickerApp> createState() => _ClickerAppState();
}

class _ClickerAppState extends State<ClickerApp> {
  static const _brandColor = Color(0xfff30069);

  static const _useDynamicColorKey = 'use_dynamic_color';
  bool _useDynamicColor = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDynamicColor());
  }

  ColorScheme _resolveScheme({
    required ColorScheme? dynamicScheme,
    required Brightness brightness,
  }) {
    final fallback = ColorScheme.fromSeed(
      seedColor: _brandColor,
      brightness: brightness,
    );
    return !_useDynamicColor
        ? fallback
        : dynamicScheme?.harmonized() ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightScheme = _resolveScheme(
          dynamicScheme: lightDynamic,
          brightness: Brightness.light,
        );
        final darkScheme = _resolveScheme(
          dynamicScheme: darkDynamic,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          title: 'Clicker',
          theme: ThemeData(colorScheme: lightScheme),
          darkTheme: ThemeData(colorScheme: darkScheme),
          home: ClickerHomePage(
            title: 'Clicker',
            assetDown: 'assets/clicker-down.wav',
            assetUp: 'assets/clicker-up.wav',
            useDynamicColor: _useDynamicColor,
            onUseDynamicColorChanged: _setDynamicColor,
          ),
          
        );
      },
    );
  }

  Future<void> _restoreDynamicColor() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_useDynamicColorKey);

    if (stored != null && stored != _useDynamicColor) {
      setState(() => _useDynamicColor = stored);
    }
  }

  Future<void> _setDynamicColor(bool value) async {
    setState(() => _useDynamicColor = value);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useDynamicColorKey, value);
  }
}

class ClickerHomePage extends StatefulWidget {
  const ClickerHomePage({
    super.key,
    required this.title,
    required this.assetDown,
    required this.assetUp,
    required this.useDynamicColor,
    required this.onUseDynamicColorChanged,
  });

  final String title;
  final String assetDown;
  final String assetUp;
  final bool useDynamicColor;
  final ValueChanged<bool> onUseDynamicColorChanged;

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
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle dynamic color',
            icon: Icon(
              widget.useDynamicColor ? Icons.palette : Icons.palette_outlined,
            ),
            onPressed: () => widget.onUseDynamicColorChanged(!widget.useDynamicColor),
          ),
        ],
      ),
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
