class ApiConnection {
  static const String localUrl = 'http://10.0.2.2:8000/api';
  static const hostConnection = localUrl;

  static String resolveMediaUrl(String url) {
    if (url.isEmpty) return url;

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final normalized = url.startsWith('/') ? url : '/$url';

    final baseUrl = hostConnection.replaceAll('/api', '');
    return '$baseUrl$normalized';
  }

  static const signUp = '$hostConnection/register';
  static const login = '$hostConnection/login';
  static const cities = '$hostConnection/cities';
  static String cinemas = '$hostConnection/cinemas';

  static const movies = '$hostConnection/movies';
  static const futureMovies = '$hostConnection/future-movies';
  static const distributedMovies = '$hostConnection/movies/distributed';

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

  static String updateTicketUrl(int ticketId) =>
      "$hostConnection/tickets/$ticketId";

  static String deleteTicketUrl(int ticketId) =>
      "$hostConnection/tickets/$ticketId";

  static String updateProfile = '$hostConnection/profile';
  static String changePassword = '$hostConnection/change-password';

  // Payment Methods
  static String paymentMethods = '$hostConnection/payment-methods';
  static String addPaymentMethod = '$hostConnection/payment-methods';
  static String updatePaymentMethodUrl(int id) =>
      '$hostConnection/payment-methods/$id';
  static String deletePaymentMethodUrl(int id) =>
      '$hostConnection/payment-methods/$id';
  static String setDefaultPaymentMethodUrl(int id) =>
      '$hostConnection/payment-methods/$id/set-default';

  // Favorite Movies
  static String favoriteMovies = '$hostConnection/favorite-movies';
  static String toggleFavoriteMovie = '$hostConnection/favorite-movies/toggle';
  static String checkFavoriteMovieUrl(int movieId) =>
      '$hostConnection/favorite-movies/$movieId/check';
  static String removeFavoriteMovieUrl(int movieId) =>
      '$hostConnection/favorite-movies/$movieId';
}
