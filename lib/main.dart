import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "services/app_state.dart";
import "theme/app_theme.dart";
import "screens/splash_screen.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const TempBoxApp());
}

class TempBoxApp extends StatefulWidget {
  const TempBoxApp({super.key});

  @override
  State<TempBoxApp> createState() => _TempBoxAppState();
}

class _TempBoxAppState extends State<TempBoxApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEMPBOX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: SplashScreen(appState: _appState),
    );
  }
}
