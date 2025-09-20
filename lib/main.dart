import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'src/services/ocr_service.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const DeltaApp());
}

class DeltaApp extends StatelessWidget {
  const DeltaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Δ-Silicon OCR',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const OcrScreen(),
    );
  }
}

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  late CameraController _controller;
  final OcrService _ocr = OcrService();
  String _result = 'Point camera at report';

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _startOcr();
    });
  }

  void _startOcr() async {
    await _ocr.init();
    _controller.startImageStream((image) async {
      final text = await _ocr.recognize(image);
      if (mounted) setState(() => _result = text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Δ-Silicon OCR')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_result, style: const TextStyle(fontSize: 24)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
