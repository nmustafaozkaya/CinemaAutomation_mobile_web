<?php

namespace Database\Seeders\Movies;

use Illuminate\Database\Seeder;
use App\Models\Movie;
use Illuminate\Support\Facades\Http;
use Carbon\Carbon;

class Movies2025Seeder extends Seeder
{
    private $tmdbApiKey = 'fd906554dbafae73a755cb63e9a595df';
    private $tmdbBaseUrl = 'https://api.themoviedb.org/3';
    private $imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

    public function run(): void
    {
        $this->command->info('🎬 2025 Filmleri TMDB\'den yükleniyor...');

        $movies = [];
        $page = 1;
        $maxPages = 10; // 10 sayfa = ~200 film
        $totalAdded = 0;

        while ($page <= $maxPages) {
            $this->command->info("📄 Sayfa {$page} yükleniyor...");

            try {
                $response = Http::timeout(15)->get("{$this->tmdbBaseUrl}/discover/movie", [
                    'api_key' => $this->tmdbApiKey,
                    'primary_release_year' => 2025,
                    'sort_by' => 'popularity.desc',
                    'page' => $page,
                    'language' => 'tr-TR',
                    'region' => 'TR'
                ]);

                if (!$response->successful()) {
                    $this->command->error("❌ TMDB API hatası: " . $response->status());
                    break;
                }

                $data = $response->json();
                
                if (empty($data['results'])) {
                    $this->command->info("⚠️ Sayfa {$page}'de film bulunamadı.");
                    break;
                }

                foreach ($data['results'] as $movieData) {
                    // Sadece poster'ı olan filmleri ekle
                    if (empty($movieData['poster_path'])) {
                        continue;
                    }

                    // Film zaten var mı kontrol et
                    $existingMovie = Movie::where('title', $movieData['title'])->first();
                    if ($existingMovie) {
                        continue;
                    }

                    // Genre'ları al
                    $genres = [];
                    if (isset($movieData['genre_ids']) && is_array($movieData['genre_ids'])) {
                        $genres = $this->getGenreNames($movieData['genre_ids']);
                    }

                    // Release date'i parse et
                    $releaseDate = null;
                    if (!empty($movieData['release_date'])) {
                        try {
                            $releaseDate = Carbon::parse($movieData['release_date'])->format('Y-m-d');
                        } catch (\Exception $e) {
                            $releaseDate = '2025-01-01';
                        }
                    } else {
                        $releaseDate = '2025-01-01';
                    }

                    // Film verisini hazırla
                    $movie = [
                        'title' => substr($movieData['title'] ?? 'İsimsiz Film', 0, 255),
                        'description' => substr($movieData['overview'] ?? 'Açıklama mevcut değil.', 0, 1000),
                        'duration' => $movieData['runtime'] ?? 120,
                        'language' => substr($movieData['original_language'] ?? 'en', 0, 5),
                        'release_date' => $releaseDate,
                        'genre' => !empty($genres) ? implode(', ', array_slice($genres, 0, 3)) : 'Drama',
                        'poster_url' => $this->imageBaseUrl . $movieData['poster_path'],
                        'imdb_raiting' => isset($movieData['vote_average']) ? round($movieData['vote_average'], 1) : null,
                        'status' => 'active',
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];

                    try {
                        Movie::create($movie);
                        $totalAdded++;
                        $this->command->info("✅ {$movie['title']} eklendi");
                    } catch (\Exception $e) {
                        $this->command->warn("⚠️ {$movie['title']} eklenemedi: " . $e->getMessage());
                    }
                }

                // Rate limiting
                usleep(500000); // 0.5 saniye bekle
                $page++;

            } catch (\Exception $e) {
                $this->command->error("❌ Sayfa {$page} yüklenirken hata: " . $e->getMessage());
                break;
            }
        }

        $this->command->info("\n🎉 2025 Filmleri yükleme tamamlandı!");
        $this->command->info("📊 Toplam eklenen: {$totalAdded} film");
    }

    private function getGenreNames($genreIds): array
    {
        static $genreMap = null;

        if ($genreMap === null) {
            try {
                $response = Http::timeout(10)->get("{$this->tmdbBaseUrl}/genre/movie/list", [
                    'api_key' => $this->tmdbApiKey,
                    'language' => 'tr-TR'
                ]);

                if ($response->successful()) {
                    $data = $response->json();
                    $genreMap = [];
                    foreach ($data['genres'] as $genre) {
                        $genreMap[$genre['id']] = $genre['name'];
                    }
                }
            } catch (\Exception $e) {
                $this->command->warn("⚠️ Genre listesi alınamadı, varsayılan kullanılıyor.");
            }

            // Varsayılan genre map
            if ($genreMap === null) {
                $genreMap = [
                    28 => 'Aksiyon',
                    12 => 'Macera',
                    16 => 'Animasyon',
                    35 => 'Komedi',
                    80 => 'Suç',
                    99 => 'Belgesel',
                    18 => 'Drama',
                    10751 => 'Aile',
                    14 => 'Fantastik',
                    36 => 'Tarih',
                    27 => 'Korku',
                    10402 => 'Müzik',
                    9648 => 'Gizem',
                    10749 => 'Romantik',
                    878 => 'Bilim Kurgu',
                    10770 => 'TV Filmi',
                    53 => 'Gerilim',
                    10752 => 'Savaş',
                    37 => 'Batı'
                ];
            }
        }

        $genres = [];
        foreach ($genreIds as $id) {
            if (isset($genreMap[$id])) {
                $genres[] = $genreMap[$id];
            }
        }

        return $genres;
    }
}

