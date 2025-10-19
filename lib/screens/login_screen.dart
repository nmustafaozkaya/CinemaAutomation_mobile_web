import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:cinema_automation/api_connection/api_connection.dart';
import 'package:cinema_automation/components/rounded_button.dart';
import 'package:cinema_automation/components/rounded_input_field.dart';
import 'package:cinema_automation/components/square_box.dart';
import 'package:cinema_automation/components/user.dart';
import 'package:cinema_automation/components/user_preferences.dart';
import 'package:cinema_automation/constant/app_text_style.dart';
import 'package:cinema_automation/screens/home.dart';
import 'package:cinema_automation/screens/register_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;

  Future<void> loginUserNow() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Email ve şifre boş olamaz');
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

    try {
      print('API URL: ${ApiConnection.login}'); // Debug için

      var res = await http.post(
        Uri.parse(ApiConnection.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
        }),
      );

      print('Response Status: ${res.statusCode}'); // Debug için
      print('Response Body: ${res.body}'); // Debug için

      // Loading'i kapat
      Navigator.of(context).pop();

      if (res.statusCode == 200) {
        var resBody = jsonDecode(res.body);

        if (resBody['success'] == true) {
          Fluttertoast.showToast(msg: 'Giriş başarılı!');
          emailController.clear();
          passwordController.clear();

          var user = User.fromJson(resBody['data']['user']);

          if (rememberMe) {
            await UserPreferences.saveData(user);
            await UserPreferences.saveToken(resBody['data']['token']);
            await UserPreferences.setRememberMe(true);
          } else {
            await UserPreferences.setRememberMe(false);
            await UserPreferences.saveToken(resBody['data']['token']);
          }

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(currentUser: user),
              ),
            );
          });
        } else {
          Fluttertoast.showToast(
            msg: resBody['message'] ?? 'Giriş başarısız',
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else if (res.statusCode == 401) {
        Fluttertoast.showToast(
          msg: 'Email veya şifre hatalı!',
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        var resBody = jsonDecode(res.body);
        Fluttertoast.showToast(
          msg:
              'Sunucu hatası: ${res.statusCode} - ${resBody['message'] ?? 'Bilinmeyen hata'}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      // Loading'i kapat
      Navigator.of(context).pop();

      print('Login Error: $e'); // Debug için
      Fluttertoast.showToast(
        msg: 'Bağlantı hatası: $e',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Üst pattern
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: 3.1416,
                child: SvgPicture.asset(
                  'assets/images/ust_pattern.svg',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 150),
              Image.asset('assets/images/logo.png', height: 150, width: 150),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 350,
                    width: 350,
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        RoundedInputField(
                          controller: emailController,
                          hintText: 'E-mail',
                          icon: Icons.mail,
                          isEmail: true,
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
                        const SizedBox(height: 10),
                        Text(
                          'Forgot Password ?',
                          style: AppTextStyle.MINI_BOLD_DESCRIPTION_TEXT,
                        ),
                        const SizedBox(height: 5),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (newValue) {
                                    setState(() {
                                      rememberMe = newValue ?? false;
                                    });
                                  },
                                ),
                                const Text('Remember me'),
                              ],
                            ),
                          ],
                        ),

                        RoundedButton(
                          text: 'Login',
                          onPressed: loginUserNow,
                          color: const Color(0xFF5FCFAF),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Divider(
                        indent: 50,
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        ' Or Continue with ',
                        style: AppTextStyle.MIDDLE_DESCRIPTION_TEXT,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        endIndent: 50,
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SquareBox(imagePath: 'assets/logo/google.jpg'),
                  SizedBox(width: 25),
                  SquareBox(imagePath: 'assets/logo/apple.png'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Not a member?',
                      style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_TEXT,
                    ),
                  ),
                  GestureDetector(
                    child: Text(
                      'Register Now',
                      style: AppTextStyle.MINI_DEFAULT_DESCRIPTION_BOLD,
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 50),
            ],
          ),

          // Alt pattern
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SvgPicture.asset(
                'assets/images/alt_pattern.svg',
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
