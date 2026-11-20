import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_exception.dart';

Future<LatLng> getMapLocation() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const MapRoutesException(
      'Turn on location services or choose a starting point.',
    );
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw const MapRoutesException(
      'Allow location access in Settings or choose another starting point.',
    );
  }
  if (permission == LocationPermission.denied) {
    throw const MapRoutesException(
      'Location access is needed. You can also choose a starting point.',
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
      'Could not find your location. Try again or choose another starting point.',
    );
  }
}
