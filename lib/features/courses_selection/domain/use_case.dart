//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../../core/base_state/course_screen_state.dart';
// import '../data/repository/course_selection_repository_impl.dart';
// import 'course_selection_repository.dart';
//
// final courseScreenUseCaseProvider = Provider((ref) {
//   return CourseScreenUseCase(
//       repository: ref.read(courseSelectionRepositoryProvider));
// });
//
// class CourseScreenUseCase extends StateNotifier<CourseScreenState> {
//   CourseScreenUseCase({required this.repository}) : super(const CourseScreenInitialState());
//
//   CourseSelectionRepository repository;
//
//   Future<List<dynamic>?> dayList(String courseName,String date, List<dynamic>? listOfDates,
//       Map<String, List<dynamic>>? attendanceMap) {
//     return repository.listOfDay(courseName, date, listOfDates, attendanceMap);
//   }
// }
