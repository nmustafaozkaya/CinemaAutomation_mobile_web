import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/api_connection/api_connection.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/city_filter_provider.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';

Widget buildMoviePoster(String posterUrl) {
  // Poster URL'ini temizle ve kontrol et
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

  final resolvedUrl = ApiConnection.resolveMediaUrl(posterUrl);

  final isValidUrl =
      resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://');

  if (!isValidUrl) {
    debugPrint('Invalid poster URL: $resolvedUrl');
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
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        color: Colors.grey.shade300,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColorStyle.secondaryAccent,
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
          child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    },
  );
}

Widget _buildMovieGridSliver(
  BuildContext context,
  Future<List<Movie>> moviesFuture,
  bool isNowPlaying,
  VoidCallback? onRetry, {
  Key? key,
}) {
  return FutureBuilder<List<Movie>>(
    key: key, // Unique key ekle - Future değiştiğinde widget yeniden build olur
    future: moviesFuture, // State'ten gelen Future'ı kullan
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              color: AppColorStyle.secondaryAccent,
            ),
          ),
        );
      } else if (snapshot.hasError) {
        debugPrint('MoviesScreen - Error: ${snapshot.error}');
        return SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    style: TextStyle(
                      color: AppColorStyle.textPrimary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.movie_outlined, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "No movies found.",
                  style: TextStyle(color: AppColorStyle.textPrimary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );
      } else {
        final movies = snapshot.data!;
        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final movie = movies[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetails(
                      currentMovie: movie,
                      isNowShowing: isNowPlaying,
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
                        child: buildMoviePoster(movie.poster),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        movie.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColorStyle.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        movie.runtime,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: AppColorStyle.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Text(
                        movie.genre.split(',')[0].trim(),
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 14,
                          color: AppColorStyle.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }, childCount: movies.length),
        );
      }
    },
  );
}

class CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  CategoryHeaderDelegate({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColorStyle.appBarColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onCategorySelected('Now Showing'),
            child: Text(
              'Now Showing',
              style: AppTextStyle.basicHeader.copyWith(
                fontWeight: selectedCategory == 'Now Showing'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selectedCategory == 'Now Showing'
                    ? AppColorStyle.secondaryAccent
                    : AppColorStyle.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onCategorySelected('Coming Soon'),
            child: Text(
              'Coming Soon',
              style: AppTextStyle.basicHeader.copyWith(
                fontWeight: selectedCategory == 'Coming Soon'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: selectedCategory == 'Coming Soon'
                    ? AppColorStyle.secondaryAccent
                    : AppColorStyle.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 48.0;
  @override
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(CategoryHeaderDelegate oldDelegate) {
    return oldDelegate.selectedCategory != selectedCategory;
  }
}

class MoviesScreen extends StatefulWidget {
  final bool isComingSoon;

  const MoviesScreen({super.key, required this.isComingSoon});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late String selectedCategory;
  late Future<List<Movie>> _moviesFuture;
  bool isNowPlaying = true;
  final CityFilterProvider _cityFilter = CityFilterProvider();
  late final CityFilterListener _cityFilterListener;
  int _loadCounter = 0; // Her yüklemede artırılacak counter

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      isNowPlaying = category == 'Now Showing';
      // Yeni Future oluştur - cache'i bypass et
      _loadMovies();
    });
  }

  void _loadMovies() {
    String apiUrl;

    // Kategoriye göre API URL'i belirle - web'deki gibi
    if (selectedCategory == 'Now Showing') {
      apiUrl = ApiConnection.movies;
    } else {
      // Coming Soon
      apiUrl = ApiConnection.futureMovies;
    }

    // Parametreleri ekle - web'deki gibi
    final params = <String>['per_page=100'];
    if (_cityFilter.hasCityFilter) {
      params.add('city_id=${_cityFilter.selectedCityId}');
    }
    
    // Cache-busting için timestamp ekle
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    params.add('_t=$timestamp');

    apiUrl = '$apiUrl?${params.join('&')}';

    // Counter'ı artır - FutureBuilder key'ini güncellemek için
    _loadCounter++;

    // Future'ı her seferinde yeniden oluştur - cache'i bypass et
    _moviesFuture = fetchMovies(apiUrl);
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.isComingSoon ? 'Coming Soon' : 'Now Showing';
    isNowPlaying = !widget.isComingSoon;
    _loadMovies();

    // Şehir filtresi değiştiğinde filmleri yeniden yükle
    _cityFilterListener = _handleCityFilterChange;
    _cityFilter.addListener(_cityFilterListener);
  }

  void _handleCityFilterChange(int? cityId, String? cityName) {
    if (!mounted) return;
    setState(() {
      _loadMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'All Movies',
          style: TextStyle(color: AppColorStyle.textPrimary),
        ),
        backgroundColor: AppColorStyle.appBarColor,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            delegate: CategoryHeaderDelegate(
              selectedCategory: selectedCategory,
              onCategorySelected: _onCategorySelected,
            ),
            floating: false,
            pinned: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: _buildMovieGridSliver(
              context,
              _moviesFuture,
              isNowPlaying,
              () {
                // State'teki Future'ı yeniden yükle
                setState(() {
                  _loadMovies();
                });
              },
              key: ValueKey('movies_${selectedCategory}_$_loadCounter'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityFilter.removeListener(_cityFilterListener);
    super.dispose();
  }
}
