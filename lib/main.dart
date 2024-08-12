import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsmb_rider/Page/Main/push_Navigate.dart';
import 'package:wsmb_rider/firebase_options.dart';
import 'package:wsmb_rider/Page/Launch/launch_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  void checkToken() async {
    final pref = await SharedPreferences.getInstance();
    //pref.remove('token');
    userId = pref.getString('token');
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context)._themeData,
      home: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userId == null
              ? const LaunchScreen()
              : PushNavigate(userId: userId!),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  final ThemeData _themeData = _lighTheme;
  ThemeData get themeData => _themeData;

  static const Color highlight = Color.fromARGB(255, 72, 206, 76);
  static const Color honeydew = Color.fromARGB(255, 206, 241, 208);
  static const Color trust = Color.fromARGB(255, 144, 181, 212);
  static const Color pop = Color.fromARGB(255, 255, 230, 0);
  static const Color light = Color.fromARGB(255, 240, 239, 239);

  static final ThemeData _lighTheme = ThemeData(
      textTheme: GoogleFonts.montserratTextTheme(
          const TextTheme(bodyMedium: TextStyle(color: Colors.black))),
      iconTheme: const IconThemeData(color: highlight),
      useMaterial3: true,
      scaffoldBackgroundColor: light,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: highlight, foregroundColor: Colors.black)),
      colorScheme: const ColorScheme.light(
          primary: highlight,
          secondary: highlight,
          tertiary: trust,
          surface: light));
}

class Label {
  static String getLabel() {
    final head = WordPair.random();
    final tail = Random().nextInt(100);
    return "$head$tail";
  }
}
