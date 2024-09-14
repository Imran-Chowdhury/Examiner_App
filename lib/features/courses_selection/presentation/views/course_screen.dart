import 'dart:convert';

import 'package:camera/camera.dart';


import 'package:flutter/material.dart';
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
import 'exam_screen.dart';

// ignore: must_be_immutable
class CourseScreen extends ConsumerStatefulWidget {
  CourseScreen({
    super.key,
    required this.courseName,
    required this.semesterId,
    required this.isolateInterpreter,
    // required this.detectionController,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,
  });
  final String courseName;
  final String semesterId;
  // final FaceDetectionNotifier detectionController;

  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

// 2. extend [ConsumerState]
class _CourseScreenState extends ConsumerState<CourseScreen> {
  Constants constant = Constants();
  Map<String, List<dynamic>> mapOfStudents = {};

  Map<String, List<dynamic>>? attendanceSheetMap = {};
  late String day;
  // List<dynamic>? daysFromMap;
  List<dynamic>? listOfDays;

  List<dynamic>? listOfCourses;

  @override
  void initState() {
    super.initState();

    getCourses(widget.semesterId);

    // print('The attendance map is $attendanceSheetMap');
  }




  Future<void> getCourses(String semesterId) async {
    String url = 'http://192.168.0.106:8000/api/semesters/$semesterId/courses/';
    // String url = '127.0.0.1:8000/api/semesters/2/courses/'
    // String url = '${Urls.baseUrl}$rollNumber/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      // body: jsonEncode(studentData),
    );

    if (response.statusCode == 200) {
      print('Courses Found!');
      final List<dynamic> responseBody = jsonDecode(response.body);
      setState(() {
        listOfCourses = responseBody;
      });
      // return responseBody;
    } else {
      print('Failed to get courses: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      // return errorBody;
    }
  }

  @override
  Widget build(BuildContext context) {
    var courseScreenState = ref.watch(courseScreenProvider(widget.semesterId));
    var courseScreenNotifier =
        ref.watch(courseScreenProvider(widget.semesterId).notifier);

    List<dynamic>? listOfDays = mapToList(attendanceSheetMap);
    if (courseScreenState is CourseScreeenSuccessState) {
      listOfDays = courseScreenState.data;
    }

    return SafeArea(
      child: Scaffold(
        floatingActionButton:
            add(context, courseScreenNotifier, listOfDays, attendanceSheetMap),
        // backgroundColor: const Color(0xFF3a3b45),
        body: Stack(
          children: [
            const BackgroudContainer(),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
                  child: Center(
                    child: Text(
                      widget.courseName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: listOfDays!.isEmpty
                      ? const Center(
                          child: Text('Start Class'),
                        )
                      : (courseScreenState is CourseScreeenSuccessState)
                          ? listofDates(courseScreenState.data)
                          : listofDates(listOfDays),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget listofDates(List<dynamic>? listOfDays) {
    return ListView.builder(
      itemCount: listOfDays?.length,
      itemBuilder: (context, index) {
        print('The list of days is $listOfDays');
        return GestureDetector(
          onTap: () {
            navigateToDay(
              context,
              listOfDays[index],
              attendanceSheetMap,
              widget.courseName,
              widget.isolateInterpreter,
              widget.faceDetector,
              widget.cameras,
              widget.interpreter,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 60,
              width: 200,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(colors: [
                    ColorConst.lightButtonColor,
                    ColorConst.darkButtonColor
                  ])),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      listOfDays![index],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget add(BuildContext context, CourseScreenNotifier courseScreenNotifier,
      List<dynamic>? listOfDays, Map<String, List<dynamic>>? attendanceMap) {
    return Padding(
      padding: const EdgeInsets.only(right: 30, bottom: 50),
      child: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              String? formattedDate =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
              courseScreenNotifier.dayList(widget.courseName,
                  formattedDate.toString(), listOfDays, attendanceMap);
            }
          },
          child: const Icon(Icons.add)),
    );
  }

  List<dynamic>? mapToList(Map<String, List<dynamic>>? attendanceSheetMap) {
    print('Lalalaa');
    List? daysList = [];
    try {
      if (attendanceSheetMap!.isNotEmpty) {
        for (String key in attendanceSheetMap.keys) {
          daysList.add(key);
        }
        print(daysList);
      } else {
        daysList = [];
      }
    } catch (e) {
      rethrow;
    }
    return daysList;
  }

  void navigateToDay(
      context,
      String day,
      dynamic attendanceSheet,
      String courseName,
      tf_lite.IsolateInterpreter isolateInterpreter,
      FaceDetector faceDetector,
      List<CameraDescription> cameras,
      tf_lite.Interpreter interpreter) {
    // Navigator.push(
    //   context,
    //   // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
    //   MaterialPageRoute(
    //     builder: (context) => ExamScreen(
    //       day: day,
    //       attendedStudentsMap: attendanceSheet,
    //       courseName: courseName,
    //       interpreter: interpreter,
    //       isolateInterpreter: isolateInterpreter,
    //       cameras: cameras,
    //       faceDetector: faceDetector,
    //
    //     ),
    //   ),
    // );
  }

  // Future<Map<String, List<dynamic>>> getAllStudentsMap(
  //     String nameOfJsonFile) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final jsonMap = prefs.getString(nameOfJsonFile);
  //   if (jsonMap != null) {
  //     final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
  //     return decodedMap;
  //   } else {
  //     return {};
  //   }
  // }

  Future<Map<String, List<dynamic>>> getAttendanceMap(
    String nameOfJsonFile,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      // attendanceSheet = decodedMap;
      return decodedMap;
    } else {
      return {};
    }
  }
}
