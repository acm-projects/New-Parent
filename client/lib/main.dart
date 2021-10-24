import 'package:firebase_core/firebase_core.dart';
import 'package:client/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:client/pages/splash_page.dart';
import 'package:tinycolor2/src/color_extension.dart';

Future main() async {
  // setup flutter and firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.deepPurple.shade300,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          textTheme: const TextTheme(
            headline1: TextStyle(fontWeight: FontWeight.w800, fontSize: 30),
            headline2: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
            subtitle1: TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
          ),
          scaffoldBackgroundColor: Colors.amber.shade100,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(Colors.deepPurple.shade300),
          ).copyWith(
            onBackground: Colors.grey.shade700,
            onSurface: Colors.grey.shade700,
            secondary: Colors.green.shade200,
            onSecondary: Colors.green.shade200.darken(40).desaturate(25),
          ),
          snackBarTheme: SnackBarThemeData(
            elevation: 0,
            backgroundColor: Colors.green.shade200,
            contentTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.green.shade200.darken(40).desaturate(25),
            ),
            actionTextColor: Colors.grey.shade700,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
