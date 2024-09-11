
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_services.dart';
import '../../domain/course_selection_repository.dart';

import '../data_source/course_selection_data_source.dart';
import '../data_source/course_selection_data_source_impl.dart';

final courseSelectionRepositoryProvider = Provider((ref) {
  return CourseScreenRepositoryImpl(
      dataSource: ref.read(courseScreenDataSourceProvider));
});

class CourseScreenRepositoryImpl extends CourseSelectionRepository {
  CourseScreenRepositoryImpl({required this.dataSource});
  CourseSelectionDataSource dataSource;
//gotta use dartz for either function to send the list and the message
  @override
  Future<List<dynamic>?> listOfDay(
      String courseName,
      String date,
      List<dynamic>? listOfDates,
      Map<String, List<dynamic>>? attendanceMap) async {
    try {
      if (!listOfDates!.contains(date)) {
        listOfDates.add(date);

        await dataSource.saveOrUpdateJsonInSharedPreferences(date, courseName);
        return listOfDates;
      } else {
        // state = CourseScreeenSuccessState(data: listOfDates);
        // Fluttertoast.showToast(msg: 'This date already exists');
        return listOfDates;
      }
    } catch (e) {
      rethrow;
    }
    // return listOfDates;
  }
}

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  final apiService = ApiService();
  return CourseRepositoryImpl(apiService);
});


class CourseRepositoryImpl implements CourseRepository {
  final ApiService apiService;

  CourseRepositoryImpl(this.apiService);

  @override
  Future<Either<Map<String, dynamic>, List<dynamic>?>> fetchCourses(String semesterId) async {
    return await apiService.getCourses(semesterId);
  }

  @override
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> addCourse(
      String semesterId,
      Map<String, dynamic> courseData,
      List<dynamic>? listOfCourses,
      ) async {
    return await apiService.addCourses(semesterId, courseData, listOfCourses);
  }
}


