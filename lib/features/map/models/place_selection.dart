import '../../../core/models/tourism_place.dart';

class RouteLocation {
  const RouteLocation({required this.place});

  factory RouteLocation.fromPlace(TourismPlace place) {
    return RouteLocation(place: place);
  }

  final TourismPlace? place;
}
