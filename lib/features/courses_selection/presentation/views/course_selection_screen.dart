






import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../../../core/constants/constants.dart';
import '../../../../core/utils/background_widget.dart';
import '../riverpod/course_screen_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:camera/camera.dart';

import 'course_details_screen.dart';


class CourseListScreen extends ConsumerStatefulWidget {
  final String semesterName;
  final String semesterId;
  // final FaceDetectionNotifier detectionController;

  final FaceDetector faceDetector;
  late List<CameraDescription> cameras;
  final tf_lite.Interpreter interpreter;
  final tf_lite.IsolateInterpreter isolateInterpreter;

  CourseListScreen({ required this.semesterName,
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
        title: Text(
          widget.semesterName,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 20,
        backgroundColor: const Color.fromARGB(255, 101, 123, 120),
      ),
      body: Stack(
        children: [
          const BackgroundContainer(),  // Background placed behind content
          coursesAsync.when(
            data: (coursesEither) {
              return coursesEither.fold(
                    (error) => Center(child: Text('Error: ${error['error'] ?? 'Unknown error'}')),
                    (courses) {
                  if (courses == null || courses.isEmpty) {
                    return const Center(
                      child: Text(
                        'No courses available. Add a course!',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    );
                  }
                  return listOfCourses(courses);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 30, bottom: 50),
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddCourseDialog(semesterId: widget.semesterId),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );

  }
  Widget listOfCourses(List<dynamic>? courses) {
    return ListView.builder(
      itemCount: courses?.length,
      itemBuilder: (context, index) {

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailsScreen(
                  courseName:courses[index]['name'].toString(),
                  courseId: courses[index]['id'].toString(), // Pass courseId
                  semesterId: widget.semesterId, // Pass semesterId
                  isolateInterpreter: widget.isolateInterpreter,
                  faceDetector: widget.faceDetector,
                  cameras: widget.cameras,
                  interpreter: widget.interpreter,
                ),
              ),
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
                      courses![index]['name'],
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

              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
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

