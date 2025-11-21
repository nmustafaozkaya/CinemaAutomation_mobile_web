import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';

class CinemaMoviesScreen extends StatefulWidget {
  final Cinema selectedCinema;

  const CinemaMoviesScreen({super.key, required this.selectedCinema});

  @override
  State<CinemaMoviesScreen> createState() => _CinemaMoviesScreenState();
}

class _CinemaMoviesScreenState extends State<CinemaMoviesScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMoviesForCinema();
  }

  Future<void> _fetchMoviesForCinema() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final client = http.Client();

      try {
        final uri = Uri.parse(
          '${ApiConnection.showtimes}?cinema_id=${widget.selectedCinema.cinemaId}&_t=${DateTime.now().millisecondsSinceEpoch}',
        );

        final request = http.Request('GET', uri);
        request.headers['Accept'] = 'application/json';
        request.headers['Content-Type'] = 'application/json';

        // Daha uzun timeout süresi (30 saniye)
        final streamedResponse = await client
            .send(request)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception(
                  'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
                );
              },
            );

        // Response'u tam olarak oku
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          throw Exception(
            'Sunucu hatası: ${response.statusCode}. '
            'Yanıt: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
          );
        }

        // Response body'nin tam olduğundan emin ol
        if (response.bodyBytes.isEmpty) {
          setState(() {
            _movies = [];
            _isLoading = false;
          });
          return;
        }

        // UTF-8 decoding - allowMalformed true ile bozuk karakterleri atla
        String decodedBody;
        try {
          decodedBody = utf8.decode(
            response.bodyBytes,
            allowMalformed: true, // Bozuk UTF-8 karakterlerini atla
          );
        } catch (e) {
          // UTF-8 decode hatası durumunda alternatif
          try {
            decodedBody = response.body;
          } catch (e2) {
            throw Exception('Response decode edilemedi: ${e.toString()}');
          }
        }

        // JSON'un tam olduğunu kontrol et
        if (decodedBody.trim().isEmpty) {
          setState(() {
            _movies = [];
            _isLoading = false;
          });
          return;
        }

        // JSON'u güvenli bir şekilde parse et
        Map<String, dynamic> jsonResponse;
        try {
          String cleanedBody = decodedBody.trim();
          
          // Agresif JSON temizleme - yaygın syntax hatalarını düzelt
          cleanedBody = _fixCommonJsonErrors(cleanedBody);
          
          // Eğer JSON tam bitmemişse, son kapanış parantezlerini kontrol et
          if (!cleanedBody.endsWith('}') && !cleanedBody.endsWith(']')) {
            int lastValidBrace = cleanedBody.lastIndexOf('}');
            int lastValidBracket = cleanedBody.lastIndexOf(']');
            int lastValid = lastValidBrace > lastValidBracket ? lastValidBrace : lastValidBracket;
            
            if (lastValid > 0) {
              cleanedBody = cleanedBody.substring(0, lastValid + 1);
              if (cleanedBody.contains('"data":[') && !cleanedBody.endsWith(']}')) {
                cleanedBody = '${cleanedBody.replaceAll(RegExp(r',\s*$'), '')}]}';
              }
            }
          }
          
          jsonResponse = json.decode(cleanedBody) as Map<String, dynamic>;
        } catch (e) {
          if (e is FormatException) {
            debugPrint('❌ JSON parse hatası: ${e.message}');
            debugPrint('Response uzunluğu: ${decodedBody.length} karakter');
            if (e.offset != null && e.offset! < decodedBody.length) {
              final start = (e.offset! - 100).clamp(0, decodedBody.length);
              final end = (e.offset! + 100).clamp(0, decodedBody.length);
              debugPrint('Hata pozisyonu: ${e.offset}, çevresi: ${decodedBody.substring(start, end)}');
            }
          }
          setState(() {
            _errorMessage = 'Filmler alınırken hata oluştu. Lütfen tekrar deneyin.';
            _isLoading = false;
          });
          return;
        }

        if (jsonResponse['success'] != true || jsonResponse['data'] == null) {
          setState(() {
            _movies = [];
            _isLoading = false;
            _errorMessage = jsonResponse['message'] ?? 'Film bulunamadı.';
          });
          return;
        }

        final data = jsonResponse['data'];
        List<dynamic> showtimeList = [];
        
        if (data is List) {
          showtimeList = data;
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          showtimeList = data['data'] as List<dynamic>;
        }

        if (showtimeList.isEmpty) {
          setState(() {
            _movies = [];
            _isLoading = false;
          });
          return;
        }

        // Cinema nesnelerini güvenli bir şekilde oluştur
        final Map<int, Movie> uniqueMovies = {};

        for (final showtime in showtimeList) {
          if (showtime is! Map<String, dynamic>) continue;
          final movieJson = showtime['movie'];
          if (movieJson is! Map<String, dynamic>) continue;

          try {
            final movie = Movie.fromJson(movieJson);
            uniqueMovies[movie.id] = movie;
          } catch (e) {
            debugPrint('Sinema bazlı film parse hatası: $e');
            continue;
          }
        }

        final movies = uniqueMovies.values.toList()
          ..sort((a, b) => a.title.compareTo(b.title));

        setState(() {
          _movies = movies;
          _isLoading = false;
          _errorMessage = null;
        });
      } finally {
        client.close();
      }
    } on http.ClientException catch (e) {
      setState(() {
        _errorMessage = 'Bağlantı hatası: ${e.message}';
        _isLoading = false;
      });
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = 'Veri formatı hatası: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Filmler alınamadı: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildMoviePoster(String posterUrl) {
    final resolvedUrl = ApiConnection.resolveMediaUrl(posterUrl);
    if (posterUrl.isEmpty ||
        posterUrl == 'N/A' ||
        posterUrl.trim().isEmpty ||
        posterUrl == 'null') {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }

    final isValidUrl =
        resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://');

    if (!isValidUrl) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
        ),
      );
    }

    return Image.network(
      resolvedUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
          '${widget.selectedCinema.cinemaName} - Filmler',
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
          : _movies.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.movie_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bu sinemada gösterimde olan film bulunamadı.',
                    style: TextStyle(color: AppColorStyle.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _fetchMoviesForCinema();
                    },
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.6,
              ),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetails(
                          currentMovie: movie,
                          isNowShowing: true,
                          preselectedCinema: widget.selectedCinema,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildMoviePoster(movie.poster),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            movie.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColorStyle.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          movie.runtime,
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 14,
                            color: AppColorStyle.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // JSON syntax hatalarını düzelt
  String _fixCommonJsonErrors(String json) {
    // 1. "id":123"name" -> "id":123,"name" (eksik virgül)
    json = json.replaceAllMapped(
      RegExp(r'(\d+)"([a-zA-Z_]+)'),
      (match) => '${match[1]},"${match[2]}',
    );
    
    // 2. "id":123.45"name" -> "id":123.45,"name" (decimal sayılar için)
    json = json.replaceAllMapped(
      RegExp(r'(\d+\.\d+)"([a-zA-Z_]+)'),
      (match) => '${match[1]},"${match[2]}',
    );
    
    // 3. "}"name" -> },"name" (obje kapanışından sonra virgül eksik)
    json = json.replaceAllMapped(
      RegExp(r'\}"([a-zA-Z_]+)'),
      (match) => '},"${match[1]}',
    );
    
    // 4. "]"name" -> ],"name" (array kapanışından sonra virgül eksik)
    json = json.replaceAllMapped(
      RegExp(r'\]"([a-zA-Z_]+)'),
      (match) => '],"${match[1]}',
    );
    
    // 5. "name":Salon -> "name":"Salon" (value'da tırnak eksik - başta)
    // Dikkatli olmalıyız: true, false, null, number'ları bozmayalım
    json = json.replaceAllMapped(
      RegExp(r'":([A-Z][a-zA-Z0-9\s]+)([,}\]])'),
      (match) {
        final value = match[1]!.trim();
        // true, false, null kontrolü
        if (value == 'true' || value == 'false' || value == 'null') {
          return ':${match[1]}${match[2]}';
        }
        // Sayı kontrolü
        if (RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
          return ':${match[1]}${match[2]}';
        }
        // String olmalı, tırnak ekle
        return ':"$value"${match[2]}';
      },
    );
    
    // 6. Çift colon temizle: :: -> :
    json = json.replaceAll('::', ':');
    
    // 7. Çift virgül temizle: ,, -> ,
    json = json.replaceAll(',,', ',');
    
    return json;
  }
}
