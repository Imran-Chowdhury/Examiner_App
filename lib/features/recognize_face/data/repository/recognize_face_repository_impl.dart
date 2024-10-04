
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import '../../../../core/utils/image_to_float32.dart';
import '../../../../core/utils/laplacian_function.dart';
import '../../domain/repository/recognize_face_repository.dart';




final recognizeFaceRepositoryProvider = Provider((ref) =>
    RecognizeFaceRepositoryImpl());

class RecognizeFaceRepositoryImpl implements RecognizeFaceRepository {
  RecognizeFaceRepositoryImpl();


  //
  // @override
  // Future<Map<String, dynamic>> recognizeFace(
  //     img.Image image,
  //     tf_lite.Interpreter interpreter,
  //     tf_lite.IsolateInterpreter isolateInterpreter,
  //     // tf_lite.Interpreter livenessInterpreter,
  //     tf_lite.IsolateInterpreter livenessIsolateInterpreter,
  //     String nameOfJsonFile,
  //     List<dynamic> allStudent
  //     ) async {
  //   final stopwatch = Stopwatch()..start();
  //
  //
  //
  //   final inputShape = interpreter.getInputTensor(0).shape;
  //   final outputShape = interpreter.getOutputTensor(0).shape;
  //
  //   final inputShapeLength = inputShape[1];
  //   final outputShapeLength = outputShape[1];
  //
  //   print('the input and output shape of facenet is $inputShape and $outputShape');
  //
  //   List input = imageToByteListFloat32(inputShapeLength, 127.5, 127.5, image);
  //   // List livenessInput = imageToByteListFloat32(256, 127.5, 127.5, image);
  //
  //
  //   input = input.reshape([1, inputShapeLength, inputShapeLength, 3]);
  //
  //
  //   // Initialize an empty list for outputs
  //   List output = List.filled(1 * outputShapeLength, null, growable: false).reshape([1, outputShapeLength]);// for face recognition
  //
  //
  //   // interpreter.run(input, output);
  //
  //   await isolateInterpreter.run(input, output);
  //   output = output.reshape([outputShapeLength]);
  //   var finalOutput = List.from(output);
  //   // print('The final output is $finalOutput');
  //
  //
  //
  //   List<dynamic> trainings = allStudent;
  //
  //   stopwatch.stop();
  //   final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
  //   print('Inference Time: $elapsedSeconds seconds');
  //   // await antiSpoofing(image, livenessIsolateInterpreter);
  //   //  return recognition(trainings, finalOutput, 15.5); //seemed better and the safest to go
  //   return recognition(trainings, finalOutput, 16.5); //seemed better
  // }
  //
  //
  // // Run inference on the image
  // // Future<List<double>> antiSpoofing(img.Image image,tf_lite.IsolateInterpreter livenessIsolateInterpreter, ) async {
  // Future<void> antiSpoofing(img.Image image,tf_lite.IsolateInterpreter livenessIsolateInterpreter, ) async {
  //   List livenessInput = imageToByteListFloat32(256, 127.5, 127.5, image);
  //
  //   livenessInput = livenessInput.reshape([1, 256, 256, 3]);
  //
  //
  //   List clssPred = List.filled(1 * 8, null, growable: false).reshape([1, 8]);
  //   List leafNodeMask = List.filled(1 * 8, null, growable: false).reshape([1, 8]);
  //   debugPrint('The length of livenessOutput ${clssPred.length} and ${leafNodeMask.length}');
  //   Map<int, List> outputs = {0:clssPred,1:leafNodeMask};
  //
  //
  //   await livenessIsolateInterpreter.run(livenessInput, outputs);
  //   // await Future.delayed(const Duration(seconds: 2));
  //   // await livenessIsolateInterpreter.runForMultipleInputs([livenessInput], outputs);
  //   // debugPrint('The outputs of liveness are $outputs');
  //    clssPred = clssPred.reshape([8]);
  //   var finalClssPred = List.from(clssPred);
  //
  //   leafNodeMask = leafNodeMask.reshape([8]);
  //   var finalLeafNodeMask = List.from(leafNodeMask);
  //
  //   // double livenessScore = calculateLivenessScore(finalLivenessOutput, List.filled(8, 1.0)); // Assuming leaf mask is all 1.0
  //
  //   // Step 8: Apply threshold for liveness detection
  //   // double threshold = 0.2;
  //   // bool isLive = livenessScore <= threshold;
  //   // debugPrint('The liveness is $isLive');
  //   // antiSpoofing(image, livenessIsolateInterpreter);
  //
  // }


