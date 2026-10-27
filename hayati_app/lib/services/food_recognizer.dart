import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';

/// One guess at what a photo shows, with the model's confidence (0–1).
class FoodGuess {
  const FoodGuess(this.label, this.confidence);
  final String label;
  final double confidence;
}

/// Suggests what a meal photo shows, entirely on the device: no network,
/// and the photo is never stored or uploaded. Guesses are suggestions the
/// user confirms; nutrition comes from the app's food list.
abstract interface class FoodRecognizer {
  bool get available;
  Future<List<FoodGuess>> recognize(String imagePath);
}

class UnavailableFoodRecognizer implements FoodRecognizer {
  const UnavailableFoodRecognizer();
  @override
  bool get available => false;
  @override
  Future<List<FoodGuess>> recognize(String imagePath) async => const [];
}

/// Google's AIY food classifier (`assets/models/food_v1.tflite`, ~2,000
/// dishes) through ML Kit's custom-model image labeling.
class OnDeviceFoodRecognizer implements FoodRecognizer {
  static const _asset = 'assets/models/food_v1.tflite';
  ImageLabeler? _labeler;

  @override
  bool get available => true;

  Future<ImageLabeler> _open() async {
    if (_labeler != null) return _labeler!;
    // ML Kit reads the model from a file path, so copy it out once.
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/food_v1.tflite');
    if (!await file.exists()) {
      final data = await rootBundle.load(_asset);
      await file.writeAsBytes(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes), flush: true);
    }
    return _labeler = ImageLabeler(options: LocalLabelerOptions(modelPath: file.path, confidenceThreshold: 0.1, maxCount: 5));
  }

  @override
  Future<List<FoodGuess>> recognize(String imagePath) async {
    final labeler = await _open();
    final labels = await labeler.processImage(InputImage.fromFilePath(imagePath));
    return [
      for (final l in labels..sort((a, b) => b.confidence.compareTo(a.confidence)))
        if (l.label.isNotEmpty && l.label != '__background__') FoodGuess(l.label, l.confidence),
    ];
  }
}

/// Overridden in tests. Only phones run the model.
final foodRecognizerProvider = Provider<FoodRecognizer>((ref) {
  if (kIsWeb) return const UnavailableFoodRecognizer();
  return switch (defaultTargetPlatform) {
    TargetPlatform.android || TargetPlatform.iOS => OnDeviceFoodRecognizer(),
    _ => const UnavailableFoodRecognizer(),
  };
});
