import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfirmScreen extends ConsumerStatefulWidget {
  final String originalName;
  final String originalRollNumber;
  final String originalSession;
  final String originalSemester;
  final List<int> uint8list;

  ConfirmScreen({
    Key? key,
    required this.originalName,
    required this.originalRollNumber,
    required this.originalSession,
    required this.originalSemester,
    required this.uint8list,
  }) : super(key: key);

  @override
  _ConfirmScreenState createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends ConsumerState<ConfirmScreen> {
  @override
  Widget build(BuildContext context) {
    // Convert List<int> to Uint8List for Image.memory
    final Uint8List imageBytes = Uint8List.fromList(widget.uint8list);

    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Image
            Center(
              child: Image.memory(imageBytes),
            ),
            SizedBox(height: 20),
            // Display Text
            Text('Name: ${widget.originalName}', style: TextStyle(fontSize: 18)),
            Text('Roll Number: ${widget.originalRollNumber}', style: TextStyle(fontSize: 18)),

            Text('Session: ${widget.originalSession}', style: TextStyle(fontSize: 18)),

            Text('Semester: ${widget.originalSemester}', style: TextStyle(fontSize: 18)),
            Spacer(),
            // Confirm Button
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  // Add action for confirm button
                },
                child: Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
