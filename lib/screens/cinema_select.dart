import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/components/movies.dart' show Movie;
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/screens/showtimes_screen.dart';
import 'package:sinema_uygulamasi/screens/cinema_movies_screen.dart';

class CinemaSelect extends StatefulWidget {
  final Movie? currentMovie2;

  const CinemaSelect({super.key, this.currentMovie2});

  @override
  State<CinemaSelect> createState() => _CinemaSelectState();
}

class _CinemaSelectState extends State<CinemaSelect> {
  List<Cinema> _allCinemas = [];
  List<Cinema> _filteredCinemas = [];
  List<String> _cities = ['All'];
  String _selectedCity = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  Map<int, String> _cityIdToNameMap = {}; // City ID to name mapping
  int _totalShowtimes = 0;

  @override
  void initState() {
    super.initState();
    _loadCities().then((_) {
      if (widget.currentMovie2 != null) {
        fetchCinemasForMovie();
      } else {
        fetchAllCinemas();
      }
    });
  }

  // Şehirleri API'den yükle
  Future<void> _loadCities() async {
    try {
      final uri = Uri.parse(ApiConnection.cities);
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final List<dynamic> citiesData = jsonResponse['data'];
          final cityMap = <int, String>{};
          
          for (final cityData in citiesData) {
            if (cityData['id'] != null && cityData['name'] != null) {
              cityMap[cityData['id'] as int] = cityData['name'] as String;
            }
          }
          
          setState(() {
            _cityIdToNameMap = cityMap;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading cities: $e');
      // Hata durumunda varsayılan şehirleri kullan
      _cityIdToNameMap = {
        1: 'Istanbul',
        2: 'Ankara',
        3: 'Afyonkarahisar',
        4: 'Izmir',
        5: 'Bursa',
      };
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCinemasForMovie() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final movieId = widget.currentMovie2!.id;
      
      // Web'in kullandığı endpoint - daha temiz ve doğru JSON döndürüyor
      final uri = Uri.parse('${ApiConnection.cinemas}/showing/$movieId');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

      if (jsonResponse['success'] != true || jsonResponse['data'] == null) {
        setState(() {
          _error = jsonResponse['message'] ??
              'No cinemas showing this movie.';
          _isLoading = false;
        });
        return;
      }

      // Data is now directly cinema list
      final List<dynamic> cinemasData = jsonResponse['data'] as List<dynamic>;
      
      if (cinemasData.isEmpty) {
        setState(() {
          _error = "No cinemas showing this movie.";
          _isLoading = false;
        });
        return;
      }

      // Sinemalar zaten temiz JSON olarak geliyor, complex parsing'e gerek yok
      final List<Cinema> cinemas = [];
      final Set<String> cityNames = {};

      for (final cinemaData in cinemasData) {
        try {
          final cinema = Cinema.fromJson(cinemaData as Map<String, dynamic>);
          cinemas.add(cinema);
          
          // Şehir isimlerini topla
          if (cinema.cityName.isNotEmpty && 
              cinema.cityName != 'Bilinmeyen' && 
              cinema.cityName != 'Bilinmeyen Şehir') {
            cityNames.add(cinema.cityName);
          }
        } catch (e) {
          debugPrint('Cinema parse hatası: $e');
          continue;
        }
      }

      if (cinemas.isEmpty) {
        setState(() {
          _error = "Bu filmi gösteren sinema bulunmuyor.";
          _isLoading = false;
        });
        return;
      }

      final sortedCities = cityNames.toList()..sort();
      cinemas.sort((a, b) => a.cinemaName.compareTo(b.cinemaName));

      setState(() {
        _allCinemas = cinemas;
        _filteredCinemas = cinemas;
        _cities = ['All', ...sortedCities];
        _isLoading = false;
      });
      
    } catch (e) {
      debugPrint('fetchCinemasForMovie error: $e');
      setState(() {
        _error = 'Failed to load cinema information: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> fetchAllCinemas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final client = http.Client();

      try {
        final uri = Uri.parse('${ApiConnection.showtimes}?_t=${DateTime.now().millisecondsSinceEpoch}');
        
        final request = http.Request('GET', uri);
        request.headers['Accept'] = 'application/json';
        request.headers['Content-Type'] = 'application/json';

        final streamedResponse = await client
            .send(request)
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('Request timed out. Please try again.');
              },
            );

        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          throw Exception(
            'Server error: ${response.statusCode}. '
            'Response: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
          );
        }

        if (response.bodyBytes.isEmpty) {
          setState(() {
            _isLoading = false;
            _error = "No cinemas found yet.";
          });
          return;
        }

        String decodedBody;
        try {
          // UTF-8 decode - allowMalformed true yaparak bozuk karakterleri atla
          decodedBody = utf8.decode(response.bodyBytes, allowMalformed: true);
        } catch (e) {
          // UTF-8 decode başarısız olursa alternatif olarak response.body kullan
          try {
            decodedBody = response.body;
          } catch (e2) {
            throw Exception('Response could not be decoded: ${e.toString()}');
          }
        }

        // JSON'un tam olduğunu kontrol et
        if (decodedBody.trim().isEmpty) {
          setState(() {
            _isLoading = false;
            _error = "No cinemas found yet.";
          });
          return;
        }

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
        } on FormatException catch (e) {
          debugPrint('❌ JSON parse error: ${e.message}');
          debugPrint('Response length: ${decodedBody.length} characters');
          if (e.offset != null && e.offset! < decodedBody.length) {
            final start = (e.offset! - 100).clamp(0, decodedBody.length);
            final end = (e.offset! + 100).clamp(0, decodedBody.length);
            debugPrint('Error position: ${e.offset}, context: ${decodedBody.substring(start, end)}');
          }
          throw Exception('JSON parse error: ${e.message}');
        }

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          await _processCinemaData(jsonResponse['data']);
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'API response format was unexpected.',
          );
        }
      } finally {
        client.close();
      }
    } on http.ClientException catch (e) {
      setState(() {
        _error = 'Connection error: ${e.message}';
        _isLoading = false;
      });
    } on FormatException catch (e) {
      setState(() {
        _error = 'Data format error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('fetchAllCinemas error: $e');
      setState(() {
        _error = 'Failed to load cinema information: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _processCinemaData(dynamic data) async {
    List<dynamic> showtimesList = [];

    if (data is Map && data.containsKey('data')) {
      showtimesList = data['data'] ?? [];
    } else if (data is List) {
      showtimesList = data;
    } else {
      throw Exception('Unexpected data format');
    }

    if (showtimesList.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = "No cinemas found yet.";
      });
      return;
    }

    final Map<int, Map<String, dynamic>> uniqueCinemas = {};
    final Set<String> cityNames = {};

    for (final showtime in showtimesList) {
      try {
        if (showtime == null ||
            showtime['hall'] == null ||
            showtime['hall']['cinema'] == null) {
          continue;
        }

        final cinemaData = Map<String, dynamic>.from(
          showtime['hall']['cinema'],
        );
        final cinemaId = cinemaData['id'];

        if (cinemaId == null) continue;

        if (!uniqueCinemas.containsKey(cinemaId)) {
          // Şehir bilgisini düzelt
          if (cinemaData['city_id'] != null) {
            final cityId = cinemaData['city_id'] is int 
                ? cinemaData['city_id'] 
                : int.tryParse(cinemaData['city_id'].toString());
            
            if (cinemaData['city'] == null || cinemaData['city']['name'] == null) {
              final cityName = _cityIdToNameMap[cityId] ?? 
                  (cinemaData['city']?['name'] ?? 'Bilinmeyen');
              cinemaData['city'] = {
                'id': cityId,
                'name': cityName,
              };
            }
          } else if (cinemaData['city'] == null) {
            // city_id yoksa ve city de yoksa atla
            continue;
          }

          uniqueCinemas[cinemaId] = cinemaData;

          final cityName = cinemaData['city']?['name'] ?? 'Bilinmeyen';
          if (cityName != 'Bilinmeyen') {
            cityNames.add(cityName);
          }
        }
      } catch (e) {
        continue;
      }
    }

    final List<Cinema> cinemas = [];
    for (final cinemaData in uniqueCinemas.values) {
      try {
        final cinema = Cinema.fromJson(cinemaData);
        cinemas.add(cinema);
      } catch (e) {
        continue;
      }
    }

    // "Bilinmeyen" şehirleri filtrele
    final validCities = cityNames.where((city) => 
      city.isNotEmpty && 
      city != 'Bilinmeyen' && 
      city != 'Bilinmeyen Şehir'
    ).toList();
    
    final sortedCities = validCities..sort();

    cinemas.sort((a, b) => a.cinemaName.compareTo(b.cinemaName));

    setState(() {
      _allCinemas = cinemas;
      _filteredCinemas = cinemas;
      _cities = ['All', ...sortedCities];
      _totalShowtimes = showtimesList.length;
      _isLoading = false;
    });
  }

  void _filterCinemas(String query) {
    final searchLower = query.toLowerCase();

    final filtered = _allCinemas.where((cinema) {
      final matchesSearch =
          cinema.cinemaName.toLowerCase().contains(searchLower) ||
          cinema.cinemaAddress.toLowerCase().contains(searchLower);
      final matchesCity =
          _selectedCity == 'All' || cinema.cityName == _selectedCity;

      return matchesSearch && matchesCity;
    }).toList();

    filtered.sort((a, b) => a.cinemaName.compareTo(b.cinemaName));

    setState(() {
      _filteredCinemas = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          widget.currentMovie2 != null
              ? '${widget.currentMovie2!.title} - Cinema Selection'
              : 'Cinema Selection',
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
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColorStyle.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColorStyle.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.currentMovie2 != null) {
                          fetchCinemasForMovie();
                        } else {
                          fetchAllCinemas();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorStyle.primaryAccent,
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(color: AppColorStyle.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Header showing cinema count
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Found ${_filteredCinemas.length} cinemas ($_totalShowtimes showtimes)',
                    style: const TextStyle(
                      color: AppColorStyle.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    dropdownColor: AppColorStyle.appBarColor,
                    style: const TextStyle(color: AppColorStyle.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Filter by City',
                      labelStyle: TextStyle(color: AppColorStyle.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.primaryAccent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.secondaryAccent,
                        ),
                      ),
                    ),
                    items: _cities
                        .map(
                          (city) =>
                              DropdownMenuItem(value: city, child: Text(city)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCity = value);
                        _filterCinemas(_searchController.text);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppColorStyle.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Search cinema...',
                      hintStyle: TextStyle(color: AppColorStyle.textSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColorStyle.textSecondary,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.primaryAccent,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.secondaryAccent,
                        ),
                      ),
                    ),
                    onChanged: _filterCinemas,
                  ),
                ),
                Expanded(
                  child: _filteredCinemas.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColorStyle.textSecondary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No cinema matches your search.',
                                style: TextStyle(
                                  color: AppColorStyle.textPrimary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _filteredCinemas.length,
                          itemBuilder: (context, index) {
                            final cinema = _filteredCinemas[index];
                            return Card(
                              color: AppColorStyle.appBarColor,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                onTap: () {
                                  if (widget.currentMovie2 != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowtimesScreen(
                                          selectedCinema: cinema,
                                          currentMovie: widget.currentMovie2!,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Sinema seçildiğinde o sinemadaki tüm filmleri göster
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CinemaMoviesScreen(
                                          selectedCinema: cinema,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                leading: const CircleAvatar(
                                  backgroundColor: AppColorStyle.primaryAccent,
                                  child: Icon(
                                    Icons.movie,
                                    color: AppColorStyle.textPrimary,
                                  ),
                                ),
                                title: Text(
                                  cinema.cinemaName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColorStyle.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${cinema.cityName} • ${cinema.cinemaAddress}',
                                  style: const TextStyle(
                                    color: AppColorStyle.textSecondary,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColorStyle.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
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
