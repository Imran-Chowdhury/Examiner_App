import '../../domain/entities/course.dart';

class CourseModel extends Course {
  CourseModel({required String id, required String name}) : super(id: id, name: name);

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'name': name,
    };
  }
}