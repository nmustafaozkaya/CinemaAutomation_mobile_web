<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Showtime;
use App\Models\Seat;
use App\Models\Ticket;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class ShowtimeController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        try {
            $query = Showtime::with(['movie', 'hall.cinema'])
                ->where('status', 'active')
                ->where('date', '>=', now()->toDateString());

            // Filtreleme
            if ($request->has('movie_id')) {
                $query->where('movie_id', $request->movie_id);
            }

            if ($request->has('cinema_id')) {
                $query->whereHas('hall', function($q) use ($request) {
                    $q->where('cinema_id', $request->cinema_id);
                });
            }

            if ($request->has('date')) {
                $query->where('date', $request->date);
            }

            $showtimes = $query->orderBy('date')
                ->orderBy('start_time')
                ->paginate(20);

            return response()->json([
                'success' => true,
                'data' => $showtimes
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Seanslar yüklenirken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    public function show($id): JsonResponse
    {
        try {
            $showtime = Showtime::with(['movie', 'hall.cinema', 'hall.seats'])
                ->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $showtime
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Seans bulunamadı'
            ], 404);
        }
    }

    public function availableSeats($id): JsonResponse
    {
        try {
            $showtime = Showtime::with(['hall.seats' => function($query) {
                $query->orderBy('row')->orderBy('number');
            }])->findOrFail($id);

            // Koltukları status'e göre grupla
            $seats = $showtime->hall->seats;
            
            $availableSeats = $seats->where('status', Seat::STATUS_AVAILABLE)->values();
            $occupiedSeats = $seats->where('status', Seat::STATUS_OCCUPIED)->values();
            $pendingSeats = $seats->where('status', Seat::STATUS_PENDING)->values();

            return response()->json([
                'success' => true,
                'data' => [
                    'showtime' => [
                        'id' => $showtime->id,
                        'movie' => $showtime->movie->title,
                        'hall' => $showtime->hall->name,
                        'cinema' => $showtime->hall->cinema->name,
                        'start_time' => $showtime->start_time,
                        'price' => $showtime->price
                    ],
                    'seats' => [
                        'available' => $availableSeats,
                        'occupied' => $occupiedSeats,
                        'pending' => $pendingSeats
                    ],
                    'counts' => [
                        'total' => $seats->count(),
                        'available' => $availableSeats->count(),
                        'occupied' => $occupiedSeats->count(),
                        'pending' => $pendingSeats->count()
                    ]
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Koltuk bilgileri yüklenirken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Koltuğu geçici olarak rezerve et (pending yap)
     */
    public function reserveSeat(Request $request, $showtimeId): JsonResponse
    {
        try {
            $validated = $request->validate([
                'seat_id' => 'required|exists:seats,id'
            ]);

            $seat = Seat::findOrFail($validated['seat_id']);

            if (!$seat->isAvailable()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Koltuk müsait değil'
                ], 400);
            }

            // Koltuğu pending yap (10 dakika süreyle)
            $seat->markAsPending();
            
            // Opsiyonel: Pending koltuğu otomatik temizlemek için job
            // \App\Jobs\ReleasePendingSeat::dispatch($seat)->delay(now()->addMinutes(10));

            return response()->json([
                'success' => true,
                'message' => 'Koltuk rezerve edildi',
                'data' => [
                    'seat' => $seat,
                    'expires_at' => now()->addMinutes(10)
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Koltuk rezerve edilirken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Koltuğu satın al (occupied yap)
     */
    public function purchaseSeat(Request $request, $showtimeId): JsonResponse
    {
        try {
            $validated = $request->validate([
                'seat_id' => 'required|exists:seats,id',
                'customer_name' => 'required|string|max:255',
                'customer_email' => 'required|email',
                'customer_phone' => 'required|string|max:20'
            ]);

            $seat = Seat::findOrFail($validated['seat_id']);
            $showtime = Showtime::findOrFail($showtimeId);

            // Koltuk pending mi kontrol et
            if (!$seat->isPending()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Koltuk rezerve edilmemiş'
                ], 400);
            }

            // Transaction içinde yap
            DB::transaction(function() use ($seat, $showtime, $validated) {
                // Koltuğu occupied yap
                $seat->markAsOccupied();
                
                // Bilet oluştur
                Ticket::create([
                    'showtime_id' => $showtime->id,
                    'seat_id' => $seat->id,
                    'customer_name' => $validated['customer_name'],
                    'customer_email' => $validated['customer_email'],
                    'customer_phone' => $validated['customer_phone'],
                    'price' => $showtime->price,
                    'status' => 'sold'
                ]);
            });

            return response()->json([
                'success' => true,
                'message' => 'Bilet başarıyla satın alındı',
                'data' => [
                    'seat' => $seat->fresh(),
                    'showtime' => $showtime
                ]
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Bilet satın alınırken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Pending koltukları serbest bırak (cron job için)
     */
    public function releasePendingSeats(): JsonResponse
    {
        try {
            // 10 dakikadan fazla pending olan koltukları available yap
            $expiredSeats = Seat::where('status', Seat::STATUS_PENDING)
                ->where('updated_at', '<', now()->subMinutes(10))
                ->get();

            foreach ($expiredSeats as $seat) {
                $seat->markAsAvailable();
            }

            return response()->json([
                'success' => true,
                'message' => count($expiredSeats) . ' koltuk serbest bırakıldı'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request): JsonResponse
    {
        try {
            $validated = $request->validate([
                'movie_id' => 'required|exists:movies,id',
                'hall_id' => 'required|exists:halls,id',
                'price' => 'required|numeric|min:0',
                'start_time' => 'required|date|after:now',
                'end_time' => 'required|date|after:start_time',
                'date' => 'required|date|after_or_equal:today'
            ]);

            $showtime = Showtime::create($validated);
            $showtime->load(['movie', 'hall.cinema']);

            return response()->json([
                'success' => true,
                'data' => $showtime,
                'message' => 'Seans başarıyla oluşturuldu'
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Seans oluşturulurken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id): JsonResponse
    {
        try {
            $showtime = Showtime::findOrFail($id);

            $validated = $request->validate([
                'movie_id' => 'sometimes|exists:movies,id',
                'hall_id' => 'sometimes|exists:halls,id',
                'price' => 'sometimes|numeric|min:0',
                'start_time' => 'sometimes|date',
                'end_time' => 'sometimes|date|after:start_time',
                'date' => 'sometimes|date',
                'status' => 'sometimes|in:active,inactive,cancelled'
            ]);

            $showtime->update($validated);
            $showtime->load(['movie', 'hall.cinema']);

            return response()->json([
                'success' => true,
                'data' => $showtime,
                'message' => 'Seans başarıyla güncellendi'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Seans güncellenirken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }

    public function destroy($id): JsonResponse
    {
        try {
            $showtime = Showtime::findOrFail($id);

            // Bu seansa ait bilet varsa silme
            if ($showtime->tickets()->count() > 0) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bu seansa ait biletler bulunduğu için silinemez'
                ], 400);
            }

            $showtime->delete();

            return response()->json([
                'success' => true,
                'message' => 'Seans başarıyla silindi'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Seans silinirken hata oluştu: ' . $e->getMessage()
            ], 500);
        }
    }
}