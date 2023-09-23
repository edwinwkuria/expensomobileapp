import 'package:expenso/pages/expense.dart';
import 'package:expenso/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final router = GoRouter(routes: [
  GoRoute(
    path: "/",
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    path: '/expenses',
    builder: (context, state) => const ExpensesPage(),
  ),
]);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          // Customize the appearance of input fields here
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          fillColor: Colors.grey[200], // Slight grey background
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Rounded border
            borderSide: BorderSide.none, // Remove the default border
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(0),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              const EdgeInsets.symmetric(vertical: 16.0), // Adjust vertical padding as needed
            ),
            minimumSize: MaterialStateProperty.all<Size>(
              const Size(double.infinity, 48), // Full width by default
            ),
          ),
        ),
      ),
    );
  }
}
