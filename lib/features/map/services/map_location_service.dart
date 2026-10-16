import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_exception.dart';

Future<LatLng> getMapLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const MapRoutesException(
      'Hãy bật GPS hoặc chọn một địa điểm làm điểm đi.',
    );
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw const MapRoutesException(
      'Quyền vị trí đang bị tắt. Bật trong Cài đặt hoặc chọn điểm đi khác.',
    );
  }
  if (permission == LocationPermission.denied) {
    throw const MapRoutesException(
      'Chưa có quyền vị trí. Bạn có thể chọn một địa điểm làm điểm đi.',
    );
  }
  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  } on TimeoutException {
    throw const MapRoutesException(
      'Chưa xác định được vị trí. Thử lại hoặc chọn điểm đi khác.',
    );
  }
}
