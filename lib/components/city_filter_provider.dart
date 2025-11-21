typedef CityFilterListener = void Function(int?, String?);

/// Global şehir filtresi state yönetimi (Singleton pattern)
class CityFilterProvider {
  static final CityFilterProvider _instance = CityFilterProvider._internal();
  factory CityFilterProvider() => _instance;
  CityFilterProvider._internal();

  int? _selectedCityId;
  String? _selectedCityName;
  final List<CityFilterListener> _listeners = [];

  int? get selectedCityId => _selectedCityId;
  String? get selectedCityName => _selectedCityName;
  bool get hasCityFilter => _selectedCityId != null;

  void addListener(CityFilterListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
      // Listener eklendiğinde mevcut state'i hemen ilet
      listener(_selectedCityId, _selectedCityName);
    }
  }

  void removeListener(CityFilterListener listener) {
    _listeners.remove(listener);
  }

  void setCityFilter(int? cityId, String? cityName) {
    _selectedCityId = cityId;
    _selectedCityName = cityName;
    _notifyListeners();
  }

  void clearCityFilter() {
    _selectedCityId = null;
    _selectedCityName = null;
    _notifyListeners();
  }

  void _notifyListeners() {
    final listeners = List<CityFilterListener>.from(_listeners);
    for (final listener in listeners) {
      try {
        listener(_selectedCityId, _selectedCityName);
      } catch (_) {
        // Listener içinde hata olması durumunda diğerlerini etkileme
        continue;
      }
    }
  }
}

