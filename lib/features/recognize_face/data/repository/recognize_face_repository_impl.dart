import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tf_lite;
import '../../../../core/utils/image_to_float32.dart';
import '../../domain/repository/recognize_face_repository.dart';
import '../data_source/recognize_face_data_source.dart';
import '../data_source/recognize_face_data_source_impl.dart';

final recognizeFaceRepositoryProvider = Provider((ref) =>
    RecognizeFaceRepositoryImpl(
        dataSource: ref.read(recognizeFaceDataSourceProvider)));

class RecognizeFaceRepositoryImpl implements RecognizeFaceRepository {
  RecognizeFaceRepositoryImpl({required this.dataSource});

  RecognizeFaceDataSource dataSource;

  @override
  // Future<String> recognizeFace(
  //     img.Image image,
  //     Interpreter interpreter,
  //     IsolateInterpreter isolateInterpreter,
  //     String nameOfJsonFile)
  Future<Map<String,dynamic>> recognizeFace(
      img.Image image,
      tf_lite.Interpreter interpreter,
      tf_lite.IsolateInterpreter isolateInterpreter,
      String nameOfJsonFile,
      List<dynamic> allStudent
      ) async {
    final stopwatch = Stopwatch()..start();

    final inputShape = interpreter.getInputTensor(0).shape;
    final outputShape = interpreter.getOutputTensor(0).shape;

    final inputShapeLength = inputShape[1];
    final outputShapeLength = outputShape[1];

    List input = imageToByteListFloat32(inputShapeLength, 127.5, 127.5, image);

    input = input.reshape([1, inputShapeLength, inputShapeLength, 3]);

    // Initialize an empty list for outputs

    List output = List.filled(1 * outputShapeLength, null, growable: false)
        .reshape([1, outputShapeLength]);

    // interpreter.run(input, output);

    await isolateInterpreter.run(input, output);

    output = output.reshape([outputShapeLength]);
    var finalOutput = List.from(output);
    print('The final output is $finalOutput');



    // Map<String, List<dynamic>> trainings =
    //     await dataSource.readMapFromSharedPreferences(nameOfJsonFile);


    List<dynamic> trainings = allStudent;

    stopwatch.stop();
    final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
    print('Inference Time: $elapsedSeconds seconds');

    //  return recognition(trainings, finalOutput, 15.5); //seemed better and the safest to go
    return recognition(trainings, finalOutput, 16.5); //seemed better
  }

  @override
  // String recognition(Map<String, List<dynamic>> trainings, List<dynamic> finalOutput, double threshold) {

  Map<String,dynamic> recognition( List<dynamic> trainings, List<dynamic> finalOutput, double threshold) {


    final stopwatch = Stopwatch()..start();

    double minDistance = double.infinity;

    String matchedName = '';
    Map<String,dynamic> studentData = {};

    try {
      for(int i = 0; i<trainings.length;i++){


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
      } else {
        print('Yes!');
        print('the person is $matchedName');
        print('the minDistance is $minDistance');
        // print('the Cosine distance is $maxDistance');
      }
      // print('The avgMap is $avgMap');

      stopwatch.stop();
      final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
      print('recognize Time: $elapsedSeconds seconds');

      print('the studentData is $studentData');
      return studentData ;

      // return matchedName + minDistance.toString();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  @override
  double euclideanDistance(List e1, List e2) {
    // final stopwatch = Stopwatch()..start();

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }

    // stopwatch.stop();
    // final double elapsedSeconds = stopwatch.elapsedMilliseconds / 1000.0;
    // print('Euclidean distance Time: $elapsedSeconds seconds');
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
