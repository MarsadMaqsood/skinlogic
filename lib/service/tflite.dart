// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class TfLiteService {
  TfLiteService();

  Map<String, dynamic> predictionResults = {};
  late Interpreter _interpreter;

  Future<String> runInference({XFile? selectedImage}) async {
    try {
      predictionResults.clear();

      _interpreter = await Interpreter.fromAsset('assets/model/model.tflite');
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');

      List<String> labels = labelsData
          .split('\n')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      if (selectedImage == null) {
        return 'No image selected.';
      }

      final bytes = await selectedImage.readAsBytes();

      img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        return 'Failed to decode image';
      }

      img.Image? resizedImage = img.copyResize(
        originalImage,
        width: 224,
        height: 224,
      );

      /// A 4D Float32List for the input tensor [1 224 224 3]
      final inputBytes = Float32List(1 * 224 * 224 * 3);
      final buffer = Float32List.view(inputBytes.buffer);

      int pixelIndex = 0;

      for (int x = 0; x < 224; x++) {
        for (int y = 0; y < 224; y++) {
          final pixel = resizedImage.getPixel(x, y);

          /// Extract R G B and normalize to [0, 1]
          buffer[pixelIndex++] = (pixel.r / 255.0);
          buffer[pixelIndex++] = (pixel.g / 255.0);
          buffer[pixelIndex++] = (pixel.b / 255.0);
        }
      }

      ///Prepare tensor output
      /// Model output shape should be [1, NUMBER OF CLASSES]
      final outputBuffer = List.filled(
        1 * labels.length,
        0.0,
      ).reshape([1, labels.length]);

      /// run inference
      _interpreter.run(inputBytes.buffer, outputBuffer);

      /// Process result (apply the softmax and Map to labels )
      Map<String, double> resultMap = {};
      List<double> probabilities = List<double>.from(outputBuffer[0]);
      double sumExp = probabilities
          .map((e) => math.exp(e))
          .reduce((a, b) => a + b);

      for (var i = 0; i < probabilities.length; i++) {
        if (i < labels.length) {
          double confidence = math.exp(probabilities[i]) / sumExp;
          resultMap[labels[i]] = confidence;
        }
      }

      /// Sort result by confidence (decending)
      predictionResults = Map.fromEntries(
        resultMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
      );

      return '$predictionResults';
    } catch (e) {
      return '$e';
    }
  }

  (String, double, String, Color) formatPrediction() {
    final topPrediction = predictionResults
        .entries
        .first; // Get the entry with the highest probability
    final diseaseName = topPrediction.key;
    final confidence = topPrediction.value;

    String confidenceMessage;
    Color confidenceColor;

    if (confidence > 0.85) {
      // Highly confident
      confidenceMessage = 'High confidence';
      confidenceColor = Colors.green;
    } else if (confidence > 0.60) {
      // Moderately confident
      confidenceMessage = 'Moderate confidence';
      confidenceColor = Colors.orange;
    } else {
      // Low confidence / Uncertain
      confidenceMessage = 'Low confidence - Consult a specialist';
      confidenceColor = Colors.red;
    }

    return (diseaseName, confidence, confidenceMessage, confidenceColor);
  }

  dispose() {
    _interpreter.close();
  }
}
