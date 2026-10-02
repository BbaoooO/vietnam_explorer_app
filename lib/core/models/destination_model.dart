import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Destination {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final String imageUrl;
  final String entryFee;
  final String bestTime;
  final double rating;
  final int reviewCount;
  final LatLng position;
  final IconData icon;
  final String region;

  Destination({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.entryFee,
    required this.bestTime,
    required this.rating,
    required this.reviewCount,
    required this.position,
    required this.icon,
    required this.region,
  });
}