class Cinema {
  final int cityId;
  final String cityName;
  final int cinemaId;
  final String cinemaName;
  final String cinemaAddress;
  final String cinemaPhone;
  final String cinemaEmail;

  Cinema({
    required this.cityId,
    required this.cityName,
    required this.cinemaId,
    required this.cinemaName,
    required this.cinemaAddress,
    required this.cinemaPhone,
    required this.cinemaEmail,
  });

  factory Cinema.fromJson(Map<String, dynamic> json) {
    final cityData = json['city'];

    int parsedCityId = 0;
    String parsedCityName = 'Bilinmeyen';

    if (cityData is Map<String, dynamic>) {
      final dynamic cityIdValue = cityData['id'];
      if (cityIdValue is int) {
        parsedCityId = cityIdValue;
      } else if (cityIdValue is String) {
        parsedCityId = int.tryParse(cityIdValue) ?? 0;
      }

      final dynamic cityNameValue = cityData['name'];
      if (cityNameValue is String && cityNameValue.trim().isNotEmpty) {
        parsedCityName = cityNameValue;
      }
    } else {
      final dynamic cityIdValue = json['city_id'];
      if (cityIdValue is int) {
        parsedCityId = cityIdValue;
      } else if (cityIdValue is String) {
        parsedCityId = int.tryParse(cityIdValue) ?? 0;
      }
    }

    return Cinema(
      cityId: parsedCityId,
      cityName: parsedCityName,
      cinemaId: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      cinemaName: json['name']?.toString() ?? 'Sinema',
      cinemaAddress: json['address']?.toString() ?? '',
      cinemaPhone: json['phone']?.toString() ?? '',
      cinemaEmail: json['email']?.toString() ?? '',
    );
  }
}
