import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Movie {
  final int id;
  final String title;
  final DateTime releaseDate;
  final String runtime;
  final String genre;
  final String plot;
  final String language;
  final String poster;
  final String imdbRating;
  final bool isPreOrder;
  final int? daysUntilRelease;

  Movie({
    required this.id,
    required this.title,
    required this.releaseDate,
    required this.runtime,
    required this.genre,
    required this.plot,
    required this.language,
    required this.poster,
    required this.imdbRating,
    this.isPreOrder = false,
    this.daysUntilRelease,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    try {
      // imdb_raiting string veya number olabilir
      String imdbRatingStr = '';
      if (json['imdb_raiting'] != null) {
        if (json['imdb_raiting'] is String) {
          imdbRatingStr = json['imdb_raiting'] as String;
        } else if (json['imdb_raiting'] is num) {
          imdbRatingStr = json['imdb_raiting'].toString();
        }
      }

      // Pre-order özelliği kaldırıldı - artık kullanılmıyor
      // API'den gelen değerler varsa al ama UI'da kullanma
      bool isPreOrder = false;
      int? daysUntilRelease;

      // Duration kontrolü - null veya geçersiz değerler için varsayılan
      String runtime = '';
      if (json['duration'] != null) {
        if (json['duration'] is int || json['duration'] is num) {
          runtime = '${json['duration']} dk';
        } else if (json['duration'] is String) {
          runtime = json['duration'] as String;
        }
      }

      return Movie(
        id: json['id'] is int
            ? json['id'] as int
            : int.tryParse(json['id'].toString()) ?? 0,
        title: json['title']?.toString() ?? '',
        releaseDate: parseDate(json['release_date']),
        runtime: runtime,
        genre: json['genre']?.toString() ?? '',
        plot: json['description']?.toString() ?? '',
        language: json['language']?.toString() ?? '',
        poster: json['poster_url']?.toString() ?? '',
        imdbRating: imdbRatingStr,
        isPreOrder: isPreOrder,
        daysUntilRelease: daysUntilRelease,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Movie.fromJson hatası: $e');
      debugPrint('   JSON: $json');
      debugPrint('   Stack trace: $stackTrace');
      rethrow;
    }
  }
}

DateTime parseDate(dynamic dateStr) {
  // null veya boş string kontrolü
  if (dateStr == null || dateStr.toString().isEmpty) {
    return DateTime(1900);
  }

  // Eğer zaten DateTime ise döndür
  if (dateStr is DateTime) {
    return dateStr;
  }

  // String'e çevir
  final dateString = dateStr.toString().trim();

  try {
    // Önce dd-MM-yyyy formatını dene (Laravel'den gelebilir)
    if (dateString.contains('-') && dateString.split('-').length == 3) {
      final parts = dateString.split('-');
      if (parts[0].length == 2 && parts[2].length == 4) {
        // dd-MM-yyyy formatı
        return DateFormat('dd-MM-yyyy').parseStrict(dateString);
      } else if (parts[0].length == 4 && parts[2].length == 2) {
        // yyyy-MM-dd formatı
        return DateFormat('yyyy-MM-dd').parseStrict(dateString);
      }
    }

    // DateTime.parse() ISO 8601 formatını otomatik handle eder
    // (2026-11-06T00:00:00.000000Z gibi)
    return DateTime.parse(dateString);
  } catch (e) {
    // Hata durumunda debug bilgisi ver ve varsayılan tarih döndür
    debugPrint('⚠️ Tarih parse hatası: "$dateString" - $e');
    return DateTime(1900);
  }
}

Future<List<Movie>> fetchMovies(String url) async {
  try {
    // Web'le aynı endpoint kullan - basit ve temiz JSON döndürür
    final response = await http.get(
      Uri.parse(url),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('İstek zaman aşımına uğradı');
      },
    );

    if (response.statusCode != 200) {
      debugPrint('⚠️ HTTP hatası: ${response.statusCode}');
      return [];
    }

    if (response.body.isEmpty) {
      return [];
    }

    // JSON parse - web'deki gibi basit
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Response yapısını kontrol et
    if (data['success'] != true && data['success'] != null) {
      return [];
    }

    // Film listesini al: data.data.data (paginated response)
    List<dynamic> moviesJson = [];
    if (data['data'] is Map<String, dynamic>) {
      final dataMap = data['data'] as Map<String, dynamic>;
      if (dataMap['data'] is List) {
        moviesJson = dataMap['data'] as List<dynamic>;
      }
    } else if (data['data'] is List) {
      // Eğer direkt array ise
      moviesJson = data['data'] as List<dynamic>;
    }

    // Filmleri parse et - hatalı olanları atla
    List<Movie> movies = [];
    for (var json in moviesJson) {
      try {
        if (json is Map<String, dynamic>) {
          movies.add(Movie.fromJson(json));
        }
      } catch (e) {
        debugPrint('⚠️ Film parse hatası (atlandı): $e');
        continue;
      }
    }

    return movies;
  } on TimeoutException {
    debugPrint('⚠️ Request timeout');
    return [];
  } on FormatException catch (e) {
    debugPrint('⚠️ JSON parse hatası: $e');
    return [];
  } catch (e) {
    debugPrint('⚠️ fetchMovies hatası: $e');
    return [];
  }
}

String sanitizeJsonString(String input) {
  var result = input;

  // Octal kaçışlarını (ör. \013) Unicode biçimine çevir
  result = result.replaceAllMapped(RegExp(r'\\([0-7]{1,3})'), (match) {
    final octal = match.group(1);
    if (octal == null) {
      return match.group(0) ?? '';
    }

    final intValue = int.tryParse(octal, radix: 8);
    if (intValue == null) {
      return match.group(0) ?? '';
    }

    final hex = intValue.toRadixString(16).padLeft(4, '0');
    return '\\u$hex';
  });

  // Eksik uzunluktaki Unicode kaçışlarını tamamla (ör. \u013 => \u0013)
  result = result.replaceAllMapped(
    RegExp(r'\\u([0-9A-Fa-f]{1,3})(?![0-9A-Fa-f])'),
    (match) {
      final hexDigits = match.group(1);
      if (hexDigits == null) {
        return match.group(0) ?? '';
      }

      final padded = hexDigits.padLeft(4, '0');
      return '\\u$padded';
    },
  );

  // Eksik virgül düzeltmeleri (ör. "id":83"title" => "id":83,"title")
  result = result.replaceAllMapped(
    RegExp(r'":(\d+)"([a-zA-Z_][a-zA-Z0-9_]*)'),
    (match) {
      return '":${match.group(1)},"${match.group(2)}';
    },
  );

  // Eksik başlangıç tırnağı düzeltmeleri (ör. "name":Salon 3" => "name":"Salon 3")
  // Pattern: "key":value" şeklindeki hataları düzelt (değer tırnak içinde değil ama sonunda tırnak var)
  result = result.replaceAllMapped(
    RegExp(r'"([a-zA-Z_][a-zA-Z0-9_]*)"\s*:\s*([^",}\[\]]+?)"([,}\]])'),
    (match) {
      final key = match.group(1);
      final value = match.group(2);
      final ending = match.group(3);
      if (key != null && value != null && ending != null) {
        final trimmedValue = value.trim();
        // Eğer değer sayı, boolean veya null değilse, tırnak ekle
        if (int.tryParse(trimmedValue) == null &&
            double.tryParse(trimmedValue) == null &&
            trimmedValue != 'true' &&
            trimmedValue != 'false' &&
            trimmedValue != 'null' &&
            !trimmedValue.startsWith('{') &&
            !trimmedValue.startsWith('[') &&
            !trimmedValue.startsWith('"')) {
          return '"$key":"$trimmedValue"$ending';
        }
      }
      return match.group(0) ?? '';
    },
  );

  // Eksik başlangıç tırnağı düzeltmeleri (ör. hall_id":183 => "hall_id":183)
  // Pattern: key":value şeklindeki hataları düzelt (key tırnak içinde değil)
  result = result.replaceAllMapped(
    RegExp(r'([a-zA-Z_][a-zA-Z0-9_]*)"\s*:\s*([^",}\[\]]+?)([,}\]])'),
    (match) {
      final key = match.group(1);
      final value = match.group(2);
      final ending = match.group(3);
      if (key != null && value != null && ending != null) {
        // Eğer key tırnak içinde değilse, tırnak ekle
        if (!key.startsWith('"')) {
          return '"$key":$value$ending';
        }
      }
      return match.group(0) ?? '';
    },
  );

  // Eksik başlangıç tırnağı düzeltmeleri (ör. "title":Miraculous World => "title":"Miraculous World")
  // Pattern: "key":value şeklindeki hataları düzelt (değer tırnak içinde değil ve sonunda tırnak yok)
  result = result.replaceAllMapped(
    RegExp(r'"([a-zA-Z_][a-zA-Z0-9_]*)"\s*:\s*([A-Za-z][^",}\[\]]*?)([,}\]])'),
    (match) {
      final key = match.group(1);
      final value = match.group(2);
      final ending = match.group(3);
      if (key != null && value != null && ending != null) {
        final trimmedValue = value.trim();
        // Eğer değer sayı, boolean veya null değilse, tırnak ekle
        if (int.tryParse(trimmedValue) == null &&
            double.tryParse(trimmedValue) == null &&
            trimmedValue != 'true' &&
            trimmedValue != 'false' &&
            trimmedValue != 'null' &&
            !trimmedValue.startsWith('{') &&
            !trimmedValue.startsWith('[') &&
            !trimmedValue.startsWith('"')) {
          return '"$key":"$trimmedValue"$ending';
        }
      }
      return match.group(0) ?? '';
    },
  );

  // Eksik değer düzeltmeleri (ör. "description":","duration" => "description":"","duration")
  result = result.replaceAllMapped(
    RegExp(r'"([a-zA-Z_][a-zA-Z0-9_]*)"\s*:\s*,\s*"([a-zA-Z_][a-zA-Z0-9_]*)'),
    (match) {
      final key1 = match.group(1);
      final key2 = match.group(2);
      if (key1 != null && key2 != null) {
        return '"$key1":"","$key2';
      }
      return match.group(0) ?? '';
    },
  );

  // Yinelenen çift tırnakları tek tırnak haline getir (ama sadece yan yana olanları)
  // ""key" şeklindeki durumları düzelt
  result = result.replaceAllMapped(RegExp(r'""([a-zA-Z_][a-zA-Z0-9_]*)'), (
    match,
  ) {
    final key = match.group(1);
    if (key != null) {
      return '"$key';
    }
    return match.group(0) ?? '';
  });

  // Başlangıçtaki çift tırnakları düzelt (ör. {""success" => {"success")
  result = result.replaceAllMapped(RegExp(r'\{""([a-zA-Z_][a-zA-Z0-9_]*)'), (
    match,
  ) {
    final key = match.group(1);
    if (key != null) {
      return '{"$key';
    }
    return match.group(0) ?? '';
  });

  return result;
}
