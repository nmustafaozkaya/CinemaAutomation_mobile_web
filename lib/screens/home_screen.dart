import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/auto_image_slider.dart';
import 'package:sinema_uygulamasi/components/promotions_screen.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';
import 'package:sinema_uygulamasi/components/get_promotions.dart';
import 'package:sinema_uygulamasi/screens/movies_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

Widget buildMoviePoster(String posterUrl) {
  // Poster URL'ini temizle ve kontrol et
  if (posterUrl.isEmpty ||
      posterUrl == 'N/A' ||
      posterUrl.trim().isEmpty ||
      posterUrl == 'null') {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }

  // URL'yi çözümle
  final resolvedUrl = ApiConnection.resolveMediaUrl(posterUrl);

  // Geçerli URL kontrolü - http/https ile başlamalı
  final isValidUrl =
      resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://');

  if (!isValidUrl) {
    debugPrint('Invalid poster URL: $resolvedUrl');
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }

  return Image.network(
    resolvedUrl,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        color: Colors.grey.shade300,
        child: Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      debugPrint('Poster load error: $error - URL: $resolvedUrl');
      return Container(
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
        ),
      );
    },
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Movie>> _nowShowingMoviesFuture;
  late Future<List<Movie>> _comingSoonMoviesFuture;
  static const int _maxRetries = 3;
  int _loadCounter = 0; // Her yüklemede artırılacak counter

  @override
  void initState() {
    super.initState();
    _loadDistributedMovies();
  }

  void _loadDistributedMovies() {
    // Distributed API'yi kullan - toplam 100 filmi tarihe göre dağıtır
    // Cache-busting için timestamp ekle - her çağrıda yeni timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    String url = '${ApiConnection.distributedMovies}?_t=$timestamp';

    // Counter'ı artır - FutureBuilder key'lerini güncellemek için
    _loadCounter++;

    // Future'ları her seferinde yeniden oluştur - cache'i bypass et
    if (mounted) {
      setState(() {
        _nowShowingMoviesFuture = _fetchDistributedMovies(url, true);
        _comingSoonMoviesFuture = _fetchDistributedMovies(url, false);
      });
    } else {
      // initState içindeyse setState olmadan direkt atama yap
      _nowShowingMoviesFuture = _fetchDistributedMovies(url, true);
      _comingSoonMoviesFuture = _fetchDistributedMovies(url, false);
    }
  }

  Future<List<Movie>> _fetchDistributedMovies(
    String url,
    bool isNowShowing, {
    int retryAttempt = 0,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Cache-Control': 'no-cache',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        try {
          // JSON string'i temizle - Unicode ve escape karakterlerini düzelt
          String cleanedJson = sanitizeJsonString(response.body);
          
          // "Unexpected end of input" hatasını kontrol et - JSON eksik/kesik olabilir
          if (cleanedJson.trim().isEmpty || 
              (!cleanedJson.trim().endsWith('}') && !cleanedJson.trim().endsWith(']'))) {
            debugPrint('⚠️ JSON eksik görünüyor, retrying...');
            if (retryAttempt < _maxRetries) {
              await Future.delayed(
                Duration(milliseconds: 500 * (retryAttempt + 1)),
              );
              return _fetchDistributedMovies(
                url,
                isNowShowing,
                retryAttempt: retryAttempt + 1,
              );
            }
            return [];
          }
          
          // JSON parse - temizlenmiş JSON'u kullan
          Map<String, dynamic> data;
          try {
            data = jsonDecode(cleanedJson) as Map<String, dynamic>;
          } catch (e) {
            debugPrint('⚠️ JSON parse hatası (sanitize sonrası): $e');
            // Eğer sanitize sonrası da parse edilemezse, orijinal JSON'u dene
            try {
              data = jsonDecode(response.body) as Map<String, dynamic>;
            } catch (e2) {
              debugPrint('⚠️ Orijinal JSON da parse edilemedi: $e2');
              rethrow;
            }
          }

          if (data['success'] == true && data['data'] != null) {
            final responseData = data['data'] as Map<String, dynamic>;

            if (isNowShowing) {
              final nowShowingData =
                  responseData['now_showing'] as Map<String, dynamic>?;
              final moviesJson =
                  nowShowingData?['data'] as List<dynamic>? ?? [];
              final movies = moviesJson
                  .map((json) {
                    try {
                      return Movie.fromJson(json as Map<String, dynamic>);
                    } catch (e) {
                      debugPrint('⚠️ Movie parse error: $e');
                      return null;
                    }
                  })
                  .whereType<Movie>()
                  .toList();
              return movies;
            } else {
              final comingSoonData =
                  responseData['coming_soon'] as Map<String, dynamic>?;
              final moviesJson =
                  comingSoonData?['data'] as List<dynamic>? ?? [];
              final movies = moviesJson
                  .map((json) {
                    try {
                      return Movie.fromJson(json as Map<String, dynamic>);
                    } catch (e) {
                      debugPrint('⚠️ Movie parse error: $e');
                      return null;
                    }
                  })
                  .whereType<Movie>()
                  .toList();
              return movies;
            }
          }
        } catch (e) {
          debugPrint('⚠️ JSON parse error: $e');
          // JSON parse hatası - retry yap
          if (retryAttempt < _maxRetries) {
            debugPrint(
              '⚠️ Retrying... (${retryAttempt + 1}/$_maxRetries)',
            );
            await Future.delayed(
              Duration(milliseconds: 500 * (retryAttempt + 1)),
            );
            return _fetchDistributedMovies(
              url,
              isNowShowing,
              retryAttempt: retryAttempt + 1,
            );
          }
        }
      } else if (response.statusCode != 200) {
        debugPrint('⚠️ HTTP error: ${response.statusCode}');
        // HTTP hatası - retry yap
        if (retryAttempt < _maxRetries) {
          debugPrint(
            '⚠️ Retrying... (${retryAttempt + 1}/$_maxRetries)',
          );
          await Future.delayed(
            Duration(milliseconds: 500 * (retryAttempt + 1)),
          );
          return _fetchDistributedMovies(
            url,
            isNowShowing,
            retryAttempt: retryAttempt + 1,
          );
        }
      }
      return [];
    } on TimeoutException catch (e) {
      debugPrint('⚠️ Timeout error: $e');
      // Timeout - retry yap
      if (retryAttempt < _maxRetries) {
        debugPrint('⚠️ Retrying... (${retryAttempt + 1}/$_maxRetries)');
        await Future.delayed(Duration(milliseconds: 500 * (retryAttempt + 1)));
        return _fetchDistributedMovies(
          url,
          isNowShowing,
          retryAttempt: retryAttempt + 1,
        );
      }
      return [];
    } catch (e) {
      debugPrint('⚠️ _fetchDistributedMovies error: $e');
      // Diğer hatalar - retry yap
      if (retryAttempt < _maxRetries) {
        debugPrint('⚠️ Retrying... (${retryAttempt + 1}/$_maxRetries)');
        await Future.delayed(Duration(milliseconds: 500 * (retryAttempt + 1)));
        return _fetchDistributedMovies(
          url,
          isNowShowing,
          retryAttempt: retryAttempt + 1,
        );
      }
      return [];
    }
  }

  // Vizyondaki Filmler bölümü
  Widget showMoviesContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Vizyondaki Filmler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MoviesScreen(isComingSoon: false),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: AppColorStyle.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
            const SizedBox(height: 10),
        FutureBuilder<List<Movie>>(
          key: ValueKey('now_showing_$_loadCounter'),
          future: _nowShowingMoviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hata: ${snapshot.error}",
                      style: const TextStyle(
                        color: AppColorStyle.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadDistributedMovies();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorStyle.primaryAccent,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Film bulunamadı.",
                      style: TextStyle(color: AppColorStyle.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadDistributedMovies();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorStyle.primaryAccent,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final movies = snapshot.data!;
              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetails(
                              currentMovie: movie,
                              isNowShowing: true,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: buildMoviePoster(movie.poster),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  // Çok Yakındaki Filmler bölümü
  Widget showMoviesComingSoon(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Yakında Gelecek Filmler',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const MoviesScreen(isComingSoon: true),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: AppColorStyle.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Movie>>(
          key: ValueKey('coming_soon_$_loadCounter'),
          future: _comingSoonMoviesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hata: ${snapshot.error}",
                      style: const TextStyle(
                        color: AppColorStyle.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadDistributedMovies();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorStyle.primaryAccent,
                      ),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return SizedBox(
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Film bulunamadı.",
                      style: TextStyle(color: AppColorStyle.textSecondary),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loadDistributedMovies();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorStyle.primaryAccent,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final movies = snapshot.data!;
              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetails(
                              currentMovie: movie,
                              isNowShowing: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: buildMoviePoster(movie.poster),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget showpromotions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Kampanyalar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PromotionsScreen(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    fontSize: 20,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: AppColorStyle.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        FutureBuilder<List<Promotion>>(
          future: fetchPromotions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            } else {
              final promotions = snapshot.data!;
              return SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: promotions.length,
                  itemBuilder: (context, index) {
                    final promotion = promotions[index];
                    return HorizontalPromotionCard(promotion: promotion);
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColorStyle.appBarColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: Colors.black,
            );
          },
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: SizedBox(
            height: AppBar().preferredSize.height * 0.8,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Filmleri Keşfet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AutoImageSlider(),
                  const SizedBox(height: 10),
                  showMoviesContent(context),
                  const SizedBox(height: 20),
                  showMoviesComingSoon(context),
                  const SizedBox(height: 20),
                  showpromotions(context),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 150.0,
              width: double.infinity,
              color: Colors.lightBlueAccent.shade100,
              padding: const EdgeInsets.only(
                left: 16.0,
                top: 16.0,
                bottom: 8.0,
              ),
              alignment: Alignment.bottomLeft,
              child: Image.asset(
                'assets/images/logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PromotionsScreen(),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: const Icon(FontAwesomeIcons.gift),
                      title: const Text('Kampanyalar'),
                      trailing: const Icon(Icons.arrow_right),
                    ),
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.adjust),
                    title: const Text('Hakkımızda'),
                    trailing: const Icon(Icons.arrow_drop_down),
                    children: [
                      ListTile(
                        title: const Text('Biz Kimiz?'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Sertifikalarımız'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: const Text('Misyonumuz'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
