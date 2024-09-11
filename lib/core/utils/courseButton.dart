
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class SemesterButton extends StatelessWidget {
  final String semesterName;
  // final String courseTeacher;
  // final Future<Map<String, List<dynamic>>> listOfStudents;
  final VoidCallback goToCourse;

  const SemesterButton(
      {super.key,
      required this.semesterName,
      // required this.courseTeacher,
      required this.goToCourse});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: goToCourse,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gradient: LinearGradient(
            // colors: [Color(0xFF0cdec1), Color(0xFF0ad8e6)],
            colors: [ColorConst.lightButtonColor, ColorConst.darkButtonColor],

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        height: 200,
        width: 175,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                semesterName,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Text(
              //   courseTeacher,
              //   style: const TextStyle(
              //       fontSize: 10,
              //       fontWeight: FontWeight.w500,
              //       color: Colors.white54),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
