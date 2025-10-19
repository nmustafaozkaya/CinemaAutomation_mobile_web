import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cinema_automation/components/user_preferences.dart';
import 'package:cinema_automation/components/user.dart';
import 'package:cinema_automation/screens/home.dart';
import 'package:cinema_automation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  final rememberMe = await UserPreferences.getRememberMe();
  final currentUser = rememberMe ? await UserPreferences.readData() : null;

  runApp(MyApp(currentUser: currentUser));
}

class MyApp extends StatelessWidget {
  final User? currentUser;

  const MyApp({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema Automation',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: currentUser != null
          ? HomePage(currentUser: currentUser!)
          : const LoginScreen(),
    );
  }
}
