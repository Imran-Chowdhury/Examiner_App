import 'dart:convert';



import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/utils/background_widget.dart';
import '../../../../core/utils/courseButton.dart';
import '../../../train_face/presentation/views/home_screen.dart';

import 'course_selection_screen.dart';

// class CourseSelectionScreen extends ConsumerStatefulWidget {
//   @override
//   ConsumerState<CourseSelectionScreen> createState() =>
//       _CourseSelectionScreenState();

//   CourseSelectionScreen({
//     super.key,
//     // required this.attendedStudentsMap,
//     // required this.day,
//     required this.semester,
//     required this.isolateInterpreter,
//     required this.faceDetector,
//     required this.cameras,
//     required this.interpreter,
//   });

//   String semester;

//   final FaceDetector faceDetector;
//   late List<CameraDescription> cameras;
//   final tf_lite.Interpreter interpreter;
//   final tf_lite.IsolateInterpreter isolateInterpreter;
// }

// // 2. extend [ConsumerState]
// class _CourseSelectionScreenState extends ConsumerState<CourseSelectionScreen> {
//   Map<String, String>? courseMap = {};
//   List<dynamic>? courseList;

//   @override
//   void initState() {
//     super.initState();

//     fetchInitialData();
//   }

//   Future<void> fetchInitialData() async {
//     final attendance = await getCourseMap(widget.semester);
//     // final students = await getAllStudentsMap(constant.allStudent);

//     setState(() {
//       courseMap = attendance;
//       // mapOfStudents = students;
//     });
//     print('The attendance map is $courseMap');
//   }

//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     String family = widget.semester;
//     final courseController = ref.watch(courseProvider(family).notifier);
//     final courseState = ref.watch(courseProvider(family));

//     if (courseState is CourseSuccessState) {
//       // courseList = courseState.data;
//       courseMap = courseState.data;
//     }

//     return SafeArea(
//       child: Scaffold(
//         floatingActionButton: add(
//             context, _formKey, courseController, courseMap, widget.semester),
//         body: Stack(children: [
//           // Background color with transparency
//           const BackgroudContainer(),

//           // Main content

//           // courseMap!.isEmpty
//           //     ? const Center(
//           //         child: Text('No course added yet'),
//           //       )
//           //     :
//           Column(
//             // mainAxisAlignment: MainAxisAlignment.center,

//             children: [
//               const SizedBox(
//                 height: 20,
//               ),
//               (courseState is CourseSuccessState)
//                   ? listOfCourses(courseState.data, courseController)
//                   : listOfCourses(
//                       // courseList,
//                       courseMap,
//                       courseController,
//                     ),
//             ],
//           ),
//         ]),
//       ),
//     );
//   }

//   Widget listOfCourses(
//     Map<String, String>? courseMap,
//     CourseNotifier attendanceController,
//   ) {
//     List<String>? courseList = courseMap?.keys.toList();
//     List<String>? teacherList = courseMap?.values.toList();
//     return Expanded(
//       child: ListView.builder(
//         itemCount: courseMap!.length,
//         itemBuilder: (context, index) {
//           print(courseMap.keys);
//           String? courseName = courseList?[index];
//           String? teacherName = teacherList?[index];

//           return GestureDetector(
//             child: ListTile(
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//               leading: Container(
//                 padding: const EdgeInsets.only(right: 12.0),
//                 decoration: const BoxDecoration(
//                     border: Border(
//                         right: BorderSide(width: 1.0, color: Colors.white24))),
//                 child: const Icon(Icons.person_2_outlined, color: Colors.white),
//               ),
//               title: Text(
//                 // 'lalala',
//                 courseName!,
//                 // $map[index],
//                 style: const TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//               subtitle: Row(
//                 children: <Widget>[
//                   const Icon(Icons.linear_scale,
//                       color: ColorConst.darkButtonColor),
//                   Text(teacherName!,
//                       style: const TextStyle(color: Colors.white)),
//                 ],
//               ),
//               // trailing: const Icon(Icons.keyboard_arrow_right,
//               //     color: Colors.white, size: 30.0),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget add(
//       BuildContext context,
//       GlobalKey<FormState> formKey,
//       CourseNotifier courseController,
//       // List<dynamic>? courseList,
//       Map<String, String>? courseMap,
//       String semester) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 30, bottom: 50),
//       child: FloatingActionButton(
//           backgroundColor: Colors.white,
//           shape: const CircleBorder(),
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 TextEditingController courseNameController =
//                     TextEditingController();
//                 TextEditingController teacherNameController =
//                     TextEditingController();

