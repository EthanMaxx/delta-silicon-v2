import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

class OcrService {
  late OrtSession _session;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    final raw = await rootBundle.load('assets/models/trocr-small-int8.onnx');
    final bytes = raw.buffer.asUint8List();
    _session = OrtSession.fromBuffer(bytes, OrtSessionOptions());
    _initialized = true;
  }

  Future<String> recognize(CameraImage image) async {
    if (!_initialized) await init();
    final Uint8List pixels = _convertYuv420(image);
    final flat = pixels.toList();
    final inputOrt = OrtValueTensor.createTensorWithDataList(flat, [1, 384, 384, 3]);
    final runOptions = OrtRunOptions();
    final outputs = _session.run([inputOrt], runOptions);
    final text = outputs.first.value.toString();
    return text.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  Uint8List _convertYuv420(CameraImage img) {
    final out = Uint8List(384 * 384 * 3);
    for (int y = 0; y < 384; y++) {
      for (int x = 0; x < 384; x++) {
        final idx = (y * 384 + x) * 3;
        out[idx] = 255;
        out[idx + 1] = 255;
        out[idx + 2] = 255;
      }
    }
    return out;
  }
}