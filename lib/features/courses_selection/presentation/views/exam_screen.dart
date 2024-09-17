

import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:face_roll_teacher/features/courses_selection/presentation/riverpod/exam_riverpod.dart';
import 'package:face_roll_teacher/features/courses_selection/presentation/views/student_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;



import '../../../../core/constants/constants.dart';
import '../../../../core/utils/background_widget.dart';
import '../../../../core/utils/customButton.dart';
import '../../../face_detection/presentation/riverpod/face_detection_provider.dart';
import '../../../live_feed/presentation/views/live_feed_screen.dart';
import '../../../recognize_face/presentation/riverpod/recognize_face_provider.dart';
import '../riverpod/attendance_riverpod.dart';

// ignore: must_be_immutable
class StudentScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<StudentScreen> createState() => _StudentScreenState();

   StudentScreen({
    super.key,
    // required this.attendedStudentsMap,
    required this.day,
    required this.courseName,
    required this.isolateInterpreter,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,
    required this.examId,
    required this.semesterId,
  });

  // Map<String, List<dynamic>> attendedStudentsMap;
  String day;
  String courseName;

  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;
  final String examId;
  final String semesterId;

  // List<String> attendedStudentsList;
}

// 2. extend [ConsumerState]
class _StudentScreenState extends ConsumerState<StudentScreen> {
  List<dynamic>? attended;
  late List<dynamic> allStudent;
  List<dynamic>? cachedStudentList;
  @override
  void initState() {
    Future.microtask(() => ref.read(attendanceProvider(widget.examId).notifier).getAttendedStudents(widget.examId));
    getStudentList(widget.examId);
    printAllSharedPreferences();
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
      print(allStudent);
    }



