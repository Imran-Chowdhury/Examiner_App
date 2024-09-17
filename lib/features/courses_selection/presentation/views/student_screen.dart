import 'dart:convert';

import 'package:camera/camera.dart';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import '../../../../core/base_state/course_screen_state.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/background_widget.dart';
import '../riverpod/course_screen_riverpod.dart';
import '../riverpod/exam_riverpod.dart';
import 'exam_screen.dart';

// ignore: must_be_immutable
class CourseScreen extends ConsumerStatefulWidget {
  CourseScreen({
    super.key,
    // required this.courseName,
    // required this.semesterId,
    // required this.isolateInterpreter,
    // // required this.detectionController,
    // required this.faceDetector,
    // required this.cameras,
    // required this.interpreter,
    //

    required this.studentList,
    required this.examId
  });
  // final String courseName;
  // final String semesterId;

  List<dynamic>? studentList;
  final String examId;


  // final FaceDetector faceDetector;
  // late List<CameraDescription> cameras;
  // final tf_lite.Interpreter interpreter;
  // final tf_lite.IsolateInterpreter isolateInterpreter;

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

// 2. extend [ConsumerState]
class _CourseScreenState extends ConsumerState<CourseScreen> {



  // List<dynamic>? listOfStudent;


  @override
  void initState() {
    super.initState();
    // ref.read(getAStudentProvider(widget.examId).notifier).setTheState(widget.studentList);
    Future.microtask(()=> ref.read(getAStudentProvider(widget.examId).notifier).setTheState(widget.studentList));

  }





  @override
  Widget build(BuildContext context) {

    var studentState = ref.watch(getAStudentProvider(widget.examId));
    GetAStudentNotifier studentController = ref.watch(getAStudentProvider(widget.examId).notifier);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    List<dynamic>? cachedStudentList;




    // if (studentState is AsyncData) {
    //   listOfStudent = studentState.value;
    // }

    return SafeArea(
      child: Scaffold(
        floatingActionButton:
            add(context, studentController, formKey),
        // backgroundColor: const Color(0xFF3a3b45),
        body: Stack(
          children: [
            const BackgroudContainer(),
            Column(
              children: [
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
                //   child: Center(
                //     child: Text(
                //       widget.courseName,
                //       style: const TextStyle(
                //         fontSize: 24,
                //         fontWeight: FontWeight.bold,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  child:studentState.when(

                    data: (students) {
                      if (students == null || students.isEmpty) {

                        return const Center(
                          child: Text(
                            'No Students available. Fetch Students By Selecting Range!',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18),
                          ),
                        );
                      }
                      return listofStudents(students);

                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  ),
                  //
                  // listOfStudent!.isEmpty
                  //     ? const Center(
                  //         child: Text('No Student'),
                  //       )
                  //     : listofStudents(listOfStudent),
                      // : (studentState is AsyncData)
                      //     ? listofStudents(studentState.value)
                      //     : listofStudents(listOfStudent),

                ),
                //
                // Expanded(
                //   child: studentState.when(
                //     data: (students) {
                //       if (students == null || students.isEmpty) {
                //         // Check if listOfStudent is not null or empty
                //         if (widget.studentList != null && widget.studentList!.isNotEmpty) {
                //           // Display listOfStudent if it exists
                //           cachedStudentList = widget.studentList;
                //           return listofStudents(widget.studentList);
                //         } else {
                //           // Show a message if both students and listOfStudent are empty
                //           return const Center(
                //             child: Text(
                //               'No Students available. Fetch Students By Selecting Range!',
                //               style: TextStyle(
                //                 color: Colors.white70,
                //                 fontSize: 18,
                //               ),
                //             ),
                //           );
                //         }
                //       }
                //       // If students is not empty, display it
                //       cachedStudentList = students;
                //       return listofStudents(students);
                //     },
                //     loading: () => const Center(child: CircularProgressIndicator()),
                //     error: (error, stack) {
                //       if (cachedStudentList != null &&
                //           cachedStudentList!.isNotEmpty) {
                //         // Show a toast message for the error
                //         Fluttertoast.showToast(
                //           msg: "Error: $error",
                //
                //         );
                //       }
                //       return listofStudents(cachedStudentList);
                //     }
                //   ),
                // ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget listofStudents(List<dynamic>? studentList) {
    return ListView.builder(
      itemCount: studentList?.length,
      itemBuilder: (context, index) {
        print('The list of days is $studentList');
        return GestureDetector(
          onTap: () {
            // navigateToDay(
            //   context,
            //   listOfDays[index],
            //   attendanceSheetMap,
            //   widget.courseName,
            //   widget.isolateInterpreter,
            //   widget.faceDetector,
            //   widget.cameras,
            //   widget.interpreter,
            // );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 60,
              width: 200,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(colors: [
                    ColorConst.lightButtonColor,
                    ColorConst.darkButtonColor
                  ])),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      studentList![index]['name'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    // const Icon(
                    //   Icons.arrow_forward,
                    //   color: Colors.white,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget add(BuildContext context, GetAStudentNotifier studentController,GlobalKey<FormState> formKey,) {
    return Padding(
      padding: const EdgeInsets.only(right: 30, bottom: 50),
      child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () async {

            showDialog(
              context: context,
              builder: (BuildContext context) {
                TextEditingController rollController = TextEditingController();

                return AlertDialog(
                  title: const Text('Add a Student'),
                  contentPadding:
                  const EdgeInsets.all(24), // Adjust padding for bigger size
                  content: Form(
                    key: formKey,
                    // mainAxisSize: MainAxisSize.min,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: rollController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter roll of student',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a valid roll number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          // Validation passed, proceed with saving

                          // Perform save operation or any other logic here
                          // attendanceController.manualAttend(attended,
                          //     nameController.text.trim(), courseName, day);

                          // studentController.getAStudent(widget.examId,rollController.text.toString());
                          getAStudent(studentController, rollController.text.toString());
                          // if(){}


                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add)),
    );
  }

  Future<void> getAStudent(GetAStudentNotifier studentController,String rollNumber)async{
   await studentController.getAStudent(widget.examId,rollNumber);
  }






}
