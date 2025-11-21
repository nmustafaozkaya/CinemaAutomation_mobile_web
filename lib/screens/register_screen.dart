import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/rounded_button.dart';
import 'package:sinema_uygulamasi/components/rounded_input_field.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/home.dart';

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
  DateTime? birthDate;
  String? selectedGender;
  Future<void> registerAndSaveUserRecord() async {
    // Şifrelerin eşleşip eşleşmediğini kontrol et
    if (passwordController.text.trim() != rePasswordController.text.trim()) {
      Fluttertoast.showToast(msg: "Şifreler eşleşmiyor!");
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

    Map<String, dynamic> bodyData = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'password_confirmation': rePasswordController.text.trim(),
    };

    // Opsiyonel alanları ekle
    if (phoneController.text.trim().isNotEmpty) {
      bodyData['phone'] = phoneController.text.trim();
    }
    if (birthDate != null) {
      bodyData['birth_date'] = birthDate!.toIso8601String().split('T')[0];
    }
    if (selectedGender != null && selectedGender!.isNotEmpty) {
      bodyData['gender'] = selectedGender;
    }

    var body = jsonEncode(bodyData);

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
          var token = resBodyOfSignUp['data']['token'];

          User user = User.fromJson(userData);

          // Token'ı kaydet
          await UserPreferences.saveToken(token);
          
          // Kullanıcı bilgilerini kaydet
          await UserPreferences.saveData(user);
          
          // Remember me'yi aktif et
          await UserPreferences.setRememberMe(true);

          if (mounted) {
            // Ana sayfaya yönlendir
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(currentUser: user),
              ),
              (route) => false, // Önceki tüm sayfaları temizle
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
                      hintText: 'Ad Soyad',
                      icon: Icons.person,
                      isEmail: false,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: emailController,
                      hintText: 'Email',
                      icon: Icons.mail,
                      isEmail: true,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: phoneController,
                      hintText: 'Telefon',
                      icon: Icons.phone,
                      isEmail: false,
                      isPassword: false,
                      onChange: (value) {},
                    ),
                    // Doğum Tarihi
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now().subtract(const Duration(days: 1)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF5FCFAF),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            birthDate = picked;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(29),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF5FCFAF)),
                            const SizedBox(width: 15),
                            Text(
                              birthDate == null
                                  ? 'Doğum Tarihi'
                                  : '${birthDate!.day.toString().padLeft(2, '0')} ${birthDate!.month.toString().padLeft(2, '0')} ${birthDate!.year}',
                              style: TextStyle(
                                color: birthDate == null ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Cinsiyet
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(29),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedGender,
                          isExpanded: true,
                          hint: const Row(
                            children: [
                              Icon(Icons.person, color: Color(0xFF5FCFAF)),
                              SizedBox(width: 15),
                              Text('Seçiniz', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5FCFAF)),
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Erkek')),
                            DropdownMenuItem(value: 'female', child: Text('Kadın')),
                            DropdownMenuItem(value: 'other', child: Text('Diğer')),
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                        ),
                      ),
                    ),
                    RoundedInputField(
                      controller: passwordController,
                      hintText: 'Şifre',
                      icon: Icons.lock,
                      isEmail: false,
                      isPassword: true,
                      onChange: (value) {},
                    ),
                    RoundedInputField(
                      controller: rePasswordController,
                      hintText: 'Şifre Tekrar',
                      icon: Icons.lock,
                      isEmail: false,
                      isPassword: true,
                      onChange: (value) {},
                    ),
                    RoundedButton(
                      text: 'Kayıt Ol',
                      onPressed: () {
                        if (rePasswordController.text.trim() !=
                            passwordController.text.trim()) {
                          Fluttertoast.showToast(msg: 'Şifreler eşleşmiyor!');
                        } else {
                          registerAndSaveUserRecord();
                        }
                      },
                      color: const Color(0xFF5FCFAF),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Zaten hesabınız var mı? Giriş yapın"),
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
