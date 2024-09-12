
import 'package:dartz/dartz.dart';

abstract class CourseDetailsRepository {
  Future<Either<Map<String, dynamic>, List<dynamic>?>> getExams( String courseId,);
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> addExam(String semesterId,String courseId, String roomId, Map<String, dynamic> examData);
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> deleteExam(String courseId, String examId);
}