import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../../../../core/base_state/base_state.dart';

import '../../domain/use_case/recognize_face_use_case.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;


final recognizeFaceProvider = StateNotifierProvider.family(
  (ref, day) {
    return RecognizeFaceNotifier(
        ref: ref, useCase: ref.read(recognizeFaceUseCaseProvider));
  },
);

class RecognizeFaceNotifier extends StateNotifier<BaseState> {
  RecognizeFaceNotifier({required this.ref, required this.useCase})
      : super(const InitialState());

  Ref ref;
  RecognizeFaceUseCase useCase;

  Future<Map<String,dynamic>> pickImagesAndRecognize(
      img.Image image,
      tf_lite.Interpreter interpreter,
      tf_lite.IsolateInterpreter isolateInterpreter,
      tf_lite.Interpreter livenessInterpreter,
      tf_lite.IsolateInterpreter livenessIsolateInterpreter,
      String nameOfJsonFile,
      List<dynamic> allStudent
      ) async {
    state = const LoadingState();
    final stopwatch = Stopwatch()..start();

    final studentData = await useCase.recognizeFace(
        image,
        interpreter,
        isolateInterpreter,
        livenessInterpreter,
        livenessIsolateInterpreter,
        nameOfJsonFile,
        allStudent);

    stopwatch.stop();
    final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;

    // Print the elapsed time in seconds
    print('The Recognition Execution time: $elapsedSeconds seconds');

    if (studentData.isNotEmpty) {
      // print('the name is $name');
      state = SuccessState(name: studentData['name']);
    } else {
      // print('No match!');
      state = const ErrorState('No match!');
    }
    return studentData;
  }

}
