
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';


abstract class RecognizeFaceRepository{



  double euclideanDistance(List e1, List e2);

  Future<String> recognizeFace(img.Image image, Interpreter interpreter,IsolateInterpreter isolateInterpreter, String nameOfJsonFile, List<dynamic> allStudent);


  // String recognition(Map<String, List<dynamic>> data, List<dynamic> foundList, double threshold);
  String recognition(List<dynamic> data, List<dynamic> foundList, double threshold);

  double cosineSimilarity(List<double> vectorA, List<double> vectorB);


}