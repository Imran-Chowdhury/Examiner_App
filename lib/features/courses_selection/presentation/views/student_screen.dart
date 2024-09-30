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
import 'attendance_screen.dart';

// ignore: must_be_immutable
class TotalStudentScreen extends ConsumerStatefulWidget {
  TotalStudentScreen({
    super.key,
    required this.studentList,
    required this.examId
  });


  List<dynamic>? studentList;
  final String examId;


  @override
  ConsumerState<TotalStudentScreen> createState() => _TotalStudentScreenState();
}

// 2. extend [ConsumerState]
class _TotalStudentScreenState extends ConsumerState<TotalStudentScreen> {



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


    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 30, bottom: 50),
        child:  SizedBox(
          width: 80.0,
          height: 80.0,
          child: FloatingActionButton(

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
                          child: const Text('Add'),
                        ),
                      ],
                    );
                  },
                );
            },
            elevation: 10.0,
            backgroundColor: const Color(0xFFB37BA4),
            shape: const CircleBorder(),
            child:  const Icon(Icons.library_add, size: 40.0,color: Colors.white,),
          ),
        ),
      ),
      appBar: AppBar(
        title:const  Text(
          'Student List',
          style:  TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        // iconTheme: const IconThemeData(color: Colors.white),
        // elevation: 20,
        // backgroundColor: const Color.fromARGB(255, 101, 123, 120),

      ),

      // floatingActionButton: add(context, studentController, formKey),
      // backgroundColor: const Color(0xFF3a3b45),
      body: Stack(
        children: [
          // const BackgroundContainer(),
          Column(
            children: [
              // const Padding(
              //   padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
              //   child: Center(
              //     child: Text(
              //       'Student List',
              //       style: TextStyle(
              //         fontSize: 24,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.black,
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
                    return listOfStudents(students);

                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    return listOfStudents(widget.studentList);
                  },
                ),
              ),


            ],
          ),
        ],
      ),
    );
  }




  Widget listOfStudents(List<dynamic>? studentList) {
    return ListView.builder(
        itemCount: studentList?.length,
        itemBuilder: (context, index) {

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20), // Padding on the sides only
          child: Column(
            children: [
              Row(
                children: [
                  // const Icon(Icons.check_circle, color: Color(0xFFB37BA4), size: 40), // Icon for present student
                  SizedBox(width: 16), // Space between icon and text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentList![index]['name'],

                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        studentList[index]['roll_number'].toString(),
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Spacer(), // Pushes the more_vert icon to the right// Icon on the right-hand side
                ],
              ),
              SizedBox(height: 8), // Space between the roll and divider
              Divider(
                color: Colors.black, // Black line as a divider
                thickness: 1, // Line thickness
              ),
            ],
          ),
        );


        //   ListTile(
        //
        //
        //   onTap: (){
        //
        //   },
        //   title: Text(
        //     studentList![index]['roll_number'].toString(),
        //     style: const TextStyle(color: Colors.black),
        //   ),
        //   subtitle: Text(
        //     studentList[index]['name'],
        //     style: const TextStyle(color: Colors.black),
        //   ),
        // );
      },
    );

  }

  Widget add(BuildContext context, GetAStudentNotifier studentController,GlobalKey<FormState> formKey,) {
    return Padding(
      padding: const EdgeInsets.only(right: 30, bottom: 50),
      child: FloatingActionButton(
          // backgroundColor: Colors.white,
          // shape: const CircleBorder(),
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
                      child: const Text('Add'),
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
