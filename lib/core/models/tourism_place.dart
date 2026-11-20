import 'package:google_maps_flutter/google_maps_flutter.dart';

class TourismPlace {
  final String id;
  final String? destinationId;
  final String name;
  // Nhãn khu vực
  final String province;
  final String region;
  final String category;
  final String description;
  final LatLng position;
  final String imageFile;
  final String imageAuthor;
  final String imageLicense;
  final String imageLicenseUrl;
  final String sourceUrl;
  final String coordinateNote;

  const TourismPlace({
    required this.id,
    required this.name,
    this.destinationId,
    required this.province,
    required this.region,
    required this.category,
    required this.description,
    required this.position,
    this.imageFile = '',
    this.imageAuthor = '',
    this.imageLicense = '',
    this.imageLicenseUrl = '',
    this.sourceUrl = '',
    this.coordinateNote = '',
  });

  String get imageUrl => imageFile.isEmpty
      ? ''
      : Uri.https(
          'commons.wikimedia.org',
          '/wiki/Special:FilePath/$imageFile',
          {'width': '960'},
        ).toString();

  String get imageSourceUrl => imageFile.isEmpty
      ? ''
      : Uri.https('commons.wikimedia.org', '/wiki/File:$imageFile').toString();
}