//                 return AlertDialog(
//                   title: const Text('Add a Course'),
//                   contentPadding: const EdgeInsets.all(
//                       24), // Adjust padding for bigger size
//                   content: Form(
//                     key: formKey,
//                     // mainAxisSize: MainAxisSize.min,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         TextFormField(
//                           controller: courseNameController,
//                           decoration: const InputDecoration(
//                             hintText: 'Enter name of course',
//                           ),
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Please enter a course to add';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(
//                           height: 10,
//                         ),
//                         TextFormField(
//                           controller: teacherNameController,
//                           decoration: const InputDecoration(
//                             hintText: 'Enter name of course teacher',
//                           ),
//                           validator: (value) {
//                             if (value!.isEmpty) {
//                               return 'Please enter a name to add';
//                             }
//                             return null;
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   actions: <Widget>[
//                     TextButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: const Text('Cancel'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         if (formKey.currentState!.validate()) {
//                           // Validation passed, proceed with saving

//                           // Perform save operation or any other logic here
//                           courseController.addToCourseList(
//                               semester,
//                               teacherNameController.text.trim(),
//                               courseNameController.text.trim(),
//                               courseMap);
//                           // attendanceController.manualAttend(attended,
//                           //     courseNameController.text.trim(), semester, day);

//                           Navigator.of(context).pop();
//                         }
//                       },
//                       child: const Text('Save'),
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//           child: const Icon(Icons.add)),
//     );
//   }

//   // Future<void> initializeJsonFiles() async {
//   //   List<String> courses = ['Course 1', 'Course 2', 'Course 3', 'Course 4'];
//   //   final prefs = await SharedPreferences.getInstance();

//   //   for (String course in courses) {
//   //     if (prefs.getString(course) == null) {
//   //       prefs.setString(course, json.encode({}));
//   //     }
//   //   }
//   //   for (int i = 0; i < courses.length; i++) {
//   //     getJsonFromPrefs(courses[i]);
//   //   }
//   // }

//   // Future<void> initializeSemesterFiles() async {
//   //   List<String> semesters = [
//   //     'Semester 1',
//   //     'Semester 2',
//   //     'Semester 3',
//   //     'Semester 4',
//   //   ];
//   //   final prefs = await SharedPreferences.getInstance();

//   //   for (String semester in semesters) {
//   //     if (prefs.getString(semester) == null) {
//   //       prefs.setString(semester, json.encode({}));
//   //     }
//   //   }
//   //   for (int i = 0; i < semesters.length; i++) {
//   //     getJsonFromPrefs(semesters[i]);
//   //   }
//   // }

//   // Future<Map<String, dynamic>?> getJsonFromPrefs(String course) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   String? jsonString = prefs.getString(course);
//   //   if (jsonString != null) {
//   //     Map<String, dynamic> jsonData = json.decode(jsonString);
//   //     print('the map is $jsonData');
//   //     return jsonData;
//   //   }
//   //   return {
//   //     'map': 'null',
//   //   };
//   // }

//   // Future<void> saveJsonToPrefs(
//   //     String key, Map<String, dynamic> jsonData) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   String jsonString = json.encode(jsonData);
//   //   prefs.setString(key, jsonString);
//   // }

//   // Future<void> deleteAllJsonFiles() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   List<String> courses = ['Course 1', 'Course 2', 'Course 3', 'Course 4'];

//   //   for (String course in courses) {
//   //     await prefs.remove(course);
//   //   }
//   // }

//   // Future<void> loadKeys() async {
//   //   final prefs = await SharedPreferences.getInstance();

//   //   print(prefs.getKeys().toList());
//   // }

//   // Future<void> clearAllPrefs() async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   await prefs.clear();
//   //   print('All prefs deleted');
//   //   // Refresh the keys list after clearing
//   //   // _loadKeys();
//   // }

// // Future<void> navigateToCourses(
//   void navigateToCourses(
//       context,
//       String courseName,
//       tf_lite.IsolateInterpreter isolateInterpreter,
//       FaceDetector faceDetector,
//       List<CameraDescription> cameras,
//       tf_lite.Interpreter interpreter) async {
//     Navigator.push(
//       context,
//       // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
//       MaterialPageRoute(
//         builder: (context) => CourseScreen(
//           interpreter: interpreter,
//           isolateInterpreter: isolateInterpreter,
//           cameras: cameras,
//           faceDetector: faceDetector,
//           courseName: courseName,
//         ),
//       ),
//     );
//   }

//   List<dynamic>? mapToList(Map<String, String>? courseMap) {
//     // print('Lalalaa');
//     List? courseList = [];
//     try {
//       if (courseMap!.isNotEmpty) {
//         for (String key in courseMap.keys) {
//           //converting the json into a list of maps e.g [EEE-101,EEE-102]
//           courseList.add(key);
//           // courseList.add({key: courseMap[key]});
//         }
//         print(courseList);
//       } else {
//         courseList = [];
//       }
//     } catch (e) {
//       rethrow;
//     }
//     return courseList;
//   }

//   Future<Map<String, String>> getCourseMap(
//     String nameOfJsonFile,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     final jsonMap = prefs.getString(nameOfJsonFile);
//     if (jsonMap != null) {
//       final decodedMap = Map<String, String>.from(json.decode(jsonMap));
//       // final decodedMap = List<String>.from(json.decode(jsonMap));

//       // attendanceSheet = decodedMap;
//       //the decode map looks like this {EEE-101: MAAM, EEE-102:JUA}
//       print('The decoded courses are $courseMap');
//       return decodedMap;
//     } else {
//       return {};
//     }
//   }
// }




///////////////////////////////////////////////////////////////////////////////////////////////////
class SemesterSelectionScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SemesterSelectionScreen> createState() =>
      _SemesterSelectionScreenState();
}

