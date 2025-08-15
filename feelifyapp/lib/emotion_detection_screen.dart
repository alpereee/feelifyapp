import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EmotionDetectionScreen extends StatefulWidget {
  const EmotionDetectionScreen({Key? key}) : super(key: key);

  @override
  State<EmotionDetectionScreen> createState() => _EmotionDetectionScreenState();
}

class _EmotionDetectionScreenState extends State<EmotionDetectionScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  String _emotionResult = 'Tahmin Bekleniyor...';
  File? _capturedImage;

  final Map<String, String> _spotifyPlaylists = {
    'Angry': 'https://open.spotify.com/playlist/37i9dQZF1DWY3PJWG3ogmJ',
    'Disgust': 'https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6',
    'Fear': 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
    'Happy': 'https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC',
    'Sad': 'https://open.spotify.com/playlist/37i9dQZF1DWSqBruwoIXkA',
    'Surprise': 'https://open.spotify.com/playlist/37i9dQZF1DX5Ejj0EkURtP',
    'Neutral': 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d',
  };

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();

    final frontCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras.first,
    );

    _selectedCameraIndex = _cameras.indexOf(frontCamera);

    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );

    await _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.isEmpty) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;

    await _cameraController.dispose();
    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _cameraController.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _capturePhoto() async {
    try {
      await _initializeControllerFuture;

      final image = await _cameraController.takePicture();
      File imgFile = File(image.path);

      setState(() {
        _capturedImage = imgFile;
        _emotionResult = "Fotoğraf çekildi. Şimdi tahmin yapabilirsiniz.";
      });
    } catch (e) {
      setState(() {
        _emotionResult = "Fotoğraf çekilirken hata oluştu: $e";
      });
    }
  }

  Future<void> _predictEmotion() async {
    try {
      if (_capturedImage == null) {
        setState(() {
          _emotionResult = "Önce bir fotoğraf çekmelisiniz.";
        });
        return;
      }

      setState(() {
        _emotionResult = "Tahmin yapılıyor...";
      });

      final url = Uri.parse('http://192.168.27.87:8080/predict');
// Emulator kullanıyorsan 10.0.2.2 yap
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _capturedImage!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final decoded = json.decode(respStr);
        final emotion = decoded['emotion'];

        setState(() {
          _emotionResult = "Tahmin: $emotion";
        });

        // 🎵 Spotify playlist aç
        _openSpotifyPlaylist(emotion);
      } else {
        setState(() {
          _emotionResult = "Sunucu hatası: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _emotionResult = "Tahmin sırasında hata oluştu: $e";
      });
    }
  }

  Future<void> _openSpotifyPlaylist(String emotion) async {
    final url = _spotifyPlaylists[emotion];
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duygu Analizi Yap 🎥'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _capturedImage == null
                ? FutureBuilder(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CameraPreview(_cameraController);
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              'Kamera yüklenirken hata oluştu: ${snapshot.error}'),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                : Image.file(_capturedImage!),
          ),
          const SizedBox(height: 10),
          Text(
            _emotionResult,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton('📸 Fotoğraf Çek', _capturePhoto),
              const SizedBox(width: 20),
              _buildActionButton('🔍 Tahmin Yap', _predictEmotion),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 6,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
