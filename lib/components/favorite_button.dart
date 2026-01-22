import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';

class FavoriteButton extends StatefulWidget {
  final int movieId;
  final double size;
  final bool initialIsFavorite;

  const FavoriteButton({
    super.key,
    required this.movieId,
    this.size = 24,
    this.initialIsFavorite = false,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialIsFavorite;
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final token = await UserPreferences.getToken();
      if (token == null || token.isEmpty) return;

      final response = await http.get(
        Uri.parse(ApiConnection.checkFavoriteMovieUrl(widget.movieId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          isFavorite = data['is_favorite'] ?? false;
        });
      }
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => isLoading = true);

    try {
      final token = await UserPreferences.getToken();
      if (token == null || token.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login to add favorites')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConnection.toggleFavoriteMovie),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'movie_id': widget.movieId}),
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          isFavorite = data['is_favorite'] ?? false;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isFavorite
                  ? '❤️ Added to favorites'
                  : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: isFavorite ? Colors.red : Colors.grey,
          ),
        );
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : _toggleFavorite,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: isLoading
            ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
                size: widget.size,
              ),
      ),
    );
  }
}
