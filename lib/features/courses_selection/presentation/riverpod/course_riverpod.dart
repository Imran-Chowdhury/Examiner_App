import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/base_state/course_state.dart';

final courseProvider =
    StateNotifierProvider.family((ref, semester) => CourseNotifier());

class CourseNotifier extends StateNotifier<CourseState> {
  CourseNotifier() : super(const CourseInitialState());

  Future<void> addToCourseList(
      String semester,
      String teacherName,
      String courseName,
      // List<dynamic>? courseList,
      Map<String, String>? courseMap) async {
    // print('The attended name is $name');
    List? listOfCourse;
    try {
      state = const CourseLoadingState();

      if (!courseMap!.containsKey(courseName)) {
        final newCourse = <String, String>{
          courseName: teacherName,
        };

        courseMap.addEntries(newCourse.entries);
        print('the attended students are $courseMap');
        state = CourseSuccessState(data: courseMap);
        //save the person in the main attendance sheet fro the particular day
        await saveOrUpdateJsonInSharedPreferences(
          semester,
          teacherName,
          courseName,
        );
        print(listOfCourse);
        Fluttertoast.showToast(msg: 'New course has been added');
      } else {
        state = CourseSuccessState(data: courseMap);
        Fluttertoast.showToast(msg: 'This course already exists');
      }

      // for (int i = 0; i <= courseList!.length; i++) {
      //   listOfCourse!.add(courseList[i][courseName]);
      // }
      // if (!listOfCourse!.contains(courseName)) {

      // if (!courseList!.contains({courseName: teacherName})) {
      //   courseList.add({courseName: teacherName});
      //   print('the attended students are $courseList');
      //   state = CourseSuccessState(data: courseList);
      //   //save the person in the main attendance sheet fro the particular day
      //   await saveOrUpdateJsonInSharedPreferences(
      //     semester,
      //     teacherName,
      //     courseName,
      //   );
      //   print(listOfCourse);
      //   Fluttertoast.showToast(msg: 'New course has been added');
      // } else {
      //   state = CourseSuccessState(data: courseList);
      //   Fluttertoast.showToast(msg: 'This course already exists');
      // }
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> manualAttend(List<dynamic>? attended, String name,
  //     String courseName, String day) async {
  //   try {
  //     state = const AttendanceLoadingState();

  //     Map<String, List<dynamic>> studentMap =
  //         await getAllStudentsMap('Total Students');

  //     if (!attended!.contains(name) && studentMap.containsKey(name)) {
  //       attended.add(name);
  //       print('the attended students are $attended');

  //       state = AttendanceSuccessState(data: attended);
  //       //save the person in the main attendance sheet fro the particular day
  //       await saveOrUpdateJsonInSharedPreferences(
  //         attended,
  //         day,
  //         courseName,
  //       );
  //     } else if (!studentMap.containsKey(name)) {
  //       Fluttertoast.showToast(msg: '$name is not found');
  //     } else if (attended.contains(name)) {
  //       Fluttertoast.showToast(msg: '$name is already present');
  //     } else {
  //       state = AttendanceSuccessState(data: attended);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> deleteName(List<dynamic>? attended, String name,
  //     String courseName, String day) async {
  //   // Implement your delete logic here, such as removing the name from the list
  //   try {
  //     state = const AttendanceLoadingState();
  //     attended!.remove(name);
  //     state = AttendanceSuccessState(data: attended);

  //     await saveOrUpdateJsonInSharedPreferences(
  //       attended,
  //       day,
  //       courseName,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}

Future<void> saveOrUpdateJsonInSharedPreferences(
  // List attendedStudents,
  String semester,
  String teacherName,
  String courseName,
) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? existingJsonString = prefs.getString(semester); //Course 1

  // for(int i  = 0; i<listOfOutputs.length; i++){
  //   print('The $i st list of $key is ${listOfOutputs[i]} ');
  // }

  if (existingJsonString == null) {
    // If the JSON file doesn't exist, create a new one with the provided key and value
    // Map<String, dynamic> newJsonData = {key: []};
    Map<String, dynamic> newJsonData = {courseName: teacherName};
    // Map<String, List<List<double>>> newJsonData = {key: listOfOutputs};
    await prefs.setString(courseName, jsonEncode(newJsonData));
  } else {
    // If the JSON file exists, update it
    Map<String, dynamic> existingJson =
        json.decode(existingJsonString) as Map<String, dynamic>;

    existingJson[courseName] = teacherName;

    // // Check if the key already exists in the JSON
    // if (existingJson.containsKey(courseName)) {
    //   // If the key exists, update its value
    //   // existingJson[courseName] = teacherName;//do nothing
    // } else {
    //   // If the key doesn't exist, add a new key-value pair
    //   existingJson[courseName] = teacherName;
    // }

    await prefs.setString(semester, jsonEncode(existingJson));
    // dynamic printMap = await readMapFromSharedPreferencesFromTrainDataSource(nameOfJsonFile);
    // print('The name of the file is $nameOfJsonFile');
    // print(printMap);
  }
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
