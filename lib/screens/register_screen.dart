import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/rounded_button.dart';
import 'package:sinema_uygulamasi/components/rounded_input_field.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  var emailController = TextEditingController();
  var nameController = TextEditingController();
  var passwordController = TextEditingController();
  var rePasswordController = TextEditingController();
  var phoneController = TextEditingController();
  Future<void> registerAndSaveUserRecord() async {
    // Şifrelerin eşleşip eşleşmediğini kontrol et
    if (passwordController.text.trim() != rePasswordController.text.trim()) {
      Fluttertoast.showToast(msg: "Şifreler uyuşmuyor!");
      return;
    }

    // Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    var body = jsonEncode({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'password_confirmation': rePasswordController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    try {
      var res = await http.post(
        Uri.parse(ApiConnection.signUp),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();
      }

      var resBodyOfSignUp = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (resBodyOfSignUp['success'] == true) {
          Fluttertoast.showToast(msg: 'Kayıt başarılı!');

          var userData = resBodyOfSignUp['data']['user'];

          User user = User.fromJson(userData);

          await UserPreferences.saveData(user);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          Fluttertoast.showToast(
            msg:
                'Hata: ${resBodyOfSignUp['message'] ?? 'Bilinmeyen bir hata oluştu.'}',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else if (res.statusCode == 422) {
        // Sunucudan gelen validasyon hatalarını daha anlaşılır göster
        final errors = resBodyOfSignUp['errors'] as Map<String, dynamic>;
        String errorMessage = "Lütfen hataları düzeltin:\n";
        errors.forEach((key, value) {
          errorMessage += "- ${value[0]}\n";
        });
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        Fluttertoast.showToast(
          msg:
              'Sunucu hatası: ${res.statusCode} - ${resBodyOfSignUp['message'] ?? 'Bilinmeyen hata'}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();
      }

      Fluttertoast.showToast(
        msg: "Bağlantı hatası: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset('assets/images/logo.png', height: 150, width: 150),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    RoundedInputField(
                      controller: nameController,
                      hintText: 'Name',
                      icon: Icons.person,
                      isEmail: false,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: emailController,
                      hintText: 'E-mail',
                      icon: Icons.mail,
                      isEmail: true,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    // 3. Add the input field to the UI
                    RoundedInputField(
                      controller: phoneController,
                      hintText: 'Phone',
                      icon: Icons.phone,
                      isEmail: false,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: passwordController,
                      hintText: 'Password',
                      icon: Icons.lock,
                      isEmail: false,
                      isPassword: true,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: rePasswordController,
                      hintText: 'Repeat Password',
                      icon: Icons.lock,
                      isEmail: false,
                      isPassword: true,
                      onChange: (value) {},
                    ),
                    RoundedButton(
                      text: 'Register',
                      onPressed: () {
                        if (rePasswordController.text.trim() !=
                            passwordController.text.trim()) {
                          Fluttertoast.showToast(msg: 'Passwords are not same');
                        } else {
                          registerAndSaveUserRecord();
                        }
                      },
                      color: const Color(0xFF5FCFAF),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text("Already have an account? Login"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
