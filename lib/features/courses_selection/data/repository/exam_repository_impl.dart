

import 'package:dartz/dartz.dart';
import 'package:face_roll_teacher/core/network/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/exam_repository.dart';



final examRepositoryProvider = Provider<ExamRepository>((ref) {
  final apiService = ApiService();
  return ExamRepositoryImpl(apiService);
});


class ExamRepositoryImpl implements ExamRepository{


  final ApiService apiService;
  ExamRepositoryImpl(this.apiService);

  @override
  Future<Either<Map<String, dynamic>, List<dynamic>?>> getAttendedStudents(String examId)async {
   return await apiService.getAttendedStudents(examId);
  }

  @override
  Future<Either<Map<String, dynamic>, List<dynamic>?>> getStudentsByRange(String semesterId, String startRoll, String endRoll) async{
  return await apiService.getStudentsByRange(semesterId, startRoll, endRoll);
  }

  @override
  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> getAStudent(String rollNumber) async{
    return await apiService.getAStudent(rollNumber);
  }
}