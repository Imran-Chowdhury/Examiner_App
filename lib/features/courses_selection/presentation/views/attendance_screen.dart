

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:face_roll_teacher/core/utils/customFab.dart';
import 'package:face_roll_teacher/core/utils/studentCard.dart';
import 'package:face_roll_teacher/features/courses_selection/presentation/riverpod/exam_riverpod.dart';
import 'package:face_roll_teacher/features/courses_selection/presentation/views/student_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_screen.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../riverpod/attendance_riverpod.dart';


class AttendanceScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AttendanceScreen> createState() => _StudentScreenState();

   AttendanceScreen({
    super.key,

    required this.day,
    required this.courseName,
    required this.isolateInterpreter,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,
    required this.examId,
    required this.semesterId,
    required this.room,
  });


  String day;
  String courseName;

  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;
  final String examId;
  final String semesterId;
  String room;

}

// 2. extend [ConsumerState]
class _StudentScreenState extends ConsumerState<AttendanceScreen> {
  List<dynamic>? attended;
  late List<dynamic> allStudent;
  List<dynamic>? cachedStudentList;
  String presentDate = "";

  @override
  void initState() {
    Future.microtask(() => ref.read(attendanceProvider(widget.examId).notifier).getAttendedStudents(widget.examId));
    getStudentList(widget.examId);
    // printAllSharedPreferences();
    DateTime now = DateTime.now();
    presentDate = DateFormat('yyyy-MM-dd').format(now);
    super.initState();
  }

  Future<void> printAllSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get all the keys
    Set<String> keys = prefs.getKeys();

    // Loop through the keys and print each key-value pair
    for (String key in keys) {
      var value = prefs.get(key);
      print('Key: $key, Value: $value');
    }
  }


