
import 'package:dartz/dartz.dart';

abstract class ExamRepository {

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> getAStudent(String rollNumber);
  Future<Either<Map<String, dynamic>, List<dynamic>?>> getStudentsByRange(String semesterId, String startRoll, String endRoll);
  Future<Either<Map<String, dynamic>, List<dynamic>?>> getAttendedStudents(String examId);
}