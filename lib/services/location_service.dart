import 'dart:async';
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocationService extends ChangeNotifier {
  static const _cityKey = 'location_city';
  static const _stateKey = 'location_state';
  static const _countryKey = 'location_country';
  static const _tempKey = 'location_temperature';
  static const _weatherLabelKey = 'location_weather_label';

  String? _city;
  String? _state;
  String? _country;
  double? _temperature;
  String? _weatherLabel;
  bool _loading = false;
  String? _error;

  String? get city => _city;
  String? get state => _state;
  String? get country => _country;
  double? get temperature => _temperature;
  String? get weatherLabel => _weatherLabel;
  bool get loading => _loading;
  String? get error => _error;

  String get headlineLocation {
    if ((_state ?? '').isNotEmpty) return _state!;
    if ((_city ?? '').isNotEmpty) return _city!;
    if ((_country ?? '').isNotEmpty) return _country!;
    return 'your region';
  }

  List<String> get interestKeywords {
    final values = <String>{
      if ((_city ?? '').isNotEmpty) _city!,
      if ((_state ?? '').isNotEmpty) _state!,
      if ((_country ?? '').isNotEmpty) _country!,
    };

    if ((_country ?? '').toLowerCase() == 'india' &&
        (_state ?? '').isNotEmpty) {
      values.add('India');
      values.add(_state!);
    }

    return values.where((item) => item.trim().isNotEmpty).toList();
  }

  Future<void> init() async {
    await _loadCachedLocation();
    unawaited(refreshLocation());
  }

  Future<void> refreshLocation() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission was not granted.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        _city = _pickFirstNonEmpty([
          place.locality,
          place.subAdministrativeArea,
          place.subLocality,
        ]);
        _state = _pickFirstNonEmpty([
          place.administrativeArea,
          place.subAdministrativeArea,
        ]);
        _country = place.country;
      }

      await _fetchWeather(position.latitude, position.longitude);
      await _persist();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchWeather(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,weather_code',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return;

    final Map<String, dynamic> data = jsonDecode(response.body);
    final current = data['current'] as Map<String, dynamic>?;
    if (current == null) return;

    final temp = current['temperature_2m'];
    final code = current['weather_code'];
    if (temp is num) _temperature = temp.toDouble();
    if (code is num) _weatherLabel = _weatherLabelForCode(code.toInt());
  }

  Future<void> _loadCachedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    _city = prefs.getString(_cityKey);
    _state = prefs.getString(_stateKey);
    _country = prefs.getString(_countryKey);
    _temperature = prefs.getDouble(_tempKey);
    _weatherLabel = prefs.getString(_weatherLabelKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cityKey, _city ?? '');
    await prefs.setString(_stateKey, _state ?? '');
    await prefs.setString(_countryKey, _country ?? '');
    if (_temperature != null) {
      await prefs.setDouble(_tempKey, _temperature!);
    }
    await prefs.setString(_weatherLabelKey, _weatherLabel ?? '');
  }

  String? _pickFirstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  String _weatherLabelForCode(int code) {
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return 'Rain';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return 'Snow';
      case 95:
      case 96:
      case 99:
        return 'Storm';
      default:
        return 'Weather';
    }
  }
}