// 2. extend [ConsumerState]
class _SemesterSelectionScreenState extends ConsumerState<SemesterSelectionScreen> {
  late FaceDetector faceDetector;
  late tf_lite.Interpreter interpreter;
  late tf_lite.IsolateInterpreter isolateInterpreter;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await loadModelsAndDetectors();
  }

  Future<void> loadModelsAndDetectors() async {
    // Load models and initialize detectors
    interpreter = await loadModel();
    isolateInterpreter =
        await IsolateInterpreter.create(address: interpreter.address);
    // livenessInterpreter = await loadLivenessModel();
    cameras = await availableCameras();

    // Initialize face detector
    final faceDetectorOptions = FaceDetectorOptions(
      minFaceSize: 0.2,
      performanceMode: FaceDetectorMode.accurate, // or .fast
    );
    faceDetector = FaceDetector(options: faceDetectorOptions);
  }

  @override
  void dispose() {
    // Dispose resources

    faceDetector.close();
    interpreter.close();
    isolateInterpreter.close();
    super.dispose();
  }

//////////////////////////keep this///////////////

  // Future<tf_lite.Interpreter> loadModel() async {
  //   InterpreterOptions interpreterOptions = InterpreterOptions();
  //   // var interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;

  //   if (Platform.isAndroid) {
  //     interpreterOptions.addDelegate(XNNPackDelegate(
  //         options:
  //             XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
  //   }

  //   if (Platform.isIOS) {
  //     interpreterOptions.addDelegate(GpuDelegate());
  //   }

  //   return await tf_lite.Interpreter.fromAsset(
  //     'assets/facenet_512.tflite',
  //     options: interpreterOptions..threads = Platform.numberOfProcessors,
  //   );
  // }

  Future<tf_lite.Interpreter> loadModel() async {
    // InterpreterOptions interpreterOptions = InterpreterOptions();
    // var interpreterOptions = InterpreterOptions()..useNnApiForAndroid = true;// didnt work for me

    // var interpreterOptions = InterpreterOptions()..threads = 2;
    var interpreterOptions = InterpreterOptions()
      ..addDelegate(GpuDelegateV2()); //good

    // if (Platform.isAndroid) {
    //   interpreterOptions.addDelegate(XNNPackDelegate(
    //       options:
    //           XNNPackDelegateOptions(numThreads: Platform.numberOfProcessors)));
    // }

    // if (Platform.isIOS) {
    //   interpreterOptions.addDelegate(GpuDelegate());
    // }

    return await tf_lite.Interpreter.fromAsset('assets/facenet_512.tflite',
        options: interpreterOptions);
  }

  @override
  Widget build(BuildContext context) {
    // 4. use ref.watch() to get the value of the provider
    // final helloWorld = ref.watch(helloWorldProvider);
    // Constants constant = Constants();

    return Scaffold(
      // backgroundColor: Color(0xFF3a3b45),
      body: Stack(children: [
        // Background color with transparency
        const BackgroudContainer(),

        // Main content

        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50, bottom: 50),
                child: Text(
                  'Semesters',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              // const SizedBox(
              //   height: 50,
              // ),
              Center(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 25,
                    ),
                    Column(
                      children: [
                        // courseTile('Course 1', 'MAAM'),
                        SemesterButton(
                          // courseName: Constants.course_1,
                          semesterName: '1st Semester',

                          // courseTeacher: 'MAIM',
                          goToCourse: () {
                            navigateToCourses(
                                context,
                                '1',
                                'Course 1',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // courseTile('Course 4', 'MSA'),
                        SemesterButton(
                          semesterName: '3rd Semester',

                          // courseName: Constants.course_2,
                          // courseTeacher: 'MFK',
                          goToCourse: () {
                            //               (context, String courseName, tf_lite.IsolateInterpreter isolateInterpreter,
                            // FaceDetector faceDetector,List<CameraDescription> cameras, tf_lite.Interpreter interpreter)
                            navigateToCourses(
                                context,
                                '3',
                                'Course 2',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // courseTile('Course 4', 'MSA'),
                        SemesterButton(
                          semesterName: '5th Semester',

                          // courseName: Constants.course_2,
                          // courseTeacher: 'MFK',
                          goToCourse: () {
                            //               (context, String courseName, tf_lite.IsolateInterpreter isolateInterpreter,
                            // FaceDetector faceDetector,List<CameraDescription> cameras, tf_lite.Interpreter interpreter)
                            navigateToCourses(
                                context,
                                '5',
                                'Course 2',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // courseTile('Course 4', 'MSA'),
                        SemesterButton(
                          semesterName: '7th Semester',

                          // courseName: Constants.course_2,
                          // courseTeacher: 'MFK',
                          goToCourse: () {
                            //               (context, String courseName, tf_lite.IsolateInterpreter isolateInterpreter,
                            // FaceDetector faceDetector,List<CameraDescription> cameras, tf_lite.Interpreter interpreter)
                            navigateToCourses(
                                context,
                                '7',
                                'Course 2',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                      ],
                    ),
                    // const Padding(padding: EdgeInsets.only(right: 1)),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Column(
                      children: [
                        const SizedBox(
                          height: 70,
                        ),
                        SemesterButton(
                            semesterName: '2nd Semester',
                            // courseName: Constants.course_3,
                            // courseTeacher: 'MSA',
                            goToCourse: () {
                              navigateToCourses(
                                  context,
                                  '2',
                                  'Course 3',

                                  isolateInterpreter,
                                  faceDetector,
                                  cameras,
                                  interpreter);
                            }),
                        // courseTile('Course 3', 'MFK'),
                        const SizedBox(
                          height: 20,
                        ),
                        SemesterButton(
                          semesterName: '4th Semester',
                          // courseName: Constants.course_4,
                          // courseTeacher: 'JUA',
                          goToCourse: () {
                            navigateToCourses(
                                context,
                                '4',
                                'Course 4',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                        // courseTile('Course 4', 'JUA'),
                        const SizedBox(
                          height: 20,
                        ),
                        SemesterButton(
                          semesterName: '6th Semester',
                          // courseName: Constants.course_4,
                          // courseTeacher: 'JUA',
                          goToCourse: () {
                            navigateToCourses(
                                context,
                                '6',
                                'Course 4',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SemesterButton(
                          semesterName: '8th Semester',
                          // courseName: Constants.course_4,
                          // courseTeacher: 'JUA',
                          goToCourse: () {
                            navigateToCourses(
                                context,
                                '8',
                                'Course 4',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    const Text(
                      "Didn't register?",
                      style: TextStyle(
                        color: Colors.white38,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                interpreter: interpreter,
                                faceDetector: faceDetector,
                                isolateInterpreter: isolateInterpreter,
                                cameras: cameras,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Register here",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ElevatedButton(
              //     onPressed: initializeJsonFiles,
              //     child: const Text('Create files')),
              // const SizedBox(
              //   height: 10.0,
              // ),
              // ElevatedButton(
              //     onPressed: loadKeys, child: const Text('print files')),
              // const SizedBox(
              //   height: 10.0,
              // ),
              // ElevatedButton(
              //     onPressed: clearAllPrefs, child: const Text('Delete files')),
              // ElevatedButton(
              //     onPressed: deleteAllJsonFiles,
              //     child: const Text('Delete files')),
            ],
          ),
        ),
      ]),
    );
  }

  Future<void> initializeJsonFiles() async {
    List<String> courses = ['Course 1', 'Course 2', 'Course 3', 'Course 4'];
    final prefs = await SharedPreferences.getInstance();

    for (String course in courses) {
      if (prefs.getString(course) == null) {
        prefs.setString(course, json.encode({}));
      }
    }
    for (int i = 0; i < courses.length; i++) {
      getJsonFromPrefs(courses[i]);
    }
  }

  Future<Map<String, dynamic>?> getJsonFromPrefs(String course) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(course);
    if (jsonString != null) {
      Map<String, dynamic> jsonData = json.decode(jsonString);
      print('the map is $jsonData');
      return jsonData;
    }
    return {
      'map': 'working',
    };
  }

  Future<void> saveJsonToPrefs(
      String key, Map<String, dynamic> jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(jsonData);
    prefs.setString(key, jsonString);
  }

  Future<void> deleteAllJsonFiles() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> courses = ['Course 1', 'Course 2', 'Course 3', 'Course 4'];

    for (String course in courses) {
      await prefs.remove(course);
    }
  }

  Future<void> loadKeys() async {
    final prefs = await SharedPreferences.getInstance();

    print(prefs.getKeys().toList());
  }

  Future<void> clearAllPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('All prefs deleted');
    // Refresh the keys list after clearing
    // _loadKeys();
  }
  // required this.isolateInterpreter,
  // required this.detectionController,
  // required this.faceDetector,
  // required this.cameras,
  // required this.interpreter,

  void navigateToCourses(
      context,
      String semesterId,
      String courseName,
      tf_lite.IsolateInterpreter isolateInterpreter,
      FaceDetector faceDetector,
      List<CameraDescription> cameras,
      tf_lite.Interpreter interpreter) {
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
      MaterialPageRoute(
        builder: (context) =>
            CourseListScreen(
              semesterId: semesterId,
              interpreter: interpreter,
              isolateInterpreter: isolateInterpreter,
              cameras: cameras,
              faceDetector: faceDetector,
              courseName: courseName,
            ),
        //     CourseSelectionScreen(
        //   semesterId: semesterId,
        //   interpreter: interpreter,
        //   isolateInterpreter: isolateInterpreter,
        //   cameras: cameras,
        //   faceDetector: faceDetector,
        //   courseName: courseName,
        // ),
      ),
    );
  }
}
