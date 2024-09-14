import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../riverpod/course_details_riverpod.dart';
import 'exam_screen.dart';

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

   CourseDetailsScreen({
     required this.courseId,
     required this.semesterId,
     required this.courseName,
    required this.isolateInterpreter,
    required this.faceDetector,
    required this.cameras,
    required this.interpreter,});

  @override
  _CourseDetailsScreenState createState() => _CourseDetailsScreenState();
}


class _CourseDetailsScreenState extends ConsumerState<CourseDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the exams as soon as the screen is initialized
    print('The course id is ${widget.courseId}');
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


    return Scaffold(
      appBar: AppBar(
        title: Text('Exams for Course ${widget.courseId}'),
      ),
      body: examsAsync.when(

        data: (exams) {
          if (exams == null || exams.isEmpty) {
            return const Center(
              child: Text(
                'No exams available. Add a new exam!',
                style: TextStyle(
                  color: Colors.white70,
                    fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              print(exams);
              return ListTile(
                onLongPress: (){
                  _showDeleteDialog(context, exams[index]['id'].toString(), widget.courseId);

                },
                onTap: (){
                  Navigator.push(
                    context,
                    // MaterialPageRoute(builder: (context) => LiveFeedScreen()),
                    MaterialPageRoute(
                      builder: (context) => ExamScreen(
                        day: exams[index]['exam_date'],
                        // attendedStudentsMap: attendanceSheet,
                        courseName: widget.courseName,
                        interpreter: widget.interpreter,
                        isolateInterpreter: widget.isolateInterpreter,
                        cameras: widget.cameras,
                        faceDetector: widget.faceDetector,
                        semesterId: widget.semesterId,
                        examId: exams[index]['id'].toString(),

                      ),
                    ),
                  );
                },
                title: Text(
                    'Exam Date: ${exams[index]['exam_date']}',
                        style: const TextStyle(color: Colors.white70),
                ),
                subtitle: Text(
                  'Room: ${exams[index]['room']}',
                  style: const TextStyle(color: Colors.white70),
                ),
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
            builder: (context) => AddExamDialog(
              courseId: widget.courseId,
              semesterId: widget.semesterId,
            ),
          );
        },
        child: const Icon(Icons.add),
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

              // await ref.refresh(examsProvider(widget.courseId).notifier).getExams(widget.courseId);

            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}


class AddExamDialog extends ConsumerStatefulWidget {
  final String courseId;
  final String semesterId;

  AddExamDialog({required this.courseId, required this.semesterId});

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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        // _dateController.text = picked.toIso8601String();
        _dateController.text = formattedDate;
      });
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
            hint: const Text('Select Room'),
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
                  // 'room_id': roomId,
                  // 'course_id': widget.courseId,
                  // 'semester_id': widget.semesterId,
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



                // await ref.refresh(examsProvider(widget.courseId).notifier).getExams(widget.courseId);



                Navigator.pop(context); // Close dialog
              }
            },
            child: const Text('Submit'),
          ),
      ],
    );
  }
}
