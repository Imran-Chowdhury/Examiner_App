
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';


abstract class RecognizeFaceRepository{



  double euclideanDistance(List e1, List e2);

  Future<Map<String,dynamic>> recognizeFace(img.Image image, Interpreter interpreter,IsolateInterpreter isolateInterpreter, String nameOfJsonFile, List<dynamic> allStudent);

  Map<String,dynamic> recognition(List<dynamic> data, List<dynamic> foundList, double threshold);

  double cosineSimilarity(List<double> vectorA, List<double> vectorB);


}