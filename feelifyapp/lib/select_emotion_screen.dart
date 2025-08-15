import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectEmotionScreen extends StatelessWidget {
  SelectEmotionScreen({Key? key}) : super(key: key);

  final Map<String, String> _spotifyPlaylists = {
    'Mutlu': 'https://open.spotify.com/playlist/37i9dQZF1DXdPec7aLTmlC',
    'Üzgün': 'https://open.spotify.com/playlist/37i9dQZF1DWSqBruwoIXkA',
    'Şaşkın': 'https://open.spotify.com/playlist/37i9dQZF1DX5Ejj0EkURtP',
    'Korkmuş': 'https://open.spotify.com/playlist/37i9dQZF1DX4sWSpwq3LiO',
    'Öfkeli': 'https://open.spotify.com/playlist/37i9dQZF1DWY3PJWG3ogmJ',
    'İğrenmiş': 'https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6',
    'Nötr': 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d',
  };

  final Map<String, String> _emotionEmojis = {
    'Mutlu': '😄',
    'Üzgün': '😢',
    'Şaşkın': '😲',
    'Korkmuş': '😨',
    'Öfkeli': '😡',
    'İğrenmiş': '🤢',
    'Nötr': '😐',
  };

  Future<void> _openSpotifyPlaylist(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Spotify linki açılamadı.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6D8EFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Duygu Seç 🎶',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: _spotifyPlaylists.keys.length,
          itemBuilder: (context, index) {
            String emotion = _spotifyPlaylists.keys.elementAt(index);
            String emoji = _emotionEmojis[emotion] ?? '';

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: () {
                  String? url = _spotifyPlaylists[emotion];
                  if (url != null) {
                    _openSpotifyPlaylist(url);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        emotion,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
