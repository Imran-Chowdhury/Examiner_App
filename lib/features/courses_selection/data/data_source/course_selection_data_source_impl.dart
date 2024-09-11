import 'dart:convert';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'course_selection_data_source.dart';

final courseScreenDataSourceProvider = Provider((ref) {
  return CourseScreenDataSourceImpl();
});

class CourseScreenDataSourceImpl extends CourseSelectionDataSource {
  @override
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

  @override
  Future<Map<String, List<dynamic>>> getAllStudentsMap(
      String nameOfJsonFile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = prefs.getString(nameOfJsonFile);
    if (jsonMap != null) {
      final decodedMap = Map<String, List<dynamic>>.from(json.decode(jsonMap));
      return decodedMap;
    } else {
      return {};
    }
  }

  @override
  Future<void> saveOrUpdateJsonInSharedPreferences(
      String key, String courseName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? existingJsonString = prefs.getString(courseName); //Course 1

    // for(int i  = 0; i<listOfOutputs.length; i++){
    //   print('The $i st list of $key is ${listOfOutputs[i]} ');
    // }

    if (existingJsonString == null) {
      // If the JSON file doesn't exist, create a new one with the provided key and value
      Map<String, dynamic> newJsonData = {key: []};
      // Map<String, List<List<double>>> newJsonData = {key: listOfOutputs};
      await prefs.setString(courseName, jsonEncode(newJsonData));
    } else {
      // If the JSON file exists, update it
      Map<String, dynamic> existingJson =
          json.decode(existingJsonString) as Map<String, dynamic>;

      existingJson[key] = [];

      // Check if the key already exists in the JSON
      // if (existingJson.containsKey(key)) {
      //   // If the key exists, update its value
      //   // existingJson[key] = listOfOutputs;
      // } else {
      //   // If the key doesn't exist, add a new key-value pair
      //   existingJson[key] = listOfOutputs;
      // }

      await prefs.setString(courseName, jsonEncode(existingJson));
      // dynamic printMap = await readMapFromSharedPreferencesFromTrainDataSource(nameOfJsonFile);
      // print('The name of the file is $nameOfJsonFile');
      // print(printMap);
    }
  }
}
