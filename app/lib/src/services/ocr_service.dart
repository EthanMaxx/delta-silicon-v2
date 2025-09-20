import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class OcrService {
  static const _channel = MethodChannel('delta_silicon/ort');

  Future<void> init() async {
    await _channel.invokeMethod('init');
  }

  Future<String> recognize(CameraImage image) async {
    // For now we send a dummy byte array – platform will convert to bitmap
    final pngBytes = Uint8List(0); // stub – platform handles CameraImage→Bitmap
    final text = await _channel.invokeMethod('recognize', {'png': pngBytes});
    return (text as String).replaceAll(RegExp(r'[^0-9.]'), '');
  }
}
