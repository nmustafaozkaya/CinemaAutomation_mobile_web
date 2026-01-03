import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';

class EditProfileScreen extends StatefulWidget {
  final User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isLoading = false;
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _userToken = await UserPreferences.getToken();
    
    setState(() {
      _nameController.text = widget.currentUser.name;
      _emailController.text = widget.currentUser.email;
      _phoneController.text = widget.currentUser.phone ?? '';
      
      if (widget.currentUser.birthDate != null) {
        _selectedBirthDate = DateTime.parse(widget.currentUser.birthDate!);
      }
      _selectedGender = widget.currentUser.gender;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColorStyle.primaryAccent,
              onPrimary: AppColorStyle.textPrimary,
              surface: AppColorStyle.appBarColor,
              onSurface: AppColorStyle.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userToken == null || _userToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Not logged in. Please sign in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
      'birth_date': _selectedBirthDate?.toIso8601String().split('T')[0],
      'gender': _selectedGender,
    };

    try {
      final response = await http.put(
        Uri.parse(ApiConnection.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_userToken',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Update local user data
          final updatedUser = User.fromJson(responseData['data']);
          await UserPreferences.saveData(updatedUser);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.statusCode}\n${response.body}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Avatar
            Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColorStyle.primaryAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: AppColorStyle.appBarColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelStyle: const TextStyle(color: AppColorStyle.textSecondary),
              ),
              style: const TextStyle(color: AppColorStyle.textPrimary),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: AppColorStyle.appBarColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelStyle: const TextStyle(color: AppColorStyle.textSecondary),
              ),
              style: const TextStyle(color: AppColorStyle.textPrimary),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone (Optional)',
                prefixIcon: const Icon(Icons.phone_outlined),
                hintText: '05XXXXXXXXX',
                filled: true,
                fillColor: AppColorStyle.appBarColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelStyle: const TextStyle(color: AppColorStyle.textSecondary),
                hintStyle: const TextStyle(color: AppColorStyle.textSecondary),
              ),
              style: const TextStyle(color: AppColorStyle.textPrimary),
            ),
            const SizedBox(height: 16),

            // Birth Date Field
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth (Optional)',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  filled: true,
                  fillColor: AppColorStyle.appBarColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: const TextStyle(color: AppColorStyle.textSecondary),
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: _selectedBirthDate != null
                        ? AppColorStyle.textPrimary
                        : AppColorStyle.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender Field
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender (Optional)',
                prefixIcon: const Icon(Icons.wc_outlined),
                filled: true,
                fillColor: AppColorStyle.appBarColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                labelStyle: const TextStyle(color: AppColorStyle.textSecondary),
              ),
              dropdownColor: AppColorStyle.appBarColor,
              style: const TextStyle(color: AppColorStyle.textPrimary),
              items: const [
                DropdownMenuItem(
                  value: null,
                  child: Text('Select Gender', style: TextStyle(color: AppColorStyle.textSecondary)),
                ),
                DropdownMenuItem(
                  value: 'male',
                  child: Text('Male'),
                ),
                DropdownMenuItem(
                  value: 'female',
                  child: Text('Female'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Other'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorStyle.primaryAccent,
                  foregroundColor: AppColorStyle.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColorStyle.textPrimary,
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

