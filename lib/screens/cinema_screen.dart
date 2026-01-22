import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/city_filter_provider.dart';
import 'package:sinema_uygulamasi/screens/cinema_movies_screen.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  List<Cinema> _allCinemas = [];
  List<Cinema> _filteredCinemas = [];
  List<String> _cities = ['All'];
  String _selectedCity = 'All';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _error;
  final CityFilterProvider _cityFilter = CityFilterProvider();

  // Şehir adından cityId'yi bulmak için map
  Map<String, int> _cityNameToIdMap = {};

  @override
  void initState() {
    super.initState();
    fetchCinemas();
  }

  /// Bazı sunucu/HTTP kombinasyonlarında JSON'un sonundaki `}` eksik gelebiliyor.
  /// Bu yardımcı fonksiyon, basit durumlarda eksik süslü parantezi ekleyip tekrar denememizi sağlar.
  String _tryFixJson(String body) {
    final trimmed = body.trimRight();

    // Örnek beklenen yapı: {"success":true,"message":"...","data":[...]}
    // Eğer `]` ile bitiyor ama dıştaki `}` yoksa, sona `}` ekleyip dön.
    if (!trimmed.endsWith('}') && trimmed.endsWith(']')) {
      return '$trimmed}';
    }

    return trimmed;
  }

  Future<void> fetchCinemas() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConnection.cinemas),
            headers: const {'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out. Please try again.');
            },
          );

      if (response.statusCode != 200) {
        throw Exception(
          'Server error: ${response.statusCode}. '
          'Response: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
        );
      }

      if (response.body.trim().isEmpty) {
        throw Exception('Server returned an empty response.');
      }

      Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      } on FormatException {
        // İlk deneme başarısızsa, basit JSON tamamlama denemesi yap
        final fixed = _tryFixJson(response.body);
        try {
          jsonResponse = json.decode(fixed) as Map<String, dynamic>;
        } on FormatException catch (e) {
          throw Exception(
            'JSON parse error: ${e.message}. '
            'Response length: ${response.body.length} characters. '
            'Last 200 chars: ${response.body.length > 200 ? response.body.substring(response.body.length - 200) : response.body}',
          );
        }
      }

      if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
        final List<dynamic> data = jsonResponse['data'];

        final cinemas = <Cinema>[];
        for (final cinemaJson in data) {
          try {
            if (cinemaJson is Map<String, dynamic>) {
              cinemas.add(Cinema.fromJson(cinemaJson));
            }
          } catch (e) {
            debugPrint('Sinema parse hatası: $e');
            continue;
          }
        }

        final cityNames =
            cinemas
                .map((e) => e.cityName)
                .where(
                  (name) =>
                      name.isNotEmpty &&
                      name != 'Bilinmeyen' &&
                      name != 'Bilinmeyen Şehir',
                )
                .toSet()
                .toList()
              ..sort();

        final cityNameToIdMap = <String, int>{};
        for (final cinema in cinemas) {
          if (cinema.cityName.isNotEmpty &&
              cinema.cityName != 'Bilinmeyen' &&
              cinema.cityName != 'Bilinmeyen Şehir' &&
              !cityNameToIdMap.containsKey(cinema.cityName)) {
            cityNameToIdMap[cinema.cityName] = cinema.cityId;
          }
        }

        if (mounted) {
          setState(() {
            _allCinemas = cinemas;
            _filteredCinemas = cinemas;
            _cities = ['All', ...cityNames];
            _cityNameToIdMap = cityNameToIdMap;
            _isLoading = false;
            _error = null;
          });
        }
      } else {
        throw Exception(
          'Unexpected API response format. '
          'Success: ${jsonResponse['success']}, '
          'Data type: ${jsonResponse['data']?.runtimeType}',
        );
      }
    } on http.ClientException catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection error: ${e.message}';
          _isLoading = false;
        });
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Data format error: ${e.message}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _filterCinemas(String query) {
    if (!mounted) return;

    final searchLower = query.toLowerCase();

    final filtered = _allCinemas.where((cinema) {
      final matchesSearch =
          cinema.cinemaName.toLowerCase().contains(searchLower) ||
          cinema.cinemaAddress.toLowerCase().contains(searchLower);
      final matchesCity =
          _selectedCity == 'All' || cinema.cityName == _selectedCity;

      return matchesSearch && matchesCity;
    }).toList();

    if (mounted) {
      setState(() {
        _filteredCinemas = filtered;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColorStyle.appBarColor,
        title: const Text(
          'Cinemas and Halls',
          style: TextStyle(
            color: AppColorStyle.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
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
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: AppColorStyle.textPrimary),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    dropdownColor: AppColorStyle.appBarColor,
                    style: const TextStyle(color: AppColorStyle.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Filter by City',
                      labelStyle: const TextStyle(
                        color: AppColorStyle.textSecondary,
                      ),
                      iconColor: AppColorStyle.textSecondary,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColorStyle.primaryAccent,
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
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
                      if (value != null && mounted) {
                        setState(() => _selectedCity = value);
                        _filterCinemas(_searchController.text);

                        // Şehir seçildiğinde global state'e kaydet
                        if (value == 'All') {
                          _cityFilter.clearCityFilter();
                        } else {
                          // Şehir adından cityId'yi bul
                          final cityId = _cityNameToIdMap[value];
                          if (cityId != null) {
                            _cityFilter.setCityFilter(cityId, value);
                          }
                        }
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
                      hintText: 'Search cinemas...',
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

                // Sinema Listesi
                Expanded(
                  child: _filteredCinemas.isEmpty
                      ? const Center(
                          child: Text(
                            'No cinemas match your search.',
                            style: TextStyle(color: AppColorStyle.textPrimary),
                          ),
                        )
                      : ListView.builder(
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
                                  // Seçilen sinemanın şehir filtresini ayarla
                                  _cityFilter.setCityFilter(
                                    cinema.cityId,
                                    cinema.cityName,
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CinemaMoviesScreen(
                                        selectedCinema: cinema,
                                      ),
                                    ),
                                  );
                                },
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
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
