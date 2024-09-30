
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/constants.dart';
import 'features/courses_selection/presentation/views/semester_selection_screen.dart';
// import 'features/train_face/presentation/views/home_screen.dart';

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
// background colour  hex #3a3b45
  //button hex  #0cdec1 and #0ad8e6

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0XFFfcfcfc),
        // colorScheme:
        //     ColorScheme.fromSeed(seedColor: ColorConst.backgroundColor),
        // useMaterial3: true,
      ),
      // theme: ThemeData( scaffoldBackgroundColor: Colors.lightGreenAccent,),
      // home: SafeArea(child: HomeScreen()),
      home: SafeArea(child: SemesterSelectionScreen()),
      // home: SafeArea(child: SemesterSelectionScreen()),
    );
  }
}
