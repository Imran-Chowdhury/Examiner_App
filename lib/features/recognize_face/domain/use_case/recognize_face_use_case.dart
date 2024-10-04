// import 'package:face/features/recognize_face/domain/repository/recognize_face_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import 'package:tflite_flutter/tflite_flutter.dart';


import '../../data/repository/recognize_face_repository_impl.dart';
import '../repository/recognize_face_repository.dart';

final recognizeFaceUseCaseProvider = Provider((ref) => RecognizeFaceUseCase(
    repository: ref.read(recognizeFaceRepositoryProvider)));

class RecognizeFaceUseCase {
  RecognizeFaceUseCase({required this.repository});

  RecognizeFaceRepository repository;

  Future<Map<String,dynamic>> recognizeFace(
      img.Image image,
      tf_lite.Interpreter interpreter,
      tf_lite.IsolateInterpreter isolateInterpreter,
      tf_lite.Interpreter livenessInterpreter,
      tf_lite.IsolateInterpreter livenessIsolateInterpreter,
      String nameOfJsonFile,
      List<dynamic> allStudent
      ) async {
    return await repository.recognizeFace(
         image,
         interpreter,
         isolateInterpreter,
         livenessInterpreter,
         livenessIsolateInterpreter,
         nameOfJsonFile,
         allStudent);
  }




}