  @override
  Future<Map<String, dynamic>> recognizeFace(img.Image image,
      tf_lite.Interpreter interpreter,
      tf_lite.IsolateInterpreter isolateInterpreter,
      tf_lite.Interpreter livenessInterpreter,
      tf_lite.IsolateInterpreter livenessIsolateInterpreter,
      String nameOfJsonFile,
      List<dynamic> allStudent) async {
    final stopwatch = Stopwatch()
      ..start();


    final liveInputShape = livenessInterpreter
        .getInputTensor(0)
        .shape;
    final liveOutputShape = livenessInterpreter
        .getOutputTensor(0)
        .shape;

    final liveInputShapeLength = liveInputShape[1];
    final liveOutputShapeLength = liveOutputShape[1];

    int laplacianThreshold = 1000;
    double liveThreshold = 0.2;
    double score;

    int laplace = laplacian(image);
    debugPrint('The laplace is $laplace');

    if (laplace < laplacianThreshold) {
      debugPrint('This is a Fake!!!!');
    } else {
      // long start = System.currentTimeMillis();
      List liveInput = imageToByteListFloat32(
          liveInputShapeLength, 255, 255, image);
      liveInput =
          liveInput.reshape([1, liveInputShapeLength, liveInputShapeLength, 3]);


      List classPred = List.filled(1 * liveOutputShapeLength, null, growable: false).reshape([1, liveOutputShapeLength]);
      List leafNodeMask = List.filled(1 * liveOutputShapeLength, null, growable: false).reshape([1, liveOutputShapeLength]);
      // livenessInterpreter.runForMultipleInputs([liveInput], {0: classPred, 1: leafNodeMask});
      await livenessIsolateInterpreter.runForMultipleInputs([liveInput], {0:classPred, 1:leafNodeMask});
      classPred.reshape([liveOutputShapeLength]);
      leafNodeMask.reshape([liveOutputShapeLength]);
      List output1 = List.from(classPred);
      List output2 = List.from(leafNodeMask);
      debugPrint('The classPred is $output1');
      debugPrint('The leafNodeMask is $output2');
      score = calculateLivenessScore(output1, output2);
      debugPrint('The liveness score is $score');

      if (score < liveThreshold) {
        debugPrint('This is REAL!!!!');
        final inputShape = interpreter.getInputTensor(0).shape;
        final outputShape = interpreter.getOutputTensor(0).shape;

        final inputShapeLength = inputShape[1];
        final outputShapeLength = outputShape[1];

        List input = imageToByteListFloat32(
            inputShapeLength, 127.5, 127.5, image);

        input = input.reshape([1, inputShapeLength, inputShapeLength, 3]);

        // Initialize an empty list for outputs

        List output = List.filled(1 * outputShapeLength, null, growable: false)
            .reshape([1, outputShapeLength]);

        // interpreter.run(input, output);

        await isolateInterpreter.run(input, output);

        output = output.reshape([outputShapeLength]);
        var finalOutput = List.from(output);
        print('The final output is $finalOutput');


        List<dynamic> trainings = allStudent;

        stopwatch.stop();
        final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
        print('Inference Time: $elapsedSeconds seconds');

        //  return recognition(trainings, finalOutput, 15.5); //seemed better and the safest to go

        return recognition(trainings, finalOutput, 16.5); //seemed better
      } else {
        debugPrint('This is a Fake!!!!');
        return {};
      }
    }
    return {};
  }


  @override
  Map<String, dynamic> recognition(List<dynamic> trainings,
      List<dynamic> finalOutput, double threshold) {
    final stopwatch = Stopwatch()
      ..start();

    double minDistance = double.infinity;

    String matchedName = '';
    Map<String, dynamic> studentData = {};

    try {
      for (int i = 0; i < trainings.length; i++) {
        List<dynamic> innerList = trainings[i]['face_embeddings'][0];
        String name = trainings[i]['name'];

        double distance = euclideanDistance(finalOutput, innerList);
        // cosineDistance =  cosineSimilarity(finalOutput, innerList);

        // print('the Cosine distance for $key  is $cosineDistance');
        print('the Euclidean distance for $name  is $distance');


        // For euclidean distance
        if (distance <= threshold && distance < minDistance) {
          studentData = trainings[i];
          minDistance = distance;
          // cosDis = cosineDistance;
          matchedName = name;
        }
      }


      if (matchedName == '') {
        print('Sad');
        print('No match!');

        return {};
      }


      stopwatch.stop();
      final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
      print('recognize Time: $elapsedSeconds seconds');

      print('the studentData is $studentData');
      return studentData;
    } catch (e) {
      // print(e);
      rethrow;
    }
  }


  double calculateLivenessScore(List output1, List output2) {
    double score = 0;
    List classPred = output1[0];
    List leafNodeMask = output2[0];
    for (int i = 0; i < classPred.length; i++) {
      // Cast clssPred[i] to double before calling abs()
      score += (classPred[i].abs() * leafNodeMask[i]);
    }
    return score;
  }


  @override
  double euclideanDistance(List e1, List e2) {
    // final stopwatch = Stopwatch()..start();

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }

    return sqrt(sum);
  }

  @override
  double cosineSimilarity(List<dynamic> vectorA, List<dynamic> vectorB) {
    if (vectorA.length != vectorB.length) {
      throw ArgumentError("Vectors must have the same length");
    }

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }

    normA = sqrt(normA);
    normB = sqrt(normB);

    if (normA == 0 || normB == 0) {
      return 0; // Handle division by zero
    }

    return dotProduct / (normA * normB);
  }


}
