import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/base_state/course_screen_state.dart';
import '../../domain/use_case.dart';
import 'package:http/http.dart' as http;


import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../../data/repository/course_selection_repository_impl.dart';
import '../../domain/course_selection_repository.dart';


final courseScreenProvider = StateNotifierProvider.family((ref, semesterId) =>
    CourseScreenNotifier(useCase: ref.read(courseScreenUseCaseProvider)));
//CourseScreenNotifier());

class CourseScreenNotifier extends StateNotifier<CourseScreenState> {
  // CourseScreenNotifier() : super(const CourseScreenInitialState());
  CourseScreenNotifier({required this.useCase})
      : super(const CourseScreenInitialState());
  CourseScreenUseCase useCase;

  Future<void> dayList(
      String courseName,
      String date,
      List<dynamic>? listOfDates,
      Map<String, List<dynamic>>? attendanceMap) async {
    state = const CourseScreenLoadingState();

    try {
      if (!listOfDates!.contains(date)) {
        listOfDates.add(date);
        state = CourseScreeenSuccessState(data: listOfDates);
        Fluttertoast.showToast(msg: 'New date added');

        await saveOrUpdateJsonInSharedPreferences(date, courseName);
      } else {
        state = CourseScreeenSuccessState(data: listOfDates);
        Fluttertoast.showToast(msg: 'This date already exists');
      }
    } catch (e) {
      rethrow;
    }
  }



  Future<void> addCourses(String semesterId, Map<String,dynamic> courseData, List<dynamic>? listOfCourses,) async {
    String url = 'http://192.168.0.106:8000/api/semesters/$semesterId/add-course/';

    state = const CourseScreenLoadingState();


    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      body: jsonEncode(courseData),
    );

    if (response.statusCode == 201) {
      print('Courses added!');
      final List<Map<String, dynamic>> responseBody = jsonDecode(response.body);
      listOfCourses?.add(responseBody);
      state = CourseScreeenSuccessState(data: listOfCourses);

      // listOfCourses = responseBody;

      // return responseBody;
    } else {
      print('Failed to add courses: ${response.body}');
      // final Map<String, dynamic> errorBody = jsonDecode(response.body);
      Fluttertoast.showToast(msg: 'Failed to add Course' );
      // return errorBody;
    }
  }

  Future<void> getCourses(String semesterId) async {
    String url = 'http://192.168.0.106:8000/api/semesters/$semesterId/courses/';
    state = const CourseScreenLoadingState();


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
      final List<dynamic>? responseBody = jsonDecode(response.body);
      state = CourseScreeenSuccessState(data: responseBody);

        // listOfCourses = responseBody;

      // return responseBody;
    } else {
      print('Failed to get courses: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      Fluttertoast.showToast(msg: errorBody['error'] );
      // return errorBody;
    }
  }



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









final coursesProvider = FutureProvider.family<Either<Map<String, dynamic>, List<dynamic>?>, String>((ref, semesterId) async {
  final repository = ref.read(courseRepositoryProvider);
  return await repository.fetchCourses(semesterId);
});

// Provider for AddCourseNotifier
final addCourseProvider = StateNotifierProvider<AddCourseNotifier, AsyncValue<void>>((ref) {
  final repository = ref.read(courseRepositoryProvider);
  return AddCourseNotifier(repository);
});



// Notifier for adding a course
class AddCourseNotifier extends StateNotifier<AsyncValue<void>> {
  final CourseRepository repository;

  AddCourseNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> addCourse(String semesterId, Map<String, dynamic> courseData, List<dynamic>? listOfCourses) async {
    state = const AsyncValue.loading();
    final result = await repository.addCourse(semesterId, courseData, listOfCourses);

    result.fold(
          (failure) {
        // Handle error scenario
            state = AsyncValue.error(failure['error'] ?? 'Failed to add course', StackTrace.current);
      },
          (success) {
        // Handle success scenario
        state = const AsyncValue.data(null);
      },
    );
  }
}

