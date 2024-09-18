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
        const BackgroundContainer(),

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
                                '1st Semester',
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
                                '3rd Semester',
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
                                '5th Semester',
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

                            navigateToCourses(
                                context,
                                '7',
                                '7th Semester',
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
                                  '2nd Semester',

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
                                '4th Semester',
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
                                '6th Semester',
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
                                '8th Semester',
                                isolateInterpreter,
                                faceDetector,
                                cameras,
                                interpreter);
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ]),
    );
  }


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
              semesterName: courseName,
            ),
      ),
    );
  }
}
