
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;


class ApiService {
  // String baseUrl =  'http://192.168.167.139:8000/'; //mobile
  // String baseUrl =  'http://192.168.0.106:8000/'; //wifi
  String baseUrl =  'http://192.168.0.100:8000/'; //wifi



  Future<Either<Map<String,dynamic>, List<dynamic>?>> getCourses(String semesterId) async {
    String url = '${baseUrl}api/semesters/$semesterId/courses/';



    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      // body: jsonEncode(studentData),
    );

    if (response.statusCode == 200) {
      print('Courses Found!');
      final List<dynamic>? responseBody = jsonDecode(response.body);


      return Right(responseBody);
    } else {

      final Map<String, dynamic> errorBody = jsonDecode(response.body);

      return Left(errorBody);
    }
  }



  Future<Either<Map<String,dynamic>,Map<String,dynamic>>> addCourses(String semesterId, Map<String,dynamic> courseData, List<dynamic>? listOfCourses,) async {
    String url = '${baseUrl}api/semesters/$semesterId/add-course/';




    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      body: jsonEncode(courseData),
    );

    if (response.statusCode == 201) {
      print('Courses added!');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      
      // state = CourseScreeenSuccessState(data: listOfCourses);

      // listOfCourses = responseBody;

      return Right(responseBody);
    } else {
      print('Failed to add courses: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      // Fluttertoast.showToast(msg: 'Failed to add Course' );
      return Left(errorBody);
    }
  }





  // path('semesters/<int:semester_pk>/courses/<int:course_pk>/rooms/<int:room_pk>/exams/', ExamViewSet.as_view({'get': 'list', 'post': 'create'}), name='exam-list-create'),

  Future<Either<Map<String, dynamic>, List<dynamic>?>> getExams( String courseId,) async {

    // String url = 'http://192.168.0.106:8000/api/semesters/$semesterId/courses/$courseId/rooms/$roomId/exams/';

    String url = '${baseUrl}api/courses/$courseId/exams/';

    final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic>? responseBody = jsonDecode(response.body);
      print('The resposnse body for exam is $responseBody');
      return Right(responseBody);
    } else {
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      // print('The resposnse body for exam is $responseBody');
      return Left(errorBody);
    }
  }

  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> addExam(String semesterId,String courseId, String roomId, Map<String, dynamic> examData) async {
    String url = '${baseUrl}api/semesters/$semesterId/courses/$courseId/rooms/$roomId/exams/';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(examData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return Right(responseBody);
    } else {
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      return Left(errorBody);
    }
  }


  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> deleteExam(String courseId, String examId) async {
    String url = '${baseUrl}api/courses/$courseId/exams/$examId/';

    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      // body: jsonEncode(examData),
    );
    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      print(responseBody);
      return Right(responseBody);
      // return const Right({
      //   "msg": "SuccessFully Deleted"
      // });
    } else {
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      print(errorBody);
      return Left(errorBody);
    }
  }


  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> getAStudent(String rollNumber) async {
    String url = '${baseUrl}api/Students/$rollNumber/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      // body: jsonEncode(studentData),
    );

    if (response.statusCode == 200) {
      print('Student Found!');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return Right(responseBody);
    } else {
      print('Failed to get student: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      return Left(errorBody);
    }
  }


  Future<Either<Map<String, dynamic>, List<dynamic>?>> getStudentsByRange(String semesterId, String startRoll, String endRoll)  async {
    String url = '${baseUrl}api/Students/semester/$semesterId/range/$startRoll/$endRoll/';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      // body: jsonEncode(examData),
    );
    print(jsonDecode(response.body));
    if (response.statusCode == 200) {
      final List<dynamic>? responseBody = jsonDecode(response.body);
      print('The resposnse body for exam is $responseBody');
      return Right(responseBody);
    } else {
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      // print('The resposnse body for exam is $responseBody');
      return Left(errorBody);
    }
  }

  Future<Either<Map<String, dynamic>, List<dynamic>?>> getAttendedStudents(String examId)async {
    String url = '${baseUrl}api/exams/$examId/attendance/';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      // body: jsonEncode(examData),
    );
    if (response.statusCode == 200) {
      final List<dynamic>? responseBody = jsonDecode(response.body);
      print('The resposnse body for exam is $responseBody');
      return Right(responseBody);
    } else {
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      // print('The resposnse body for exam is $responseBody');
      return Left(errorBody);
    }
  }




  Future<Either<Map<String, dynamic>, Map<String, dynamic>>> markAttendance(String examId, Map<String,dynamic> studentData) async {
    String url = '${baseUrl}api/exams/$examId/mark_attendance/';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        // Add token if required
      },
      body: jsonEncode(studentData),
    );

    if (response.statusCode == 201) {
      print('Student attended');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return Right(responseBody);
    } else {
      print('Failed to attend student: ${response.body}');
      final Map<String, dynamic> errorBody = jsonDecode(response.body);
      return Left(errorBody);
    }
  }



}
