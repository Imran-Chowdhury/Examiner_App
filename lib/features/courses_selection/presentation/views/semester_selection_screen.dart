import 'dart:convert';



import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/utils/courseButton.dart';
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


    var interpreterOptions = InterpreterOptions()
      ..addDelegate(GpuDelegateV2()); //good

    return await tf_lite.Interpreter.fromAsset('assets/facenet_512.tflite',
        options: interpreterOptions);
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Stack(
          children: [

        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.057,),

              Center(
                child: Container(
                  height: screenHeight*0.24, //80
                  width: screenWidth*0.7, //180
                  decoration:const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/exam_2.png',
                      ),
                      fit: BoxFit.fill,
                    ),
                    shape: BoxShape.rectangle,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.057,),
              Padding(
                padding: EdgeInsets.only(left: screenWidth*0.01),
                child: const Text(
                  'Examiner',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.0115),

              Padding(
                padding: EdgeInsets.only(left: screenWidth*0.01),
                child:  const Text(
                  "An Advanced Attendance System!",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),

              Center(
                child: Row(
                  children: [

                    Padding(
                      padding: EdgeInsets.all(screenHeight * 0.01),
                      child: Column(
                        children: [

                          SemesterButton(
                            semesterName: '1st Semester',
                            goToCourse: () {
                              navigateToCourses(
                                  context,
                                  '1',
                                  '1st Semester',
                                  isolateInterpreter,
                                  faceDetector,
                                  cameras,
                                  interpreter
                              );
                            },
                            color: const Color(0xFFcabbe9),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          SemesterButton(
                            semesterName: '3rd Semester',
                            color: const Color(0xFFe4f1df),
                            goToCourse: () {
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

                          SemesterButton(
                            semesterName: '5th Semester',

                            color: const Color(0xFFcabbe9),
                            goToCourse: () {
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

                          SemesterButton(
                            semesterName: '7th Semester',
                            color: const Color(0xFFe4f1df),
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
                    ),

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
                          color: const Color(0xFFe4f1df),
                            goToCourse: () {
                              navigateToCourses(
                                  context,
                                  '2',
                                  '2nd Semester',
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
                          semesterName: '4th Semester',
                          color: const Color(0xFFcabbe9),
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
                          color: const Color(0xFFe4f1df),
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
                          color: const Color(0xFFcabbe9),
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
      ],
      ),
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
