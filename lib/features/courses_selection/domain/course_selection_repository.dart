import 'package:dartz/dartz.dart';

abstract class CourseRepository {
  Future<Either<Map<String, dynamic>, List<dynamic>?>> fetchCourses(String semesterId);
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> addCourse( String semesterId, Map<String, dynamic> courseData, List<dynamic>? listOfCourses,);
}