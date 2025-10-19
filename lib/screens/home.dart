import 'package:flutter/material.dart';
import 'package:cinema_automation/components/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cinema_automation/constant/app_color_style.dart';
import 'package:cinema_automation/screens/cinema_screen.dart';
import 'package:cinema_automation/screens/movies_screen.dart';
import 'package:cinema_automation/screens/profile_screen.dart';
import 'package:cinema_automation/screens/home_screen.dart';

class HomePage extends StatefulWidget {
  final User currentUser;
  final int initialIndex;
  const HomePage({super.key, required this.currentUser, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget gecerliSayfa(int aktif, User user) {
  switch (aktif) {
    case 0:
      return const HomeScreen();
    case 1:
      return const moviesScreen(isComingSoon: false);
    case 2:
      return const CinemaScreen();
    case 3:
      return ProfileScreen(currentUser: user);
    default:
      return const HomeScreen();
  }
}

class _HomePageState extends State<HomePage> {
  late int aktifOge;

  @override
  void initState() {
    super.initState();
    aktifOge = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gecerliSayfa(aktifOge, widget.currentUser),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: aktifOge,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColorStyle.primaryAccent,
        unselectedItemColor: AppColorStyle.textPrimary,
        backgroundColor: AppColorStyle.appBarColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Otomatik Filmler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.theaters),
            label: 'Otomatik Sinemalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidUser),
            label: 'Profil',
          ),
        ],
        onTap: (int index) {
          setState(() {
            aktifOge = index;
          });
        },
      ),
    );
  }
}
