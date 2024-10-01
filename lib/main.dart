
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/courses_selection/presentation/views/semester_selection_screen.dart';


void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that Flutter is initialized

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0XFFfcfcfc),
      ),

      home: SafeArea(child: SemesterSelectionScreen()),
    );
  }
}
