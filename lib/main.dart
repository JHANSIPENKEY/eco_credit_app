import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(const EcoCreditApp());
}

class EcoCreditApp extends StatelessWidget {
  const EcoCreditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: darkModeNotifier,
      builder: (context, darkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Eco Credit App",

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,

            primaryColor: Colors.green,

            scaffoldBackgroundColor: Color(0xFF0D0D0D),

            cardColor: Color(0xFF1A1A1A),

            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),

            colorScheme: ColorScheme.dark(
              primary: Colors.green,
              secondary: Colors.green,
              surface: Color(0xFF1A1A1A),
            ),
          ),

          themeMode: darkModeNotifier.value ? ThemeMode.dark : ThemeMode.light,

          home: const AuthWrapper(),
        );
      },
    );
  }
}
