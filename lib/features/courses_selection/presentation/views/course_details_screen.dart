import 'package:camera/camera.dart';
import 'package:face_roll_teacher/core/utils/customFab.dart';
 import 'package:face_roll_teacher/core/utils/nameCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../riverpod/course_details_riverpod.dart';
import 'attendance_screen.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;


class CourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String semesterId;
  final String courseName;

  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;
  final tf_lite.Interpreter livenessInterpreter;
   final  tf_lite.IsolateInterpreter livenessIsolateInterpreter;


   CourseDetailsScreen({
     required this.courseId,
     required this.semesterId, required this.courseName,
     required this.isolateInterpreter,
     required this.faceDetector,
     required this.cameras,
     required this.interpreter,
   required this.livenessInterpreter,
     required this.livenessIsolateInterpreter
   });

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}


class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the exams as soon as the screen is initialized

    Future.microtask(() => ref.read(examsProvider(widget.courseId).notifier).getExams(widget.courseId));
  }

  @override
  Widget build(BuildContext context) {
    // Fetch exams based on the courseId

    final examsAsync = ref.watch(examsProvider(widget.courseId));

    ref.listen<AsyncValue<String>>(deleteExamProvider, (previous, next) {
      next.when(
        data: (message) async {
          Fluttertoast.showToast(msg:message);
          await ref.refresh(examsProvider(widget.courseId).notifier).getExams(widget.courseId); // Refresh exams
        },
        error: (error, stackTrace) {
          Fluttertoast.showToast(msg: 'Error: $error');
        },
          loading: () => const Center(child: CircularProgressIndicator()),
      );
    });

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;


    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.courseName,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: examsAsync.when(

      data: (exams) {
        if (exams == null || exams.isEmpty) {
          return Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children: [
          Center(
          child: Container(
          height: screenHeight*0.24, //80
            width: screenWidth*0.8, //180
            decoration:const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/exam.png',
                ),
                fit: BoxFit.fill,
              ),
              shape: BoxShape.rectangle,
            ),
          ),
        ),
           SizedBox(
             height: screenHeight*.01,
           ),
           const Text(
              "Add new exams!",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],);
        }

        return listOfExams(exams);


      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
              ),
      floatingActionButton: CustomFab(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddExamDialog(
              courseId: widget.courseId,
              semesterId: widget.semesterId,
            ),
          );
        },
        icon:Icons.library_add,
      ),
    );
  }


  void _showDeleteDialog(BuildContext context, String examId, String courseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: const Text('Are you sure you want to delete this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Call the delete function
              await ref.read(deleteExamProvider.notifier).deleteExam(courseId, examId);
              Navigator.of(context).pop(); // Close the dialog


            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }



  Widget listOfExams(List<dynamic>? exams) {
    return ListView.builder(
      itemCount: exams?.length,
      itemBuilder: (context, index) {

        return GestureDetector(
          onLongPress: (){
            _showDeleteDialog(context, exams[index]['id'].toString(), widget.courseId);

          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceScreen(
                  day: exams[index]['exam_date'],
                  courseName: widget.courseName,
                  interpreter: widget.interpreter,
                  isolateInterpreter: widget.isolateInterpreter,
                  // livenessIsolateInterpreter: widget.livenessIsolateInterpreter,
                  cameras: widget.cameras,
                  faceDetector: widget.faceDetector,
                  semesterId: widget.semesterId,
                  examId: exams[index]['id'].toString(),
                  room:exams[index]['room'].toString(),
                  livenessIsolateInterpreter: widget.livenessIsolateInterpreter,
                  livenessInterpreter: widget.livenessInterpreter,

                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: NameCard(
              name:exams![index]['exam_date'].toString(),
              details: 'Room: ${exams[index]['room'].toString()}',
              color: const Color(0xFF9BCFAF),
              icon: Icons.calendar_month,
            ),

          ),
        );
      },
    );
  }
}



class AddExamDialog extends ConsumerStatefulWidget {
  final String courseId;
  final String semesterId;

  const AddExamDialog({super.key, required this.courseId, required this.semesterId});

  @override
  _AddExamDialogState createState() => _AddExamDialogState();
}

class _AddExamDialogState extends ConsumerState<AddExamDialog> {
  final TextEditingController _dateController = TextEditingController();
  String? _selectedRoom;
  final rooms = List.generate(6, (index) => 'Room ${index + 1}'); // Rooms 1 to 6


  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }


  Future<void> _selectDate(BuildContext context) async {
    // Get the current date
    DateTime now = DateTime.now();

    // Show the DatePicker dialog
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    // Check if the user selected a date
    if (picked != null) {
      // Format the picked date and the current date to 'yyyy-MM-dd' format
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      final presentDate = DateFormat('yyyy-MM-dd').format(now);

      // Compare the picked date with the present date
      if (formattedDate.compareTo(presentDate) < 0) {
        // If the picked date is in the past, show an "Invalid Date" toast
        Fluttertoast.showToast(
          msg: 'Invalid Date',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        // If the picked date is valid (today or in the future), update the TextFormField
        setState(() {
          _dateController.text = formattedDate;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final addExamState = ref.watch(addExamProvider);

    return AlertDialog(
      title: const Text('Add New Exam'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: 'Exam Date',
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          DropdownButton<String>(
            value: _selectedRoom,
            hint: const Text(
                'Select Room',
              style: TextStyle(
                fontSize: 16, // Match font size with text field
                fontWeight: FontWeight.normal, // Set to normal to avoid bold effect
                color: Colors.black, // Set color to match text field
              ),
            ),
            isExpanded: true,
            items: rooms.map((room) {
              return DropdownMenuItem<String>(
                value: room,
                child: Text(room),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRoom = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text('Cancel'),
        ),

        if (addExamState is AsyncLoading) const CircularProgressIndicator(),
        if (addExamState is! AsyncLoading)
          TextButton(
            onPressed: () async {
              if (_dateController.text.isNotEmpty && _selectedRoom != null) {
                final roomId = rooms.indexOf(_selectedRoom!) + 1; // Room ID is 1 to 6
                final examData = {
                  'exam_date': _dateController.text,
                };

                await ref
                    .read(addExamProvider.notifier)
                    .addExam( widget.semesterId,widget.courseId, roomId.toString(), examData);

                if(addExamState is AsyncData){
                  await ref.refresh(examsProvider(widget.courseId).notifier).getExams(widget.courseId);
                }

              if(addExamState is AsyncError){
                Fluttertoast.showToast(msg: addExamState.value);
              }

                Navigator.pop(context); // Close dialog
              }
            },
            child: const Text('Submit'),
          ),
      ],
    );
  }
}
