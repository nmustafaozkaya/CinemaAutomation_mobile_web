import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/buy_screen.dart';

class ShowtimesScreen extends StatefulWidget {
  final Cinema selectedCinema;
  final Movie currentMovie;

  const ShowtimesScreen({
    super.key,
    required this.selectedCinema,
    required this.currentMovie,
  });

  @override
  State<ShowtimesScreen> createState() => _ShowtimesScreenState();
}

class _ShowtimesScreenState extends State<ShowtimesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Showtime> _allShowtimes = [];
  List<DateTime> _uniqueDates = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchShowtimes();
  }

  List<dynamic> _extractShowtimeList(dynamic decodedData) {
    if (decodedData is! Map<String, dynamic>) return [];

    if (decodedData['success'] != true || decodedData['data'] == null) {
      return [];
    }

    final data = decodedData['data'];
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic> && data['data'] is List) {
      return data['data'] as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> _fetchShowtimePayload(Uri url) async {
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception(
        'API request failed. Code: ${response.statusCode}',
      );
    }

    if (response.body.isEmpty) {
      return [];
    }

    final decodedData = json.decode(response.body);
    return _extractShowtimeList(decodedData);
  }

  Future<void> _fetchShowtimes() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final primaryUrl = Uri.parse(
        "${ApiConnection.showtimes}?movie_id=${widget.currentMovie.id}&cinema_id=${widget.selectedCinema.cinemaId}",
      );

      List<dynamic> showtimeList = await _fetchShowtimePayload(primaryUrl);

      if (showtimeList.isEmpty) {
        final fallbackUrl = Uri.parse(
          "${ApiConnection.movies}/${widget.currentMovie.id}/showtimes?cinema_id=${widget.selectedCinema.cinemaId}",
        );

        try {
          showtimeList = await _fetchShowtimePayload(fallbackUrl);
        } catch (fallbackError) {
          debugPrint('Fallback showtime request failed: $fallbackError');
        }
      }

      if (showtimeList.isEmpty) {
        setState(() {
          _errorMessage =
              "No active showtimes exist for this movie at the selected cinema right now. Please try a different date or cinema.";
          _isLoading = false;
        });
        return;
      }

      final showtimes = showtimeList
          .map((json) => Showtime.fromJson(json))
          .toList();
          final dates = showtimes
              .map(
                (s) {
                  // startTime artık local timezone'da, toLocal() gerekmez
                  return DateTime(
                    s.startTime.year,
                    s.startTime.month,
                    s.startTime.day,
                  );
                },
              )
              .toSet()
              .toList()
            ..sort();

      setState(() {
        _allShowtimes = showtimes;
        _uniqueDates = dates;
        _selectedDate = dates.isNotEmpty ? dates.first : null;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e, stack) {
      debugPrint('Error while loading showtimes: $e\n$stack');
      setState(() {
        _errorMessage =
            "An unexpected error occurred while fetching showtimes. Please try again.";
        _isLoading = false;
      });
    }
  }

  Widget _buildDateSelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _uniqueDates.length,
        itemBuilder: (context, index) {
          final date = _uniqueDates[index];
          final isSelected = _selectedDate == date;
          final formattedDate = DateFormat('dd MMM, EEE', 'en_US').format(date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              margin: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: index == _uniqueDates.length - 1 ? 16 : 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : AppColorStyle.primaryAccent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  formattedDate,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.black
                        : AppColorStyle.textPrimary,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShowtimesForDate() {
    if (_selectedDate == null) {
      return const Center(
        child: Text(
          'Please select a date.',
          style: TextStyle(color: AppColorStyle.textSecondary),
        ),
      );
    }

      final showtimesForDate = _allShowtimes.where((showtime) {
      // startTime artık local timezone'da, toLocal() gerekmez
      return showtime.startTime.year == _selectedDate!.year &&
          showtime.startTime.month == _selectedDate!.month &&
          showtime.startTime.day == _selectedDate!.day;
    }).toList();

    if (showtimesForDate.isEmpty) {
      return const Center(
        child: Text(
          'No showtimes available on this date.',
          style: TextStyle(color: AppColorStyle.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: showtimesForDate.length,
      itemBuilder: (context, index) {
        final showtime = showtimesForDate[index];
        // startTime artık local timezone'da, toLocal() gerekmez
        final formattedTime = DateFormat('HH:mm').format(showtime.startTime);

        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BuyScreen(
                  currentMovie: widget.currentMovie,
                  selectedShowtime: showtime,
                  currentCinema: widget.selectedCinema,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColorStyle.appBarColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColorStyle.primaryAccent),
            ),
            child: Center(
              child: Text(
                formattedTime,
                style: const TextStyle(
                  color: AppColorStyle.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.selectedCinema.cinemaName,
          style: const TextStyle(color: AppColorStyle.textPrimary),
        ),
        backgroundColor: AppColorStyle.appBarColor,
        iconTheme: const IconThemeData(color: AppColorStyle.textPrimary),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColorStyle.primaryAccent,
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            )
          : Column(
              children: [
                _buildDateSelector(),
                Expanded(child: _buildShowtimesForDate()),
              ],
            ),
    );
  }
}
