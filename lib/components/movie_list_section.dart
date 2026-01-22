// lib/components/movie_list_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/components/favorite_button.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';

class MovieListSection extends StatelessWidget {
  final List<Movie> movies;
  final Function(Movie) onMovieTap;
  final bool isForNowShowing;

  const MovieListSection({
    super.key,
    required this.movies,
    required this.onMovieTap,
    required this.isForNowShowing,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(child: Text('No movies found.'));
    }

    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetails(
                    currentMovie: movie,
                    isNowShowing: isForNowShowing,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (movie.poster.isNotEmpty && movie.poster != 'N/A')
                        ? Image.network(
                            movie.poster,
                            width: 80,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 120,
                                color: Colors.grey[800],
                                child: const Icon(Icons.movie, size: 40),
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 120,
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie, size: 40),
                          ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Movie Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd.MM.yyyy').format(movie.releaseDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (movie.genre.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            movie.genre,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              movie.imdbRating.isNotEmpty ? movie.imdbRating : 'N/A',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Favorite Button
                  FavoriteButton(
                    movieId: movie.id,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
