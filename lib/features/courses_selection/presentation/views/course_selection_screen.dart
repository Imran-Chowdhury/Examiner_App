






import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../riverpod/course_screen_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';

import 'course_details_screen.dart';


class CourseListScreen extends ConsumerStatefulWidget {
  final String courseName;
  final String semesterId;
  // final FaceDetectionNotifier detectionController;

  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;

  CourseListScreen({ required this.courseName,
    required this.semesterId,
    required this.isolateInterpreter,
    // required this.detectionController,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,});

  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider(widget.semesterId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
      ),
      body: coursesAsync.when(
        data: (coursesEither) {
          return coursesEither.fold(
                (error) => Center(child: Text('Error: ${error['error'] ?? 'Unknown error'}')),
                (courses) {
              if (courses == null || courses.isEmpty) {
                return const Center(
                  child: Text(
                    'No courses available. Add a course!',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  // print(courses);
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailsScreen(
                            courseId: courses[index]['id'].toString(), // Pass courseId
                            semesterId: widget.semesterId, // Pass semesterId
                          ),
                        ),
                      );
                    },
                    title: Text(
                      courses[index]['name'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddCourseDialog(semesterId: widget.semesterId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


class AddCourseDialog extends ConsumerStatefulWidget {
  final String semesterId;

  const AddCourseDialog({required this.semesterId});

  @override
  _AddCourseDialogState createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends ConsumerState<AddCourseDialog> {
  final TextEditingController _courseNameController = TextEditingController();

  @override
  void dispose() {
    _courseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addCourseState = ref.watch(addCourseProvider);

    return AlertDialog(
      title: const Text('Add Course'),
      content: TextField(
        controller: _courseNameController,
        decoration: const InputDecoration(
          labelText: 'Course Name',
        ),
      ),
      actions: [
        if (addCourseState is AsyncLoading) const CircularProgressIndicator(),
        if (addCourseState is! AsyncLoading)
          TextButton(
            onPressed: () async {
              final courseName = _courseNameController.text;
              if (courseName.isNotEmpty) {
                await ref
                    .read(addCourseProvider.notifier)
                    .addCourse(widget.semesterId, {'name': courseName}, null);

                // ref.refresh(coursesProvider(widget.semesterId)); // Refresh courses after adding
                ref.invalidate(coursesProvider(widget.semesterId)); // Invalidate to refresh the courses
                Navigator.pop(context); // Close dialog after successful addition
              }
            },
            child: const Text('Done'),
          ),
      ],
    );
  }
}





// import 'dart:convert';
//
// import 'package:camera/camera.dart';
//
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
// import '../../../../core/base_state/course_screen_state.dart';
// import '../../../../core/constants/constants.dart';
// import '../../../../core/utils/background_widget.dart';
// import '../riverpod/course_screen_riverpod.dart';
// import 'course_day.dart';
//
// // ignore: must_be_immutable
// class CourseSelectionScreen extends ConsumerStatefulWidget {
//   CourseSelectionScreen({
//     super.key,
//     required this.courseName,
//     required this.semesterId,
//     required this.isolateInterpreter,
//     // required this.detectionController,
//     required this.faceDetector,
//     required this.cameras,
//     required this.interpreter,
//   });
//   final String courseName;
//   final String semesterId;
//   // final FaceDetectionNotifier detectionController;
//
//   final FaceDetector faceDetector;
//   late List<CameraDescription> cameras;
//   final tf_lite.Interpreter interpreter;
//   final tf_lite.IsolateInterpreter isolateInterpreter;
//
//   @override
//   ConsumerState<CourseSelectionScreen> createState() => _CourseSelectionScreenState();
// }
//
// // 2. extend [ConsumerState]
// class _CourseSelectionScreenState extends ConsumerState<CourseSelectionScreen> {
//
//
//   List<dynamic>? listOfCourses;
//
//   @override
//   void initState() {
//     super.initState();
//     // var courseScreenState = ref.watch(courseScreenProvider(widget.semesterId));
//     CourseScreenNotifier courseScreenNotifier =
//     ref.read(courseScreenProvider(widget.semesterId).notifier);
//
//    courseScreenNotifier.getCourses(widget.semesterId);
//
//     // print('The attendance map is $attendanceSheetMap');
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     var courseScreenState = ref.watch(courseScreenProvider(widget.semesterId));
//     var courseScreenNotifier =
//         ref.watch(courseScreenProvider(widget.semesterId).notifier);
//
//     // List<dynamic>? listOfCourses = mapToList(attendanceSheetMap);
//     List<dynamic>? listOfCourses;
//
//     if (courseScreenState is CourseScreeenSuccessState) {
//       listOfCourses = courseScreenState.data;
//     }
//
//     return SafeArea(
//       child: Scaffold(
//         floatingActionButton:
//             add(context, courseScreenNotifier, listOfCourses,widget.semesterId),
//         // backgroundColor: const Color(0xFF3a3b45),
//         body: Stack(
//           children: [
//             const BackgroudContainer(),
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
//                   child: Center(
//                     child: Text(
//                       widget.courseName,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Expanded(
//                 //   child: listOfDays!.isEmpty
//                 //       ? const Center(
//                 //           child: Text('Start Class'),
//                 //         )
//                 //       : (courseScreenState is CourseScreeenSuccessState)
//                 //           ? listofDates(courseScreenState.data)
//                 //           : listofDates(listOfDays),
//                 // ),
//                 Expanded(
//                   child: (courseScreenState is CourseScreeenSuccessState)
//                       ? courseList(courseScreenState.data)
//                       : const Center(
//                     child: Text('Start Course'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget courseList(List<dynamic>? listOfDays) {
//     return ListView.builder(
//       itemCount: listOfDays?.length,
//       itemBuilder: (context, index) {
//         print('The list of days is $listOfDays');
//         return GestureDetector(
//           onTap: () {
//             // navigateToDay(
//             //   context,
//             //   listOfDays[index],
//             //   attendanceSheetMap,
//             //   widget.courseName,
//             //   widget.isolateInterpreter,
//             //   widget.faceDetector,
//             //   widget.cameras,
//             //   widget.interpreter,
//             // );
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Container(
//               height: 60,
//               width: 200,
//               decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(20)),
//                   gradient: LinearGradient(colors: [
//                     ColorConst.lightButtonColor,
//                     ColorConst.darkButtonColor
//                   ])),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       listOfDays![index]['name'],
//                       style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold),
//                     ),
//                     const Icon(
//                       Icons.arrow_forward,
//                       color: Colors.white,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget add(BuildContext context, CourseScreenNotifier courseScreenNotifier,
//       List<dynamic>? courseList, String semesterId,) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 30, bottom: 50),
//       child: FloatingActionButton(
//           backgroundColor: Colors.white,
//           shape: const CircleBorder(),
//           onPressed: () async {
//             // DateTime? pickedDate = await showDatePicker(
//             //   context: context,
//             //   initialDate: DateTime.now(),
//             //   firstDate: DateTime(2000),
//             //   lastDate: DateTime(2100),
//             // );
//             String courseName = 'EEE 114';
//
//             if (courseName != null) {
//               // String? formattedDate =
//               //     DateFormat('dd-MM-yyyy').format(pickedDate);
//               Map<String, dynamic> courseData =  {
//                 'name': courseName,
//               };
//               courseScreenNotifier.addCourses(semesterId, courseData, courseList);
//               // courseScreenNotifier.dayList(widget.courseName,
//                   // formattedDate.toString(), listOfDays, attendanceMap);
//             }
//           },
//           child: const Icon(Icons.add)),
//     );
//   }
//
//
//   //
//   // void navigateToDay(
//   //     context,
//   //     String day,
//   //     dynamic attendanceSheet,
//   //     String courseName,
//   //     tf_lite.IsolateInterpreter isolateInterpreter,
//   //     FaceDetector faceDetector,
//   //     List<CameraDescription> cameras,
//   //     tf_lite.Interpreter interpreter) {
//   //   Navigator.push(
//   //     context,
//   //     // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
//   //     MaterialPageRoute(
//   //       builder: (context) => CourseDayScreen(
//   //         day: day,
//   //         attendedStudentsMap: attendanceSheet,
//   //         courseName: courseName,
//   //         interpreter: interpreter,
//   //         isolateInterpreter: isolateInterpreter,
//   //         cameras: cameras,
//   //         faceDetector: faceDetector,
//   //       ),
//   //     ),
//   //   );
//   // }
//
//
//
//
// }
