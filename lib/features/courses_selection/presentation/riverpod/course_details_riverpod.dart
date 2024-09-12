import 'package:face_roll_teacher/features/courses_selection/domain/course_details_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repository/course_details_repository_impl.dart';
import '../../data/repository/course_selection_repository_impl.dart';

// final examsProvider = FutureProvider.family<List<dynamic>?, String>(
//       (ref, courseId) async {
//     final repository = ref.watch(courseDetailsRepositoryProvider);
//     final result = await repository.getExams(courseId);
//     return result.fold((failure) => throw Exception(failure['error']), (exams) => exams);
//   },
// );


//Exam Fetching Notifier

final examsProvider = StateNotifierProvider.family<ExamNotifier, AsyncValue<List<dynamic>?>, String>(
      (ref, courseId) => ExamNotifier(ref.watch(courseDetailsRepositoryProvider)),
);

class ExamNotifier extends StateNotifier<AsyncValue<List<dynamic>?>> {
  final CourseDetailsRepository repository;

  ExamNotifier(this.repository) : super(const AsyncValue.loading());

  Future<void> getExams(String courseId) async {
    state = const AsyncValue.loading();
    final result = await repository.getExams(courseId);

    result.fold(
          (failure) => state = AsyncValue.error(failure['error'] ?? 'Failed to load exams', StackTrace.current),
          (exams) => state = AsyncValue.data(exams),
    );
  }
}

//Exam Adding Notifier

final addExamProvider = StateNotifierProvider<AddExamNotifier, AsyncValue<void>>(
      (ref) => AddExamNotifier(ref.watch(courseDetailsRepositoryProvider)),
);



class AddExamNotifier extends StateNotifier<AsyncValue<void>> {
  final CourseDetailsRepository repository;

  AddExamNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> addExam(String semesterId,String courseId, String roomId, Map<String, dynamic> examData) async {
    state = const AsyncValue.loading();
    final result = await repository.addExam(semesterId,courseId, roomId,  examData);


    result.fold(
          (failure) => state = AsyncValue.error(failure['error'] ?? 'Failed to add exam', StackTrace.current),
          (success) => state = const AsyncValue.data(null),
    );
  }
}

//Exam Deleting Notifier

final deleteExamProvider = StateNotifierProvider<DeleteExamNotifier, AsyncValue<String>>(
      (ref) => DeleteExamNotifier(ref.watch(courseDetailsRepositoryProvider)),
);



class DeleteExamNotifier extends StateNotifier<AsyncValue<String>> {
  final CourseDetailsRepository repository;

  DeleteExamNotifier(this.repository) : super(const AsyncValue.data(''));

  Future<void> deleteExam(String courseId, String examId) async {
    state = const AsyncValue.loading();
    final result = await repository.deleteExam(courseId, examId);

    result.fold(
          (failure) => state = AsyncValue.error(failure['error'] ?? 'Failed to delete exam', StackTrace.current),
          (success) => state =  AsyncValue.data(success['msg']??'Deleted'),
    );
  }
}