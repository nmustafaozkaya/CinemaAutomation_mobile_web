import 'package:intl/intl.dart';
import 'movies.dart';

class Showtime {
  final int id;
  final DateTime startTime;
  final String price;
  final Movie movie;
  final int cinemaId;
  final String hallname;

  Showtime({
    required this.id,
    required this.startTime,
    required this.price,
    required this.movie,
    required this.cinemaId,
    required this.hallname,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    // API'den gelen zaman string'ini al ve olduğu gibi kullan
    String timeStr = json['start_time']?.toString() ?? '';
    
    DateTime startTime;
    try {
      // API'den ne geliyorsa onu parse et, timezone conversion yapma
      startTime = DateTime.parse(timeStr);
    } catch (e) {
      // Fallback: current time
      startTime = DateTime.now();
    }
    
    return Showtime(
      id: json['id'],
      startTime: startTime,
      price: json['price'],
      movie: Movie.fromJson(json['movie']),
      cinemaId: json['hall']['cinema']['id'],
      hallname: json['hall']['name'],
    );
  }

  DateTime get dateOnly {
    // startTime zaten local timezone'a çevrildi
    return DateTime(startTime.year, startTime.month, startTime.day);
  }

  String get timeOnly {
    // startTime zaten local timezone'a çevrildi
    return DateFormat('HH:mm').format(startTime);
  }
}
