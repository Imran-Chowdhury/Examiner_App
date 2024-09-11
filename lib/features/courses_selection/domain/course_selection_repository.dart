import 'package:dartz/dartz.dart';

import 'entities/course.dart';

abstract class CourseSelectionRepository {
  Future<List<dynamic>?> listOfDay(String courseName,String date, List<dynamic>? listOfDates,
      Map<String, List<dynamic>>? attendanceMap);
}



abstract class CourseRepository {
  Future<Either<Map<String, dynamic>, List<dynamic>?>> fetchCourses(String semesterId);
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> addCourse( String semesterId, Map<String, dynamic> courseData, List<dynamic>? listOfCourses,);
}