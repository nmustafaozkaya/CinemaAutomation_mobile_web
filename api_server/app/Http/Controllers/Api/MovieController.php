<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cinema;
use App\Models\Movie;
use App\Models\Showtime;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class MovieController extends Controller
{
    /**
     * Display a listing of movies
     */
    public function index(Request $request): JsonResponse
    {
        $query = Movie::query();

        // Arama filtresi
        if ($request->filled('search')) {
            $query->where('title', 'like', '%' . $request->search . '%')
                  ->orWhere('description', 'like', '%' . $request->search . '%');
        }

        // Tür filtresi
        if ($request->filled('genre')) {
            $query->where('genre', 'like', '%' . $request->genre . '%');
        }

        // Yıl filtresi
        if ($request->filled('year')) {
            $query->whereYear('release_date', $request->year);
        }

        // IMDB rating filtresi
        if ($request->filled('min_rating')) {
            $query->where('imdb_raiting', '>=', $request->min_rating);
        }

        // Durum filtresi
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        // Sıralama
        $sortBy = $request->get('sort_by', 'release_date');
        $sortDirection = $request->get('sort_direction', 'desc');
        $query->orderBy($sortBy, $sortDirection);

        // Sayfalama
        $perPage = $request->get('per_page', 20);
        $movies = $query->paginate($perPage);

        return response()->json([
            'success' => true,
            'message' => 'Movies retrieved successfully',
            'data' => $movies
        ]);
    }

    /**
     * Store a newly created movie
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'duration' => 'required|integer|min:1',
            'language' => 'required|string|max:10',
            'release_date' => 'required|date',
            'genre' => 'required|string|max:255',
            'poster_url' => 'nullable|url',
            'imdb_raiting' => 'nullable|numeric|between:0,10',
            'status' => 'nullable|in:active,inactive'
        ]);

        $movie = Movie::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Movie created successfully',
            'data' => $movie
        ], 201);
    }

    /**
     * Display the specified movie
     */
    public function show(string $id): JsonResponse
    {
        $movie = Movie::with(['showtimes.hall.cinema.city'])->find($id);

        if (!$movie) {
            return response()->json([
                'success' => false,
                'message' => 'Movie not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Movie retrieved successfully',
            'data' => $movie
        ]);
    }

    /**
     * Update the specified movie
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $movie = Movie::find($id);

        if (!$movie) {
            return response()->json([
                'success' => false,
                'message' => 'Movie not found'
            ], 404);
        }

        $movie->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Movie updated successfully',
            'data' => $movie
        ]);
    }
    

    /**
     * Remove the specified movie
     */
    public function destroy(string $id): JsonResponse
    {
        $movie = Movie::find($id);

        if (!$movie) {
            return response()->json([
                'success' => false,
                'message' => 'Movie not found'
            ], 404);
        }

        // Eğer aktif seansları varsa silmeyi engelle
        if ($movie->showtimes()->where('status', 'active')->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete movie with active showtimes'
            ], 422);
        }

        $movie->delete();

        return response()->json([
            'success' => true,
            'message' => 'Movie deleted successfully'
        ]);
    }

    /**
     * Get movies by genre
     */
    public function byGenre(string $genre): JsonResponse
    {
        $movies = Movie::where('genre', 'like', "%{$genre}%")
                      ->where('status', 'active')
                      ->orderBy('imdb_raiting', 'desc')
                      ->get();

        return response()->json([
            'success' => true,
            'message' => "Movies in {$genre} genre retrieved successfully",
            'data' => $movies
        ]);
    }

    /**
     * Get popular movies (high IMDB rating)
     */
    public function popular(): JsonResponse
    {
        $movies = Movie::where('imdb_raiting', '>=', 7.0)
                      ->where('status', 'active')
                      ->orderBy('imdb_raiting', 'desc')
                      ->limit(20)
                      ->get();

        return response()->json([
            'success' => true,
            'message' => 'Popular movies retrieved successfully',
            'data' => $movies
        ]);
    }

    /**
     * Get now showing movies (have active showtimes)
     */
    public function nowShowing(): JsonResponse
    {
        $movies = Movie::whereHas('showtimes', function ($query) {
                        $query->where('status', 'active')
                              ->where('start_time', '>', now());
                    })
                    ->where('status', 'active')
                    ->with(['showtimes' => function ($query) {
                        $query->where('status', 'active')
                              ->where('start_time', '>', now())
                              ->orderBy('start_time');
                    }])
                    ->orderBy('release_date', 'desc')
                    ->get();

        return response()->json([
            'success' => true,
            'message' => 'Now showing movies retrieved successfully',
            'data' => $movies
        ]);
    }


// MovieController.php dosyanızın sonuna, } 'den önce bu metotları ekleyin:

/**
 * Get cinemas showing specific movie
 */
public function getCinemasForMovie(string $movieId, Request $request): JsonResponse
{
    try {
        // Movie var mı kontrol et
        $movie = Movie::find($movieId);
        if (!$movie) {
            return response()->json([
                'success' => false,
                'message' => 'Film bulunamadı'
            ], 404);
        }

        // Bu filme ait sinemalar
        $cinemas = Cinema::whereHas('halls.showtimes', function ($q) use ($movieId) {
                    $q->where('movie_id', $movieId)
                      ->where('status', 'active')
                      ->where('start_time', '>', now());
                })
                ->with([
                    'city',
                    'halls' => function ($query) use ($movieId) {
                        $query->whereHas('showtimes', function ($q) use ($movieId) {
                            $q->where('movie_id', $movieId)
                              ->where('status', 'active')
                              ->where('start_time', '>', now());
                        });
                    },
                    'halls.showtimes' => function ($query) use ($movieId) {
                        $query->where('movie_id', $movieId)
                              ->where('status', 'active')
                              ->where('start_time', '>', now())
                              ->orderBy('start_time');
                    }
                ])
                ->get();

        // Mevcut şehirleri de döndür
        $availableCities = $cinemas->pluck('city')
                                 ->filter()
                                 ->unique('id')
                                 ->values();

        return response()->json([
            'success' => true,
            'message' => 'Cinemas showing this movie retrieved successfully',
            'data' => [
                'cinemas' => $cinemas,
                'available_cities' => $availableCities,
                'total_cinemas' => $cinemas->count()
            ]
        ]);

    } catch (\Exception $e) {
     
        return response()->json([
            'success' => false,
            'message' => 'Sinemalar yüklenirken hata oluştu: ' . $e->getMessage()
        ], 500);
    }
}

/**
 * Get showtimes for movie
 */
public function getShowtimesForMovie(string $movieId, Request $request): JsonResponse
{
    try {
        $movie = Movie::find($movieId);
        if (!$movie) {
            return response()->json([
                'success' => false,
                'message' => 'Film bulunamadı'
            ], 404);
        }

        $query = Showtime::where('movie_id', $movieId)
                    ->where('status', 'active')
                    ->where('start_time', '>', now())
                    ->with(['hall.cinema.city', 'movie']);

        // Sinema filtresi
        if ($request->filled('cinema_id')) {
            $query->whereHas('hall', function($q) use ($request) {
                $q->where('cinema_id', $request->cinema_id);
            });
        }

        $showtimes = $query->orderBy('start_time')->get();

        return response()->json([
            'success' => true,
            'message' => 'Showtimes retrieved successfully',
            'data' => $showtimes
        ]);

    } catch (\Exception $e) {

        
        return response()->json([
            'success' => false,
            'message' => 'Seanslar yüklenirken hata oluştu: ' . $e->getMessage()
        ], 500);
    }
}
    
}