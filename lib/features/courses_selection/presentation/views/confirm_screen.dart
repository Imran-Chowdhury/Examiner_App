import 'dart:typed_data';
import 'package:face_roll_teacher/core/utils/background_widget.dart';
import 'package:face_roll_teacher/core/utils/customButton.dart';
import 'package:face_roll_teacher/features/courses_selection/presentation/riverpod/attendance_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exam_screen.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  final String examId;
  final String originalName;
  final String originalRollNumber;
  // final String originalSession;
  final String originalSemester;
  final List<int> uint8list;
  Map<String,dynamic> studentData;
  List<dynamic>? attended;

  ConfirmScreen({
    Key? key,
    required this.examId,
    required this.originalName,
    required this.originalRollNumber,
    // required this.originalSession,
    required this.originalSemester,
    required this.uint8list,
    required this.studentData,
    required this.attended,
  }) : super(key: key);

  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  @override
  Widget build(BuildContext context) {




    // Convert List<int> to Uint8List for Image.memory
    final Uint8List imageBytes = Uint8List.fromList(widget.uint8list);
    AttendanceNotifier attendanceController = ref.watch(attendanceProvider(widget.examId).notifier);
    final attendanceState = ref.watch(attendanceProvider(widget.examId));
    List<dynamic>? attendedList;

    if(attendanceState is AsyncData){
      attendedList = attendanceState.value;
    }

    print('The attended list printing from the Confirm screen is ${widget.attended}');

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Confirm Details',
          style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 20,
        backgroundColor: const Color.fromARGB(255, 101, 123, 120),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Custom back button icon
          onPressed: () {
            Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
            Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen


          },
        ),
      ),
      body: Stack(
        children: [
          const BackgroundContainer(),
          Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display Image
            const SizedBox(height: 20,),
            Center(
              child: Image.memory(
                imageBytes,
                width: 202.0,
                height: 202.0,
                // fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            // Display Text
            Text('Name: ${widget.originalName}', style: TextStyle(color:Colors.white70, fontSize: 22)),
            SizedBox(height: 20),
            Text('Roll Number: ${widget.originalRollNumber}', style: TextStyle(color:Colors.white70, fontSize: 22)),
            SizedBox(height: 20),
            // Text('Session: ${widget.originalSession}', style: TextStyle(fontSize: 18)),

            Text('Semester: ${widget.originalSemester}', style: const TextStyle(color:Colors.white70, fontSize: 22)),
            SizedBox(height: 250),
            // Confirm Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  CustomButton(
                      onPressed: () {
                        // Add action for confirm button
                        // attend(attendanceController, attendedList);

                        Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
                        Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen



                      },
                      buttonName: '',
                      icon: const Icon(Icons.cancel)),


                  const SizedBox(width: 80,),

                  CustomButton(onPressed: () {
                    // Add action for confirm button
                    if(attendedList!=null){
                      attend(attendanceController, attendedList);
                    }else{
                      attend(attendanceController, widget.attended);
                    }

                    // attend(attendanceController, attendedList);
                    Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
                    Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen



                  },
                      buttonName: '',
                      icon: const Icon(Icons.check_box)),
                ],
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
  Future<void> attend(AttendanceNotifier attendanceController, List<dynamic>? attendedList)async{
  await  attendanceController.markAttendance(attendedList, widget.examId, widget.studentData);
  }
}




