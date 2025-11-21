class ApiConnection {
  static const hostConnection = 'http://10.100.6.116:8000/api';

  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;

    // Tam URL ise (http/https ile başlıyorsa) olduğu gibi döndür
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Relative path ise base URL ile birleştir
    // Eğer / ile başlamıyorsa ekle
    final normalized = url.startsWith('/') ? url : '/$url';

    // Base URL'den /api kısmını çıkar (media dosyaları için)
    final baseUrl = hostConnection.replaceAll('/api', '');
    return '$baseUrl$normalized';
  }

  static const signUp = '$hostConnection/register';
  static const login = '$hostConnection/login';
  static const cities = '$hostConnection/cities';
  static String cinemas = '$hostConnection/cinemas';

  static const movies = '$hostConnection/movies';
  static const futureMovies = '$hostConnection/future-movies';
  static const distributedMovies =
      '$hostConnection/movies/distributed'; // Toplam 100 filmi tarihe göre dağıt

  static const showtimes = "$hostConnection/showtimes";
  static const halls = "$hostConnection/halls";

  static String getAvailableSeatsUrl(int showtimeId) =>
      "$hostConnection/showtimes/$showtimeId/available-seats";

  static String getTicketPricesUrl(int showtimeId) =>
      "$hostConnection/tickets/prices/$showtimeId";

  static String reserveSeatUrl(int showtimeId) =>
      "$hostConnection/showtimes/$showtimeId/reserve";

  static String releaseSeatUrl(int seatId) =>
      "$hostConnection/seats/$seatId/release";

  static String taxes = "$hostConnection/taxes";
  static String buyTicket = "$hostConnection/tickets";
  static String myTickets = '$hostConnection/my-tickets';
}
