import 'dart:typed_data';
import 'package:face_roll_teacher/core/utils/background_widget.dart';
import 'package:face_roll_teacher/core/utils/customButton.dart';
import 'package:face_roll_teacher/features/courses_selection/presentation/riverpod/attendance_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'attendance_screen.dart';

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

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;




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
        style: const TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold),
      ),
        // iconTheme: const IconThemeData(color: Colors.white),
        // elevation: 20,
        // backgroundColor: const Color.fromARGB(255, 101, 123, 120),
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
          // const BackgroundContainer(),
          Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display Image
            const SizedBox(height: 20,),
            // CircleAvatar(
            //   radius: 100.0, // Controls the size of the avatar
            //   // backgroundColor: Colors.white, // White space around the image
            //   backgroundColor: Colors.black, // Black space around the image
            //   child: ClipOval(
            //     child: SizedBox(
            //       width: 112, // The actual width of your image
            //       height: 112, // The actual height of your image
            //       child: Image.memory(
            //         imageBytes,
            //         fit: BoxFit.contain, // Ensures the image is not stretched
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 50 ,),
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
            Text('Name: ${widget.originalName}', style: TextStyle(color:Colors.black, fontSize: 22)),
            SizedBox(height: 20),
            Text('Roll Number: ${widget.originalRollNumber}', style: TextStyle(color:Colors.black, fontSize: 22)),
            SizedBox(height: 20),
            // Text('Session: ${widget.originalSession}', style: TextStyle(fontSize: 18)),

            Text('Semester: ${widget.originalSemester}', style: const TextStyle(color:Colors.black, fontSize: 22)),
            SizedBox(height: 100),
            // Confirm Button
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [



                  // CustomButton(screenHeight: screenHeight,
                  //     buttonName: 'Cancel',
                  //     onpressed: () {
                  //
                  //
                  //       Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
                  //       Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen
                  //
                  //     },
                  //     icon: const Icon(
                  //         Icons.cancel,
                  //       color: Colors.white,
                  //       size: 40,
                  //     )),
                  //


                   // SizedBox(width: 20,),

                  // CustomButton(
                  //     onpressed: () {
                  //   // Add action for confirm button
                  //   if(attendedList!=null){
                  //     attend(attendanceController, attendedList);
                  //   }else{
                  //     attend(attendanceController, widget.attended);
                  //   }
                  //
                  //   // attend(attendanceController, attendedList);
                  //   Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
                  //   Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen
                  //
                  // },
                  //     buttonName: 'Ok', icon:
                  //    const Icon(
                  //      Icons.check_box,
                  //      color: Colors.white,
                  //    size: 40,),
                  //   screenHeight: screenHeight,
                  // ),
                  IconButton(
                    icon: Icon(
                        size: 80,
                        Icons.cancel,
                        color: Colors.red), // Red cancel icon
                        onPressed: () {


                          Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
                          Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen

                        }, // Trigger the passed function when pressed
                      ),

                  SizedBox(width: 20,),
                  IconButton(
                    icon: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      size: 80,
                    ), // Green check icon
                    onPressed: () {
                      // Add action for confirm button
                      if(attendedList!=null){
                        attend(attendanceController, attendedList);
                      }else{
                        attend(attendanceController, widget.attended);
                      }

                      // attend(attendanceController, attendedList);
                      Navigator.pop(context); // First pop goes back from ConfirmScreen to LiveFeedScreen
                      Navigator.pop(context); // Second pop goes back from LiveFeedScreen to ExamScreen

                    }, // Trigger the passed function when pressed
                  ),
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




