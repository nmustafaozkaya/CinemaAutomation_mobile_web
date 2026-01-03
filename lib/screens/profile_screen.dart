import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';
import 'package:sinema_uygulamasi/screens/edit_profile_screen.dart';
import 'package:sinema_uygulamasi/screens/change_password_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/my_ticket_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User currentUser;
  const ProfileScreen({super.key, required this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColorStyle.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorStyle.appBarColor,
        centerTitle: true,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: AppColorStyle.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColorStyle.appBarColor,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColorStyle.primaryAccent,
                      child: const Icon(
                        // const ekledik
                        FontAwesomeIcons.user,
                        size: 50,
                        color: AppColorStyle.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.currentUser.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColorStyle.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.currentUser.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColorStyle.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Account Settings',
              style: TextStyle(
                color: AppColorStyle.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: AppColorStyle.primaryAccent),

            ListTile(
              leading: const Icon(
                Icons.edit,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Edit Details',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      currentUser: widget.currentUser,
                    ),
                  ),
                );
                
                // If profile was updated, just show a message
                // The EditProfileScreen already pops back
                if (result == true && mounted) {
                  // Optionally reload user data in background
                  UserPreferences.readData();
                }
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.lock,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Change Password',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.creditCard,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Payment Methods',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Payment methods are coming soon"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'My Movies',
              style: TextStyle(
                color: AppColorStyle.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: AppColorStyle.primaryAccent),

            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text(
                'Favorite Movies',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Favorite movies are coming soon"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'My Tickets',
              style: TextStyle(
                color: AppColorStyle.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: AppColorStyle.primaryAccent),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.ticketSimple,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'My Tickets',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyTicketsPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                final navigator = Navigator.of(context);
                await UserPreferences.removeData();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
