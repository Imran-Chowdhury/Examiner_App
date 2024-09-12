import 'package:dartz/dartz.dart';
import 'package:face_roll_teacher/features/courses_selection/domain/course_details_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_services.dart';

final courseDetailsRepositoryProvider = Provider<CourseDetailsRepository>((ref) {
  final apiService = ApiService();
  return CourseDetailsRepositoryImpl(apiService);
});


class CourseDetailsRepositoryImpl implements CourseDetailsRepository {
  final ApiService apiService;

  CourseDetailsRepositoryImpl(this.apiService);


  @override
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>>
  addExam(String semesterId, String courseId, String roomId, Map<String, dynamic> examData) async{

    return await apiService.addExam(semesterId, courseId, roomId, examData);
  }

  @override
  Future<Either<Map<String, dynamic>, List?>> getExams(String courseId) {

    return apiService.getExams(courseId);
  }

  @override
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> deleteExam(String courseId, String examId) {
    return apiService.deleteExam(courseId, examId);
  }
}
