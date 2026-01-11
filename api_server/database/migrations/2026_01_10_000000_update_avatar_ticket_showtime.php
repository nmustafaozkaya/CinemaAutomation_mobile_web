<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;
use App\Models\Movie;
use App\Models\Cinema;
use App\Models\Hall;
use App\Models\Showtime;
use App\Models\Seat;
use App\Models\Ticket;
use Carbon\Carbon;

/**
 * Migration to update Avatar: Fire and Ash ticket showtime
 * - Finds the specific showtime for Avatar: Fire and Ash at Avşar Sinemaları Adıyaman Park, Salon 1
 * - Updates the showtime date from Jan 10, 2026 02:30 PM to a past date
 * - This will make the ticket automatically appear as 'deactive' in the system
 */
return new class extends Migration
{
    public function up(): void
    {
        // Find the movie "Avatar: Fire and Ash"
        $movie = Movie::where('title', 'LIKE', '%Avatar%')
            ->where('title', 'LIKE', '%Fire%')
            ->where('title', 'LIKE', '%Ash%')
            ->first();

        if (!$movie) {
            // If movie doesn't exist, create it
            $movie = Movie::create([
                'title' => 'Avatar: Fire and Ash',
                'description' => 'In the third installment of James Cameron\'s Avatar saga, Jake Sully and Neytiri face new challenges as they explore the fire territories of Pandora.',
                'duration' => 120,
                'language' => 'en',
                'release_date' => '2025-12-18',
                'genre' => 'Science Fiction, Adventure, Fantasy',
                'poster_url' => 'https://image.tmdb.org/t/p/w500/avatar_fire_and_ash.jpg',
                'imdb_raiting' => 8.5,
                'status' => 'active',
            ]);
            echo "✅ Movie 'Avatar: Fire and Ash' created.\n";
        } else {
            echo "✅ Found movie: {$movie->title}\n";
        }

        // Find the cinema "Avşar Sinemaları Adıyaman Park"
        $cinema = Cinema::where('name', 'LIKE', '%Avşar%')
            ->where('name', 'LIKE', '%Adıyaman%')
            ->first();

        if (!$cinema) {
            echo "⚠️ Cinema 'Avşar Sinemaları Adıyaman Park' not found. Please run seeders first.\n";
            return;
        }

        echo "✅ Found cinema: {$cinema->name}\n";

        // Find Hall 1 (Salon 1) for this cinema
        $hall = Hall::where('cinema_id', $cinema->id)
            ->where('name', 'LIKE', '%Salon 1%')
            ->orWhere('name', 'LIKE', '%Hall 1%')
            ->first();

        if (!$hall) {
            echo "⚠️ Hall 'Salon 1' not found for cinema {$cinema->name}. Please run seeders first.\n";
            return;
        }

        echo "✅ Found hall: {$hall->name}\n";

        // Find or create the showtime for Jan 10, 2026 at 02:30 PM
        $originalDate = '2026-01-10';
        $originalTime = '14:30:00'; // 02:30 PM in 24-hour format

        $showtime = Showtime::where('movie_id', $movie->id)
            ->where('hall_id', $hall->id)
            ->where('date', $originalDate)
            ->whereTime('start_time', $originalTime)
            ->first();

        if (!$showtime) {
            // Create the showtime if it doesn't exist
            $startDateTime = Carbon::parse("$originalDate $originalTime");
            $endDateTime = $startDateTime->copy()->addMinutes($movie->duration + 15);

            $showtime = Showtime::create([
                'movie_id' => $movie->id,
                'hall_id' => $hall->id,
                'price' => 92.22,
                'start_time' => $startDateTime,
                'end_time' => $endDateTime,
                'date' => $originalDate,
                'status' => 'active',
            ]);
            echo "✅ Showtime created for {$originalDate} at {$originalTime}.\n";
        } else {
            echo "✅ Found showtime: {$showtime->date} at " . $showtime->start_time->format('H:i') . "\n";
        }

        // Find seat C5
        $seat = Seat::where('hall_id', $hall->id)
            ->where('row', 'C')
            ->where('number', 5)
            ->first();

        if (!$seat) {
            echo "⚠️ Seat C5 not found in {$hall->name}. Please run seeders first.\n";
            return;
        }

        echo "✅ Found seat: {$seat->row}{$seat->number}\n";

        // Get the first available user
        $user = DB::table('users')->first();
        if (!$user) {
            echo "⚠️ No users found in database. Please run UserSeeder first.\n";
            return;
        }

        // Find or create the ticket
        $ticket = Ticket::where('showtime_id', $showtime->id)
            ->where('seat_id', $seat->id)
            ->first();

        if (!$ticket) {
            // Mark seat as occupied
            $seat->update([
                'status' => Seat::STATUS_OCCUPIED,
                'reserved_at' => null,
                'reserved_until' => null
            ]);

            // Create the ticket
            $ticket = Ticket::create([
                'showtime_id' => $showtime->id,
                'seat_id' => $seat->id,
                'user_id' => $user->id,
                'price' => 92.22,
                'customer_type' => 'adult',
                'discount_rate' => 0,
                'status' => 'sold',
            ]);
            echo "✅ Ticket created for seat C5.\n";
        } else {
            echo "✅ Found ticket: ID {$ticket->id}\n";
        }

        // Find the specific showtime for the ticket (the one with seat C5)
        $ticketShowtime = Showtime::where('id', $ticket->showtime_id)->first();
        
        if (!$ticketShowtime) {
            echo "⚠️ Ticket's showtime not found.\n";
            return;
        }

        echo "✅ Ticket's showtime: {$ticketShowtime->date} at " . $ticketShowtime->start_time->format('H:i') . "\n";

        // UPDATE: Move the showtime date to the past to make it deactive
        // Move it to 30 days ago so it's clearly in the past
        $newDate = Carbon::now()->subDays(30);
        $newStartTime = Carbon::parse($newDate->format('Y-m-d') . ' ' . $ticketShowtime->start_time->format('H:i:s'));
        $newEndTime = $newStartTime->copy()->addMinutes($movie->duration + 15);

        $ticketShowtime->update([
            'date' => $newDate->format('Y-m-d'),
            'start_time' => $newStartTime,
            'end_time' => $newEndTime,
        ]);

        echo "\n🎯 SUCCESS: Showtime updated!\n";
        echo "   Original: {$ticketShowtime->date} at " . $ticketShowtime->start_time->format('H:i:s') . "\n";
        echo "   New: {$newDate->format('Y-m-d')} at {$newStartTime->format('H:i:s')}\n";
        echo "   Ticket will now show as 'deactive' on both web and mobile.\n";
    }

    public function down(): void
    {
        // Revert the changes - move the showtime back to original date
        $movie = Movie::where('title', 'LIKE', '%Avatar%')
            ->where('title', 'LIKE', '%Fire%')
            ->where('title', 'LIKE', '%Ash%')
            ->first();

        if (!$movie) {
            echo "⚠️ Movie not found for rollback.\n";
            return;
        }

        $cinema = Cinema::where('name', 'LIKE', '%Avşar%')
            ->where('name', 'LIKE', '%Adıyaman%')
            ->first();

        if (!$cinema) {
            echo "⚠️ Cinema not found for rollback.\n";
            return;
        }

        $hall = Hall::where('cinema_id', $cinema->id)
            ->where('name', 'LIKE', '%Salon 1%')
            ->orWhere('name', 'LIKE', '%Hall 1%')
            ->first();

        if (!$hall) {
            echo "⚠️ Hall not found for rollback.\n";
            return;
        }

        // Find showtimes in the past for this movie/hall
        $showtime = Showtime::where('movie_id', $movie->id)
            ->where('hall_id', $hall->id)
            ->where('date', '<', Carbon::now()->format('Y-m-d'))
            ->first();

        if ($showtime) {
            $originalDate = '2026-01-10';
            $originalTime = '14:30:00';
            $startDateTime = Carbon::parse("$originalDate $originalTime");
            $endDateTime = $startDateTime->copy()->addMinutes($movie->duration + 15);

            $showtime->update([
                'date' => $originalDate,
                'start_time' => $startDateTime,
                'end_time' => $endDateTime,
            ]);

            echo "✅ Showtime reverted to original date: {$originalDate} at {$originalTime}\n";
        }
    }
};
