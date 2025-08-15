import 'package:flutter/material.dart';
import 'profile_settings_screen.dart'; // Profil ekranı için import

class HomePage extends StatelessWidget {
  final String userName;
  final String email;

  const HomePage({Key? key, required this.userName, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6D8EFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hoş geldin, ${_extractName(userName)}!',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSettingsScreen(
                    userName: _extractName(userName),
                    email: email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'E-posta: $email',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              _buildMainButton(
                context,
                icon: Icons.camera_alt,
                text: 'Kameradan Duygu Analizi Yap',
                routeName: '/emotion-detection',
              ),
              const SizedBox(height: 30),
              _buildMainButton(
                context,
                icon: Icons.emoji_emotions,
                text: 'Hazır Duygu Seç',
                routeName: '/select-emotion',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kullanıcı adını e-postadan çekmek için küçük yardımcı fonksiyon
  String _extractName(String email) {
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return email;
  }

  // Ortak buton tasarımı
  Widget _buildMainButton(BuildContext context,
      {required IconData icon,
      required String text,
      required String routeName}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
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
            Icon(icon, size: 28, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
