import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'user_model.dart';
import 'home_page.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  bool isLogin = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6D8EFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Text(
                'Feelify',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                style: const TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const SizedBox(height: 40),
              if (!isLogin) ...[
                _buildTextField(
                  controller: nameController,
                  hintText: 'Ad Soyad',
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
              ],
              _buildTextField(
                controller: emailController,
                hintText: 'E-posta',
                icon: Icons.email,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: passwordController,
                hintText: 'Şifre',
                icon: Icons.lock,
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _buildMainButton(
                text: isLogin ? 'Giriş Yap' : 'Kayıt Ol',
                onPressed: _handleAuth,
              ),
              const SizedBox(height: 20),
              _buildGoogleButton(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? 'Hesabın yok mu? Kayıt Ol'
                      : 'Zaten hesabın var mı? Giriş Yap',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth() async {
    final Box<UserModel> userBox = Hive.box<UserModel>('users');

    if (isLogin) {
      // Giriş Yap
      UserModel? user = userBox.values.firstWhere(
        (u) =>
            u.email == emailController.text.trim() &&
            u.sifre == passwordController.text.trim(),
        orElse: () => UserModel(ad: '', soyad: '', email: '', sifre: ''),
      );

      if (user.email.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Başarıyla giriş yapıldı!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                userName: user.ad,
                email: user.email,
              ),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hatalı e-posta veya şifre!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Kayıt Ol
      final newUser = UserModel(
        ad: nameController.text.trim(),
        soyad: '',
        email: emailController.text.trim(),
        sifre: passwordController.text.trim(),
      );

      await userBox.add(newUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı! Şimdi giriş yapabilirsin.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        isLogin = true;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        fillColor: Colors.white,
        filled: true,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
      label: const Text(
        'Google ile Giriş Yap',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
