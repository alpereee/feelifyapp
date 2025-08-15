import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'user_model.dart'; // UserModel dosyası
import 'theme_notifier.dart'; // Tema sağlayıcı
import 'welcome_screen.dart'; // Welcome ekranı
import 'login_signup_screen.dart'; // Login/Kayıt ekranı
import 'emotion_detection_screen.dart'; // Duygu Analiz ekranı
import 'select_emotion_screen.dart'; // Hazır Duygu Seçim ekranı

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter Binding başlatılıyor
  await Hive.initFlutter(); // Hive başlatılıyor
  Hive.registerAdapter(UserModelAdapter()); // UserModel Adapter kaydı
  await Hive.openBox<UserModel>(
      'users'); // Kullanıcıları saklayacak kutu açılıyor

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const FeelifyApp(),
    ),
  );
}

class FeelifyApp extends StatelessWidget {
  const FeelifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Feelify App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlueAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeNotifier.themeMode, // Tema değişimi yönetimi
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginSignupScreen(),
        '/emotion-detection': (context) => const EmotionDetectionScreen(),
        '/select-emotion': (context) => SelectEmotionScreen(),
      },
    );
  }
}
