


import 'dart:convert';

import 'package:face_roll_teacher/features/courses_selection/data/repository/exam_repository_impl.dart';
import 'package:face_roll_teacher/features/courses_selection/domain/exam_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final examsDetailsProvider = StateNotifierProvider.family<ExamDetailsNotifier, AsyncValue<List<dynamic>>, String>(
      (ref, examId) => ExamDetailsNotifier(ref.watch(examRepositoryProvider)),
);

class ExamDetailsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final ExamRepository repository;

  ExamDetailsNotifier(this.repository) : super(const AsyncData([]));

  Future<void> getStudentsByRange(String examId,String semesterId, String startRoll, String endRoll) async{
    state = const AsyncValue.loading();
    final result = await repository.getStudentsByRange(semesterId, startRoll, endRoll);

    result.fold(
          (failure) => state = AsyncValue.error(failure['error'] ?? 'Failed to load exams', StackTrace.current),
          (students) async {
            print(students);

            if(students!.isNotEmpty){
              final SharedPreferences prefs = await SharedPreferences.getInstance();

              // Convert list of students to a JSON string
              String encodedStudentList = jsonEncode(students);

              // Save the JSON string in shared preferences with the examId as the key
              await prefs.setString(examId, encodedStudentList);
            }




            state = AsyncValue.data(students);
            // also save the list to the shared pref
          } ,
    );
  }
}


final getAStudentProvider = StateNotifierProvider.family<ExamDetailsNotifier,  AsyncValue<List<dynamic>>, String>(
      (ref, examId) => ExamDetailsNotifier(ref.watch(examRepositoryProvider)),
);

class GetAStudentNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final ExamRepository repository;

  GetAStudentNotifier(this.repository) : super(const AsyncData([]));

  Future<void> getAStudent(String examId,String rollNumber) async{
    List<dynamic> allStudents = [];
    state = const AsyncValue.loading();
    final result = await repository.getAStudent(rollNumber);

    result.fold(
          (failure) => state = AsyncValue.error(failure['error'] ?? 'Failed to load exams', StackTrace.current),
          (student) async {
        print(student);

        // Retrieve the JSON string using the examId as the key
        final SharedPreferences prefs = await SharedPreferences.getInstance();


        if(student.isNotEmpty){


          String? encodedStudentList = prefs.getString(examId);

          if(encodedStudentList!=null){
            // Decode the JSON string back to a list of students
            allStudents = jsonDecode(encodedStudentList);
            allStudents.add(student);
            String updatedListJson = jsonEncode(allStudents);
            await prefs.setString(examId, updatedListJson);
          }else{
            String encodedStudentList = jsonEncode([student]);
            await prefs.setString(examId, encodedStudentList);

          }
        }

        state = AsyncValue.data(allStudents);

      } ,
    );
  }
}



//State Provider and Notifier For attendance
