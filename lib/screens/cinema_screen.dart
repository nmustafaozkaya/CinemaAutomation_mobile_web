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

  Future<void> fetchCinemas() async {
    try {
      final client = http.Client();

      try {
        final request = http.Request('GET', Uri.parse(ApiConnection.cinemas));
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

        if (response.statusCode == 200) {
          // Response body'nin tam olduğundan emin ol
          if (response.bodyBytes.isEmpty) {
            throw Exception('Sunucudan boş yanıt alındı.');
          }

          // UTF-8 decoding
          String decodedBody;
          try {
            decodedBody = utf8.decode(
              response.bodyBytes,
              allowMalformed: false,
            );
          } catch (e) {
            // UTF-8 decode hatası durumunda alternatif
            decodedBody = response.body;
          }

          // JSON'un tam olduğunu kontrol et
          if (decodedBody.trim().isEmpty) {
            throw Exception('Sunucudan boş yanıt alındı.');
          }

          // JSON parse etme
          Map<String, dynamic> jsonResponse;
          try {
            jsonResponse = json.decode(decodedBody) as Map<String, dynamic>;
          } on FormatException catch (e) {
            // JSON parse hatası - response'u logla (debug için)
            throw Exception(
              'JSON parse hatası: ${e.message}. '
              'Response uzunluğu: ${decodedBody.length} karakter. '
              'Son 200 karakter: ${decodedBody.length > 200 ? decodedBody.substring(decodedBody.length - 200) : decodedBody}',
            );
          }

          if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
            final List<dynamic> data = jsonResponse['data'];

            // Cinema nesnelerini güvenli bir şekilde oluştur
            final cinemas = <Cinema>[];
            for (final cinemaJson in data) {
              try {
                if (cinemaJson is Map<String, dynamic>) {
                  cinemas.add(Cinema.fromJson(cinemaJson));
                }
              } catch (e) {
                // Tek bir sinema parse edilemezse atla ve devam et
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

            // Şehir adından cityId'ye map oluştur
            final cityNameToIdMap = <String, int>{};
            for (final cinema in cinemas) {
              if (cinema.cityName.isNotEmpty &&
                  cinema.cityName != 'Bilinmeyen' &&
                  cinema.cityName != 'Bilinmeyen Şehir' &&
                  !cityNameToIdMap.containsKey(cinema.cityName)) {
                cityNameToIdMap[cinema.cityName] = cinema.cityId;
              }
            }

            setState(() {
              _allCinemas = cinemas;
              _filteredCinemas = cinemas;
              _cities = ['All', ...cityNames];
              _cityNameToIdMap = cityNameToIdMap;
              _isLoading = false;
              _error = null;
            });
          } else {
            throw Exception(
              'Beklenmeyen API yanıtı formatı. '
              'Success: ${jsonResponse['success']}, '
              'Data tipi: ${jsonResponse['data']?.runtimeType}',
            );
          }
        } else {
          throw Exception(
            'Sunucu hatası: ${response.statusCode}. '
            'Yanıt: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
          );
        }
      } finally {
        client.close();
      }
    } on http.ClientException catch (e) {
      setState(() {
        _error = 'Bağlantı hatası: ${e.message}';
        _isLoading = false;
      });
    } on FormatException catch (e) {
      setState(() {
        _error = 'Veri formatı hatası: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Hata: ${e.toString()}';
        _isLoading = false;
      });
    }
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

    setState(() {
      _filteredCinemas = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColorStyle.appBarColor,
        title: const Text(
          'Sinema Salonları',
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
                'Hata: $_error',
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
                      labelText: 'Şehre Göre Filtrele',
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
                      if (value != null) {
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
                      hintText: 'Sinema ara...',
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
                            'Aramanıza uygun sinema bulunamadı.',
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
