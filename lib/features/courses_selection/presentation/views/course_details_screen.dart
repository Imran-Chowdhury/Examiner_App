import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../riverpod/course_details_riverpod.dart';


class CourseDetailsScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String semesterId;

  const CourseDetailsScreen({required this.courseId, required this.semesterId});

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
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: exams.length,
            itemBuilder: (context, index) {
              print(exams);
              return ListTile(
                title: Text(
                    'Exam Date: ${exams[index]['exam_date']}',
                        style: TextStyle(color: Colors.white70),
                ),
                subtitle: Text(
                  'Room: ${exams[index]['room']}',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            },
          );

        },
        loading: () => const Center(child: const CircularProgressIndicator()),
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

                // ref.invalidate(examsProvider(widget.courseId)); // Refresh exams
                // await ref.read(examsProvider(widget.courseId).notifier).getExams(widget.courseId);

                await ref.refresh(examsProvider(widget.courseId).notifier).getExams(widget.courseId);



                Navigator.pop(context); // Close dialog
              }
            },
            child: const Text('Submit'),
          ),
      ],
    );
  }
}
