

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../data/repository/course_selection_repository_impl.dart';
import '../../domain/course_selection_repository.dart';


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

