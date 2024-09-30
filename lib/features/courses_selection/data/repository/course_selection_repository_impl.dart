
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_services.dart';
import '../../domain/course_selection_repository.dart';


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


