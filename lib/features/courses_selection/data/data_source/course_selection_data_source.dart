abstract class CourseSelectionDataSource {
  Future<Map<String, List<dynamic>>> getAttendanceMap(String nameOfJsonFile);
  Future<Map<String, List<dynamic>>> getAllStudentsMap(String nameOfJsonFile);
  Future<void> saveOrUpdateJsonInSharedPreferences( String key, String courseName);
}
