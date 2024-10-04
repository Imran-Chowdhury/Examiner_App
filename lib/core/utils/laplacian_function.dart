import 'package:image/image.dart' as img;

const int inputImageSize = 256;
const int laplacianThreshold = 50; // Adjust this value based on your requirements

int laplacian(img.Image bitmap) {
  // Resize the image to 256x256
  img.Image resizedImage = img.copyResize(bitmap, width: inputImageSize, height: inputImageSize);

  // Laplacian filter kernel (3x3)
  List<List<int>> laplace = [
    [0, 1, 0],
    [1, -4, 1],
    [0, 1, 0],
  ];

  int size = laplace.length;
  int height = resizedImage.height;
  int width = resizedImage.width;

  // Convert image to grayscale
  List<List<int>> imgGray = convertGreyImg(resizedImage);

  int score = 0;

  // Apply the Laplacian filter
  for (int x = 0; x < height - size + 1; x++) {
    for (int y = 0; y < width - size + 1; y++) {
      int result = 0;

      // Perform convolution over the size*size region
      for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
          result += (imgGray[x + i][y + j]) * laplace[i][j];
        }
      }

      // If the result exceeds the threshold, increase the sharpness score
      if (result > laplacianThreshold) {
        score++;
      }
    }
  }

  return score;
}

// Helper function to convert image to grayscale
List<List<int>> convertGreyImg(img.Image image) {
  int width = image.width;
  int height = image.height;
  List<List<int>> grayImg = List.generate(height, (_) => List.filled(width, 0));

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int pixel = image.getPixel(x, y);
      int red = img.getRed(pixel);
      int green = img.getGreen(pixel);
      int blue = img.getBlue(pixel);

      // Calculate luminance (gray) value
      int gray = (0.299 * red + 0.587 * green + 0.114 * blue).round();
      grayImg[y][x] = gray;
    }
  }

  return grayImg;
}
