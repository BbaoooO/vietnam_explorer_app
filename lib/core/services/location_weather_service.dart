import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
class LocationWeatherService {
  static Future<Map<String, dynamic>> load() async {
    // Kiểm tra GPS
    final enabled =
    await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      throw Exception('Hãy bật GPS trên điện thoại');
    }

    // Kiểm tra quyền
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Ứng dụng chưa được cấp quyền vị trí');
    }

    // Lấy vị trí thật
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );

    // Lấy tên địa điểm từ dịch vụ reverse geocoding.
    // Nếu dịch vụ không phản hồi, thời tiết vẫn được tải bình thường.
    String city = 'Vị trí hiện tại';
    try {
      final locationUri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': position.latitude.toString(),
          'lon': position.longitude.toString(),
          'zoom': '10',
          'addressdetails': '1',
          'accept-language': 'vi',
        },
      );
      final locationResponse = await http.get(
        locationUri,
        headers: {
          'User-Agent': 'VietnamExplorerApp/1.0 (Flutter educational project)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 12));

      if (locationResponse.statusCode == 200) {
        final locationData = jsonDecode(locationResponse.body)
        as Map<String, dynamic>;
        final address = locationData['address'];
        if (address is Map<String, dynamic>) {
          final name = address['city'] ??
              address['town'] ??
              address['municipality'] ??
              address['county'] ??
              address['state'] ??
              address['province'];
          if (name is String && name.trim().isNotEmpty) {
            city = name.trim();
          }
        }
      } else {
        debugPrint('Reverse geocoding HTTP: ${locationResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Reverse geocoding: $e');
    }

    // Gọi API thời tiết
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '${position.latitude}',
        'longitude': '${position.longitude}',
        'current':
        'temperature_2m,relative_humidity_2m,weather_code',
        'timezone': 'auto',
      },
    );

    final response = await http.get(uri).timeout(
      const Duration(seconds: 20),
    );

    if (response.statusCode != 200) {
      throw Exception('Không tải được thời tiết');
    }

    final data = jsonDecode(response.body);
    final current = data['current'];

    return {
      'city': city,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'temperature': current['temperature_2m'],
      'humidity': current['relative_humidity_2m'],
      'weatherCode': current['weather_code'],
    };
  }
}