// Function to retrieve the list from shared preferences using the examId as the key
  Future<void> getStudentList(String examId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string using the examId as the key
    String? encodedStudentList = prefs.getString(examId);

    // If no data found, return null
    if (encodedStudentList == null) {
      Fluttertoast.showToast(msg: 'Select a proper range');
    }else{
      // Decode the JSON string back to a list of students
      allStudent = jsonDecode(encodedStudentList);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    String family = widget.examId;
    final detectController = ref.watch(faceDetectionProvider(family).notifier);
    final recognizeController = ref.watch(recognizeFaceProvider(family).notifier);




    // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    var attendanceState = ref.watch(attendanceProvider(family));
    AttendanceNotifier attendanceController = ref.watch(attendanceProvider(family).notifier);


    ref.listen<AsyncValue<List<dynamic>?>>(getAStudentProvider(widget.examId), (previous, next) {
      next.when(
        data: (students) async {

          if(students!.isEmpty){
            Fluttertoast.showToast(msg:'An Error Occurred');
          }else{
            allStudent = students;
          }

        },
        error: (error, stackTrace) {
          Fluttertoast.showToast(msg: 'Error: $error');
        },
        loading: () => const Center(child: CircularProgressIndicator()),


      );
    });

    ref.listen<AsyncValue<List<dynamic>>>(examsDetailsProvider(widget.examId), (previous, next) {
      next.when(
        data: (students) async {
          if(students.isEmpty){
            Fluttertoast.showToast(msg:'Please select the correct range');
          }else{
            allStudent = students;
            Fluttertoast.showToast(msg:'Synced');
          }


        },
        error: (error, stackTrace) {
          Fluttertoast.showToast(msg: 'Error: $error');
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        // loading: (){}
      );
    });


   void displayAllStudents(List<dynamic>? studentList){
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => TotalStudentScreen(
             studentList: studentList,
             examId: widget.examId)
       ),
     );
   }

    return Scaffold(
      floatingActionButton: (presentDate==widget.day)? CustomFab(
          onPressed: () {
            goToLiveFeedScreen(
              context,
              detectController,
              'Total Students',
              cachedStudentList,
              widget.day,
              family,
              recognizeController,
              allStudent,
            );
          },
            icon:Icons.camera_alt) : null,

      appBar: AppBar(
        title: Text(
          widget.courseName,
          style: const TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: showRangeDialog, icon: const Icon(Icons.download)),
          IconButton(onPressed: () {
            displayAllStudents(allStudent);
          }, icon: const Icon(Icons.list_alt_outlined)),
        ],
      ),

      body: Stack(
        children: [

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              Center(
                child: CircleAvatar(
                  radius: screenWidth*0.14, // Adjust the radius as per your need
                  backgroundImage: const AssetImage('assets/face_attendance.png'),
                  backgroundColor: Colors.transparent, // Optional: Make the background transparent
                ),
              ),
              Center(
                child: Text(
                  'Date - ${widget.day}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: screenWidth * 0.01),

              Center(
                child:Text(
                  'Room: ${widget.room}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ) ,
              ),
              const SizedBox(height: 20),

              Expanded(
                child: attendanceState.when(
                  data: (studentList) {
                    if (studentList!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Sync and Start Attending Students',
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                      );
                    }

                    // Cache the successfully loaded student list
                    cachedStudentList = studentList;

                    // Display the list of attended students
                    return listOfAttendedStudents(studentList, attendanceController);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) {
                    if (cachedStudentList != null && cachedStudentList!.isNotEmpty) {

                      return listOfAttendedStudents(cachedStudentList, attendanceController);

                    } else {
                      return const Center(
                        child: Text(
                          'No Data Available',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

            ],
          ),
        ],
      ),
    );
  }

  Widget listOfAttendedStudents(
    List<dynamic>? attendedList,
    AttendanceNotifier attendanceController,
  ) {
    return ListView.builder(
      itemCount: attendedList?.length,
      itemBuilder: (context, index) {
        String roll =  attendedList![index]['student'].toString();
        String name = attendedList[index]['name'];

        return GestureDetector(

          child: studentCard(name, roll,() {
            showDeleteOption(context, name,roll,widget.examId, attendanceController, attendedList,);
          }, ),

        );
      },
    );
  }

  Future<void> goToLiveFeedScreen(
    BuildContext context,
    FaceDetectionNotifier detectController,
    fileName,
    List<dynamic>? attended,
    String day,
    String family,
    RecognizeFaceNotifier recognizeController,
    List<dynamic> allStudent
  ) async {
    List<CameraDescription> cameras = await availableCameras();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveFeedScreen(
          examId: widget.examId,
          isolateInterpreter: widget.isolateInterpreter,
          // detectionController: detectController,
          faceDetector: widget.faceDetector,
          cameras: cameras,
          interpreter: widget.interpreter,
          studentFile: fileName,
          family: family,
          nameOfScreen: 'Course',
          day: day,
          courseName: widget.courseName,
          allStudent: allStudent,
          attended: attended,
        ),
      ),
    );
  }




  Widget add(
      BuildContext context,
      GlobalKey<FormState> formKey,
      AttendanceNotifier attendanceController,
      List<dynamic>? attended,
      String day,
      String courseName) {
    return IconButton(
      icon: const Icon(
        Icons.person_add,
        color: Colors.white,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController nameController = TextEditingController();

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
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter name of student',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name to add';
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
    );
  }

  void showDeleteOption(
      BuildContext context,
      String name,
      String rollNumber,
      String examId,
      AttendanceNotifier attendanceController,
      List<dynamic>? attended,
      ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete $name?'),
          content: Text('Are you sure you want to delete $name-$rollNumber?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                attendanceController.removeStudent(attended, rollNumber, examId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showRangeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return RangeDialog(
          initialMinRoll: 1,   // Optional initial values (if needed)
          initialMaxRoll: 100, // Optional initial values (if needed)
          onConfirm: (int minRoll, int maxRoll) async{
            // Handle the logic when the range is set
          await ref.watch(examsDetailsProvider(widget.examId).notifier)
                .getStudentsByRange(widget.examId,widget.semesterId, minRoll.toString(), maxRoll.toString());

            // Save the range or fetch the student data here
          },
        );
      },
    );
  }
}





class RangeDialog extends StatefulWidget {
  final Function(int minRoll, int maxRoll) onConfirm; // Function to call on OK

  final int initialMinRoll;
  final int initialMaxRoll;

  const RangeDialog({
    super.key,
    required this.onConfirm,
    this.initialMinRoll = 0, // Optional initial values
    this.initialMaxRoll = 0,
  });

  @override
  _RangeDialogState createState() => _RangeDialogState();
}

class _RangeDialogState extends State<RangeDialog> {
  late TextEditingController _minRollController;
  late TextEditingController _maxRollController;

  @override
  void initState() {
    super.initState();
    // Initialize text controllers with the passed initial values
    _minRollController = TextEditingController(text: widget.initialMinRoll.toString());
    _maxRollController = TextEditingController(text: widget.initialMaxRoll.toString());
  }

  @override
  void dispose() {
    // Clean up controllers when widget is removed
    _minRollController.dispose();
    _maxRollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:const Text('Set Range of Roll Numbers'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _minRollController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minimum Roll Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _maxRollController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Maximum Roll Number',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dismiss dialog on Cancel
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Extract the entered roll numbers
            int minRoll = int.parse(_minRollController.text);
            int maxRoll = int.parse(_maxRollController.text);
            widget.onConfirm(minRoll, maxRoll); // Call the function with entered values
            Navigator.of(context).pop(); // Dismiss dialog on OK
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

