


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';


import '../../data/repository/exam_repository_impl.dart';
import '../../domain/exam_repository.dart';




final attendanceProvider = StateNotifierProvider.family<AttendanceNotifier, AsyncValue<List<dynamic>?>, String>(
      (ref, examId) => AttendanceNotifier(ref.watch(examRepositoryProvider)),
);
class AttendanceNotifier extends StateNotifier<AsyncValue<List<dynamic>?>> {
  final ExamRepository repository;

  AttendanceNotifier(this.repository) : super(const AsyncLoading());

  Future<void> getAttendedStudents(String examId,
      // String? name,
      // String day,
      // String courseName,
      // List<dynamic>? attended,
      ) async {
    state = const AsyncLoading();
    final result = await repository.getAttendedStudents(examId);

    result.fold(
          (failure) =>
      state = AsyncValue.error(
          failure['error'] ?? 'Failed To Get Attended List',
          StackTrace.current),


          (students) async {
        state = AsyncValue.data(students);
      },
    );
  }

  Future<void> markAttendance(List<dynamic>? attendedList, String examId,
      Map<String, dynamic> studentData) async {
    state = const AsyncLoading();
    print('The attended List is $attendedList');

    print('The marked student is $studentData');


    Map<String, dynamic> postData = {
      "student_id": studentData['roll_number']
    };
    final result = await repository.markAttendance(examId, postData);
    result.fold(
          (failure) {
            state = AsyncValue.error(failure['error'] ?? 'Failed To Get Attended List', StackTrace.current);
            Fluttertoast.showToast(msg: failure['error']);

          } ,
          (success) async {
            attendedList?.add(success);
            print('The Success is $success');


            state = AsyncValue.data(attendedList);
      },
    );
  }

  Future<void> removeStudent(List<dynamic>? attendedList, String rollNumber, String examId) async {
    final result = await repository.removeStudent(attendedList, rollNumber, examId);

    result.fold(
          (failure) => state = AsyncValue.error(failure['error'] ?? 'Failed To Delete Student', StackTrace.current),
          (success) async {

        if (attendedList != null && attendedList.isNotEmpty) {
          // Remove the map where the 'roll_number' key matches the given rollNumber
          attendedList.removeWhere((map) => map['student'].toString() == rollNumber);
        }

        // print('The list after deletion is $attendedList');

        // Update the state with the modified list
        state = AsyncValue.data(attendedList);
      },
    );
  }

}






























// import 'dart:convert';
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../../core/base_state/attendance_state.dart';
//
// final attendanceProvider =
//     StateNotifierProvider.family((ref, day) => AttendanceNotifier());
//
// class AttendanceNotifier extends StateNotifier<AttendanceState> {
//   AttendanceNotifier() : super(const AttendanceInitialState());
//
//   Future<void> attendedList(
//     String? name,
//     String day,
//     String courseName,
//     List<dynamic>? attended,
//   ) async {
//     print('The attended name is $name');
//     try {
//       state = const AttendanceLoadingState();
//       if (name != null && !attended!.contains(name)) {
//         attended.add(name);
//         print('the attended students are $attended');
//         state = AttendanceSuccessState(data: attended);
//         //save the person in the main attendance sheet fro the particular day
//         // await saveOrUpdateJsonInSharedPreferences(
//         //   attended,
//         //   day,
//         //   courseName,
//         // );
//       } else {
//         state = AttendanceSuccessState(data: attended);
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<void> manualAttend(List<dynamic>? attended, String name,
//       String courseName, String day) async {
//     try {
//       state = const AttendanceLoadingState();
//
//       Map<String, List<dynamic>> studentMap =
//           await getAllStudentsMap('Total Students');
//
//       if (!attended!.contains(name) && studentMap.containsKey(name)) {
//         attended.add(name);
//         print('the attended students are $attended');
//
//         state = AttendanceSuccessState(data: attended);
//         //save the person in the main attendance sheet fro the particular day
//         await saveOrUpdateJsonInSharedPreferences(
//           attended,
//           day,
//           courseName,
//         );
//       } else if (!studentMap.containsKey(name)) {
//         Fluttertoast.showToast(msg: '$name is not found');
//       } else if (attended.contains(name)) {
//         Fluttertoast.showToast(msg: '$name is already present');
//       } else {
//         state = AttendanceSuccessState(data: attended);
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<void> deleteName(List<dynamic>? attended, String name,
//       String courseName, String day) async {
//     // Implement your delete logic here, such as removing the name from the list
//     try {
//       state = const AttendanceLoadingState();
//       attended!.remove(name);
//       state = AttendanceSuccessState(data: attended);
//
//       await saveOrUpdateJsonInSharedPreferences(
//         attended,
//         day,
//         courseName,
//       );
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
//
// Future<void> saveOrUpdateJsonInSharedPreferences(
//   List attendedStudents,
//   String day,
//   String courseName,
// ) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   String? existingJsonString = prefs.getString(courseName); //Course 1
//
//   // for(int i  = 0; i<listOfOutputs.length; i++){
//   //   print('The $i st list of $key is ${listOfOutputs[i]} ');
//   // }
//
//   if (existingJsonString == null) {
//     // If the JSON file doesn't exist, create a new one with the provided key and value
//     // Map<String, dynamic> newJsonData = {key: []};
//     Map<String, dynamic> newJsonData = {day: attendedStudents};
//     // Map<String, List<List<double>>> newJsonData = {key: listOfOutputs};
//     await prefs.setString(courseName, jsonEncode(newJsonData));
//   } else {
//     // If the JSON file exists, update it
//     Map<String, dynamic> existingJson =
//         json.decode(existingJsonString) as Map<String, dynamic>;
//
//     // Check if the key already exists in the JSON
//     if (existingJson.containsKey(day)) {
//       // If the key exists, update its value
//       existingJson[day] = attendedStudents;
//     } else {
//       // If the key doesn't exist, add a new key-value pair
//       existingJson[day] = attendedStudents;
//     }
//
//     await prefs.setString(courseName, jsonEncode(existingJson));
//     // dynamic printMap = await readMapFromSharedPreferencesFromTrainDataSource(nameOfJsonFile);
//     // print('The name of the file is $nameOfJsonFile');
//     // print(printMap);
//   }
// }
//
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
