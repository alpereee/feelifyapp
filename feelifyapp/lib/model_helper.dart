import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelHelper {
  late final Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/models/emotion_model.tflite');
      print('✅ Model başarıyla yüklendi!');
    } catch (e) {
      print('❌ Model yüklenirken hata oluştu: $e');
    }
  }

  Interpreter get interpreter => _interpreter;

  Future<int> predictEmotion(File imageFile) async {
    // Görüntüyü oku
    final imageBytes = await imageFile.readAsBytes();
    final img.Image? oriImage = img.decodeImage(imageBytes);

    if (oriImage == null) {
      throw Exception("Görüntü okunamadı!");
    }

    // 48x48 boyutuna resize
    final img.Image resizedImage =
        img.copyResize(oriImage, width: 48, height: 48);

    // Normalizasyon ve grayscale
    final input = List.generate(48, (y) {
      return List.generate(48, (x) {
        final pixel = resizedImage.getPixel(x, y);
        final grayscale =
            (img.getRed(pixel) + img.getGreen(pixel) + img.getBlue(pixel)) /
                3.0;
        return [grayscale / 255.0]; // Normalize edilmiş [0,1] aralığı
      });
    });

    // Input Tensor: [1, 48, 48, 1]
    final inputTensor = [input];

    // Output Tensor: [1, 7] (7 sınıf için)
    var outputTensor = List.filled(1 * 7, 0.0).reshape([1, 7]);

    // Model çalıştır
    _interpreter.run(inputTensor, outputTensor);

    // En yüksek olasılığa sahip sınıfı bul
    final output = outputTensor[0];
    final maxValue =
        output.reduce((a, b) => (a as double) > (b as double) ? a : b);
    int predictedIndex = output.indexOf(maxValue);

    return predictedIndex;
  }
}