    // return studentList;
  }

  @override
  Widget build(BuildContext context) {
    // Constants constant = Constants();
    String family = widget.examId;
    final detectController = ref.watch(faceDetectionProvider(family).notifier);
    final recognizeController = ref.watch(recognizefaceProvider(family).notifier);
    var studentState = ref.watch(getAStudentProvider(widget.examId));
    var examDetailsState = ref.watch(examsDetailsProvider(widget.examId));



    // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    var attendanceState = ref.watch(attendanceProvider(family));
    AttendanceNotifier attendanceController =
        ref.watch(attendanceProvider(family).notifier);






    ref.listen<AsyncValue<List<dynamic>?>>(getAStudentProvider(widget.examId), (previous, next) {
      next.when(
        data: (students) async {

          if(students!.isEmpty){
            Fluttertoast.showToast(msg:'An Error Occurred');
          }else{
            allStudent = students;
            // Fluttertoast.showToast(msg:'Student List Updated');
          }

        },
        error: (error, stackTrace) {
          Fluttertoast.showToast(msg: 'Error: $error');
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        // loading: () {}

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
          print('The students list is $students');

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
         builder: (context) => CourseScreen(
             // courseName: courseName,
             // semesterId: semesterId,
             studentList: studentList,
             examId: widget.examId)
       ),
     );
   }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              widget.courseName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 20,
          backgroundColor: const Color.fromARGB(255, 101, 123, 120),
          actions: [
            IconButton(onPressed: showRangeDialog, icon: const Icon(Icons.download)),
            IconButton(onPressed: () {
              displayAllStudents(allStudent);
            }, icon: const Icon(Icons.list_alt_outlined)),
          ],
        ),
        body: Stack(
          children: [
            const BackgroudContainer(),
            Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Date - ${widget.day}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 20),

                // Wrapping the `Expanded` widget properly in the `Column` structure
                Expanded(
                  child: attendanceState.when(
                    data: (studentList) {
                      if (studentList!.isEmpty) {
                        return const Center(
                          child: Text(
                            'Sync and Start Attending Students',
                            style: TextStyle(color: Colors.white70, fontSize: 18),
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
                        Fluttertoast.showToast(msg: "Error: $error");
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

                CustomButton(
                  onPressed: () {
                    goToLiveFeedScreen(
                      context,
                      detectController,
                      'Total Students',
                      attended,
                      widget.day,
                      family,
                      recognizeController,
                      allStudent,
                    );
                  },
                  buttonName: 'Attend',
                  icon: const Icon(Icons.add_a_photo),
                ),
              ],
            ),
          ],
        ),
      ),
    );


    //   SafeArea(
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Center(
    //         child: Text(
    //           widget.courseName,
    //           style: const TextStyle(
    //               color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
    //         ),
    //       ),
    //       iconTheme: const IconThemeData(color: Colors.white),
    //       elevation: 20,
    //       backgroundColor: const Color.fromARGB(255, 101, 123, 120),
    //       actions: [
    //         IconButton(onPressed: showRangeDialog, icon: const Icon(Icons.download)),
    //         IconButton(onPressed: (){
    //           displayAllStudents(allStudent);} , icon: const Icon(Icons.list_alt_outlined))
    //       ],
    //     ),
    //     body: Stack(
    //       children: [
    //         const BackgroudContainer(),
    //         Column(
    //           children: [
    //             const SizedBox(height: 20),
    //             Center(
    //               child: Text(
    //                 'Date - ${widget.day}',
    //                 style: const TextStyle(
    //                     color: Colors.white,
    //                     fontSize: 20,
    //                     fontWeight: FontWeight.w500),
    //               ),
    //             ),
    //             const SizedBox(height: 20),
    //
    //             // Attendance data, loading spinner or error message displayed here
    //             Expanded(
    //               child: attendanceState.when(
    //                 data: (studentList) {
    //                   if (studentList!.isEmpty) {
    //                     return const Center(
    //                       child: Text(
    //                         'Sync and Start Attending Students',
    //                         style: TextStyle(color: Colors.white70, fontSize: 18),
    //                       ),
    //                     );
    //                   }
    //
    //                   // Cache the successfully loaded student list
    //                   cachedStudentList = studentList;
    //
    //                   // return ListView.builder(
    //                   //   itemCount: studentList.length,
    //                   //   itemBuilder: (context, index) {
    //                   //     return ListTile(
    //                   //       onLongPress: () {
    //                   //         // You can add a dialog or any action here
    //                   //       },
    //                   //       onTap: () {
    //                   //         // You can add navigation or other logic here
    //                   //       },
    //                   //       title: Text(
    //                   //         studentList[index]['student'].toString(),
    //                   //         style: const TextStyle(color: Colors.white70),
    //                   //       ),
    //                   //       subtitle: Text(
    //                   //         studentList[index]['name'],
    //                   //         style: const TextStyle(color: Colors.white70),
    //                   //       ),
    //                   //     );
    //                   //   },
    //                   // );
    //
    //                   return listOfAttendedStudents(studentList,attendanceController);
    //                 },
    //                 loading: () => const Center(
    //                   child: CircularProgressIndicator(),
    //                 ),
    //                 error: (error, stack) {
    //                   // Show the previous cached data if available
    //                   if (cachedStudentList != null && cachedStudentList!.isNotEmpty) {
    //                     // Show a toast message for the error
    //                     Fluttertoast.showToast(
    //                       msg: "Error: $error",
    //
    //                     );
    //                     return listOfAttendedStudents(cachedStudentList,attendanceController);
    //                     // return ListView.builder(
    //                     //   itemCount: cachedStudentList!.length,
    //                     //   itemBuilder: (context, index) {
    //                     //     return ListTile(
    //                     //       title: Text(
    //                     //         cachedStudentList![index]['student'].toString(),
    //                     //         style: const TextStyle(color: Colors.white70),
    //                     //       ),
    //                     //       subtitle: Text(
    //                     //         cachedStudentList![index]['name'],
    //                     //         style: const TextStyle(color: Colors.white70),
    //                     //       ),
    //                     //     );
    //                     //   },
    //                     // );
    //                   } else {
    //                     // If there's no cached data, show an empty state or message
    //                     return const Center(
    //                       child: Text(
    //                         'No Data Available',
    //                         style: TextStyle(color: Colors.white70, fontSize: 18),
    //                       ),
    //                     );
    //                   }
    //                 },
    //               ),
    //             ),
    //
    //             const SizedBox(height: 20),
    //             // Check for loading states of student data and exam details
    //             // if (studentState is AsyncLoading || examDetailsState is AsyncLoading)
    //             //   const Center(child: CircularProgressIndicator()),
    //
    //
    //
    //             CustomButton(
    //               onPressed: () {
    //                 goToLiveFeedScreen(
    //                   context,
    //                   detectController,
    //                   'Total Students',
    //                   attended,
    //                   widget.day,
    //                   family,
    //                   recognizeController,
    //                   allStudent,
    //                 );
    //               },
    //               buttonName: 'Attend',
    //               icon: const Icon(Icons.add_a_photo),
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // );

  }

  Widget listOfAttendedStudents(
    List<dynamic>? attendedList,
    AttendanceNotifier attendanceController,
    // List<dynamic>? attended,
    // String day,
    // String courseName,
  ) {
    return ListView.builder(
      itemCount: attendedList?.length,
      itemBuilder: (context, index) {
        String roll =  attendedList![index]['student'].toString();
        String name = attendedList[index]['name'];
        print('The attended students are $attendedList');
        return GestureDetector(
          onLongPress: () {
            showDeleteOption(context, name,roll,widget.examId, attendanceController, attendedList,);
          },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            leading: Container(
              padding: const EdgeInsets.only(right: 12.0),
              decoration: const BoxDecoration(
                  border: Border(
                      right: BorderSide(width: 1.0, color: Colors.white24))),
              child: const Icon(Icons.person_2_outlined, color: Colors.white),
            ),
            title: Text(
              roll,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle:  Row(
              children: <Widget>[
               const Icon(Icons.linear_scale, color: ColorConst.darkButtonColor),
                Text(name, style: const TextStyle(color: Colors.white))
              ],
            ),
            // trailing: const Icon(Icons.keyboard_arrow_right,
            //     color: Colors.white, size: 30.0),
          ),
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
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
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
          // livenessInterpreter: livenessInterpreter,
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
                      // Validation passed, proceed with saving

                      // Perform save operation or any other logic here
                      // attendanceController.manualAttend(attended,
                      //     nameController.text.trim(), courseName, day);

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
                // Perform delete operation here
                // attendanceController.deleteName(
                //     attended, name, widget.courseName, day);
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
            print('Selected Range: $minRoll to $maxRoll');
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
    Key? key,
    required this.onConfirm,
    this.initialMinRoll = 0, // Optional initial values
    this.initialMaxRoll = 0,
  }) : super(key: key);

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

