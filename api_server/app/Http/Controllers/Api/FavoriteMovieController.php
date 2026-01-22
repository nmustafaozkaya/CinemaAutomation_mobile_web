<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FavoriteMovie;
use App\Models\Movie;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class FavoriteMovieController extends Controller
{
    /**
     * Kullanıcının favori filmlerini listele
     */
    public function index(): JsonResponse
    {
        $favorites = FavoriteMovie::with(['movie'])
            ->where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->get();

        $movies = $favorites->map(function ($favorite) {
            $movie = $favorite->movie;
            $movie->is_favorite = true;
            $movie->favorited_at = $favorite->created_at;
            return $movie;
        });

        return response()->json([
            'success' => true,
            'data' => $movies
        ]);
    }

    /**
     * Filme favorilere ekle
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'movie_id' => 'required|exists:movies,id',
        ]);

        // Film zaten favorilerde mi kontrol et
        $existing = FavoriteMovie::where('user_id', Auth::id())
            ->where('movie_id', $validated['movie_id'])
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Movie is already in favorites'
            ], 409);
        }

        $favorite = FavoriteMovie::create([
            'user_id' => Auth::id(),
            'movie_id' => $validated['movie_id'],
        ]);

        $favorite->load('movie');

        return response()->json([
            'success' => true,
            'message' => 'Movie added to favorites',
            'data' => $favorite
        ], 201);
    }

    /**
     * Filmi favorilerden çıkar
     */
    public function destroy($movieId): JsonResponse
    {
        $deleted = FavoriteMovie::where('user_id', Auth::id())
            ->where('movie_id', $movieId)
            ->delete();

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Movie not found in favorites'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Movie removed from favorites'
        ]);
    }

    /**
     * Film favorilerde mi kontrol et
     */
    public function check($movieId): JsonResponse
    {
        $isFavorite = FavoriteMovie::where('user_id', Auth::id())
            ->where('movie_id', $movieId)
            ->exists();

        return response()->json([
            'success' => true,
            'is_favorite' => $isFavorite
        ]);
    }

    /**
     * Favori filmler için toggle (ekle/çıkar)
     */
    public function toggle(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'movie_id' => 'required|exists:movies,id',
        ]);

        $favorite = FavoriteMovie::where('user_id', Auth::id())
            ->where('movie_id', $validated['movie_id'])
            ->first();

        if ($favorite) {
            // Favorilerden çıkar
            $favorite->delete();
            $message = 'Movie removed from favorites';
            $isFavorite = false;
        } else {
            // Favorilere ekle
            FavoriteMovie::create([
                'user_id' => Auth::id(),
                'movie_id' => $validated['movie_id'],
            ]);
            $message = 'Movie added to favorites';
            $isFavorite = true;
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'is_favorite' => $isFavorite
        ]);
    }
}
