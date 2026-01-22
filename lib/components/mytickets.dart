class MyTicketsResponse {
  final bool success;
  final TicketData data;

  MyTicketsResponse({required this.success, required this.data});

  factory MyTicketsResponse.fromJson(Map<String, dynamic> json) {
    return MyTicketsResponse(
      success: json['success'] ?? false,
      data: TicketData.fromJson(json['data']),
    );
  }
}

class TicketData {
  final int currentPage;
  final List<Ticket> tickets;
  final int total;
  final int perPage;
  final String? nextPageUrl;
  final String? prevPageUrl;

  TicketData({
    required this.currentPage,
    required this.tickets,
    required this.total,
    required this.perPage,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      currentPage: json['current_page'] ?? 1,
      tickets: (json['data'] as List<dynamic>)
          .map((item) => Ticket.fromJson(item))
          .toList(),
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 10,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}

class Ticket {
  final int id;
  final int showtimeId;
  final int seatId;
  final int userId;
  final int saleId;
  final double price;
  final String customerType;
  final double discountRate;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Showtime showtime;
  final Seat seat;
  final String? paymentMethod;

  Ticket({
    required this.id,
    required this.showtimeId,
    required this.seatId,
    required this.userId,
    required this.saleId,
    required this.price,
    required this.customerType,
    required this.discountRate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.showtime,
    required this.seat,
    this.paymentMethod,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    try {
      return Ticket(
        id: json['id'] ?? 0,
        showtimeId: json['showtime_id'] ?? 0,
        seatId: json['seat_id'] ?? 0,
        userId: json['user_id'] ?? 0,
        saleId: json['sale_id'] ?? 0,
        price: double.parse((json['price'] ?? 0).toString()),
        customerType: json['customer_type'] ?? 'adult',
        discountRate: double.parse((json['discount_rate'] ?? 0).toString()),
        status: json['status'] ?? 'sold',
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        showtime: Showtime.fromJson(json['showtime']),
        seat: Seat.fromJson(json['seat']),
        paymentMethod: json['sale'] != null
            ? json['sale']['payment_method'] as String?
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class Showtime {
  final int id;
  final int movieId;
  final int hallId;
  final double price;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime date;
  final String status;
  final Movie movie;
  final Hall hall;

  Showtime({
    required this.id,
    required this.movieId,
    required this.hallId,
    required this.price,
    required this.startTime,
    required this.endTime,
    required this.date,
    required this.status,
    required this.movie,
    required this.hall,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    try {
      return Showtime(
        id: json['id'] ?? 0,
        movieId: json['movie_id'] ?? 0,
        hallId: json['hall_id'] ?? 0,
        price: double.parse((json['price'] ?? 0).toString()),
        startTime: DateTime.parse(json['start_time']),
        endTime: DateTime.parse(json['end_time']),
        date: DateTime.parse(json['date']),
        status: json['status'] ?? 'active',
        movie: Movie.fromJson(json['movie']),
        hall: Hall.fromJson(json['hall']),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class Movie {
  final int id;
  final String title;
  final String description;
  final int duration;
  final String language;
  final String releaseDate;
  final String genre;
  final String posterUrl;
  final String imdbRating;
  final String status;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.language,
    required this.releaseDate,
    required this.genre,
    required this.posterUrl,
    required this.imdbRating,
    required this.status,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    try {
      return Movie(
        id: json['id'] ?? 0,
        title: json['title'] ?? 'Unknown Movie',
        description: json['description'] ?? '',
        duration: json['duration'] ?? 0,
        language: json['language'] ?? 'en',
        releaseDate: json['release_date'] ?? '',
        genre: json['genre'] ?? '',
        posterUrl: json['poster_url'] ?? '',
        imdbRating: (json['imdb_raiting'] ?? json['imdb_rating'] ?? '0.0')
            .toString(),
        status: json['status'] ?? 'active',
      );
    } catch (e) {
      rethrow;
    }
  }
}

class Hall {
  final int id;
  final String name;
  final int cinemaId;
  final int capacity;
  final String status;
  final Cinema cinema;

  Hall({
    required this.id,
    required this.name,
    required this.cinemaId,
    required this.capacity,
    required this.status,
    required this.cinema,
  });

  factory Hall.fromJson(Map<String, dynamic> json) {
    try {
      return Hall(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown Hall',
        cinemaId: json['cinema_id'] ?? 0,
        capacity: json['capacity'] ?? 0,
        status: json['status'] ?? 'active',
        cinema: Cinema.fromJson(json['cinema']),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class Cinema {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final int cityId;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.cityId,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    try {
      return Cinema(
        id: json['id'] ?? 0,
        name: json['name'] ?? 'Unknown Cinema',
        address: json['address'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        cityId: json['city_id'] ?? 0,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class Seat {
  final int id;
  final int hallId;
  final String row;
  final int number;
  final String status;
  final DateTime? reservedAt;
  final DateTime? reservedUntil;

  Seat({
    required this.id,
    required this.hallId,
    required this.row,
    required this.number,
    required this.status,
    this.reservedAt,
    this.reservedUntil,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    try {
      return Seat(
        id: json['id'] ?? 0,
        hallId: json['hall_id'] ?? 0,
        row: json['row'] ?? 'A',
        number: json['number'] ?? 1,
        status: json['status'] ?? 'Blank',
        reservedAt: json['reserved_at'] != null
            ? DateTime.parse(json['reserved_at'])
            : null,
        reservedUntil: json['reserved_until'] != null
            ? DateTime.parse(json['reserved_until'])
            : null,
      );
    } catch (e) {
      rethrow;
    }
  }
}
