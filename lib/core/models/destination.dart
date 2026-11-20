import 'package:google_maps_flutter/google_maps_flutter.dart';

class Destination {
  final String id;
  final LatLng center;
  final String title;
  final String subtitle;
  final String region;
  final String image;
  final double rating;
  final String description;
  final String bestTime;
  final String duration;
  final String budget;

  const Destination({
    required this.id,
    required this.center,
    required this.title,
    required this.subtitle,
    required this.region,
    required this.image,
    required this.rating,
    required this.description,
    required this.bestTime,
    required this.duration,
    required this.budget,
  });
}
