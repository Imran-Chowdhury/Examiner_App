import 'dart:typed_data';
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

  ConfirmScreen({
    Key? key,
    required this.examId,
    required this.originalName,
    required this.originalRollNumber,
    // required this.originalSession,
    required this.originalSemester,
    required this.uint8list,
    required this.studentData,
  }) : super(key: key);

  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  @override
  Widget build(BuildContext context) {

    final String examId;
    final String originalName;
    final String originalRollNumber;
    // final String originalSession;
    final String originalSemester;
    final List<int> uint8list;


    // Convert List<int> to Uint8List for Image.memory
    final Uint8List imageBytes = Uint8List.fromList(widget.uint8list);
    AttendanceNotifier attendanceController = ref.watch(attendanceProvider(widget.examId).notifier);
    final attendanceState = ref.watch(attendanceProvider(widget.examId));
    List<dynamic>? attendedList;
    if(attendanceState is AsyncData){
      attendedList = attendanceState.value;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Image
            Center(
              child: Image.memory(
                imageBytes,
                width: 112.0,
                height: 112.0,
                // fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            // Display Text
            Text('Name: ${widget.originalName}', style: TextStyle(color:Colors.white70, fontSize: 18)),
            Text('Roll Number: ${widget.originalRollNumber}', style: TextStyle(color:Colors.white70, fontSize: 18)),

            // Text('Session: ${widget.originalSession}', style: TextStyle(fontSize: 18)),

            Text('Semester: ${widget.originalSemester}', style: TextStyle(color:Colors.white70, fontSize: 18)),
            Spacer(),
            // Confirm Button
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  // Add action for confirm button
                  attend(attendanceController, attendedList);
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => ExamScreen(),
                  //   ),
                  //       (Route<dynamic> route) => false, // This will remove all previous routes
                  // );
                  Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
                  Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen



                },
                child: Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> attend(AttendanceNotifier attendanceController, List<dynamic>? attendedList)async{
  await  attendanceController.markAttendance(attendedList, widget.examId, widget.studentData);
  }
}




