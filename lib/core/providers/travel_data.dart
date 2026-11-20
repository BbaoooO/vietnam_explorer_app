import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/destination.dart';
import '../models/tourism_place.dart';
import '../models/travel_records.dart';
import '../repositories/travel_repository.dart';

class TravelData extends ChangeNotifier {
  TravelData(this._repository, this.uid);

  final TravelRepository _repository;
  final String uid;
  List<Destination> _destinations = const [];
  List<TourismPlace> _places = const [];
  Map<String, Destination> _destinationById = const {};
  Map<String, TourismPlace> _placeById = const {};
  UserTravelRecords? _records;
  List<String> _legacyFavorites = const [];
  bool _disposed = false;
  Future<void> _pending = Future.value();

  List<Destination> get destinations => _destinations;
  List<TourismPlace> get places => _places;
  Set<CatalogRef> get favorites => _records?.favorites ?? const {};
  List<String> get recent => _records?.recent ?? const [];
  List<Trip> get trips => _records?.trips ?? const [];
  List<TripActivity> get activities => _records?.activities ?? const [];
  Map<String, DateTime> get visits => _records?.visits ?? const {};
  Set<String> get visitedAreas => {
    for (final id in visits.keys)
      if (place(id) case final entry?) entry.province,
  };
  bool get canImportLegacyFavorites =>
      _records?.legacyClaimed == false && _legacyFavorites.isNotEmpty;

  Destination? destination(String id) => _destinationById[id];
  TourismPlace? place(String id) => _placeById[id];

  String? title(CatalogRef target) => switch (target.kind) {
    CatalogKind.destination => destination(target.id)?.title,
    CatalogKind.place => place(target.id)?.name,
  };

  Future<void> load() async {
    _destinations = await _repository.loadDestinations();
    _places = await _repository.loadPlaces();
    _destinationById = {for (final item in _destinations) item.id: item};
    _placeById = {for (final item in _places) item.id: item};
    _records = await _repository.loadUser(uid);
    if (_records?.legacyClaimed == false) {
      try {
        final preferences = await SharedPreferences.getInstance();
        _legacyFavorites =
            (preferences.getStringList('map_saved_place_ids') ?? [])
                .where(_placeById.containsKey)
                .toList();
      } catch (_) {
        // SQLite remains usable when legacy preferences cannot be read.
      }
    }
    if (!_disposed) notifyListeners();
  }

  Future<T> _mutate<T>(Future<T> Function() write) {
    final next = _pending.then((_) async {
      final result = await write();
      _records = await _repository.loadUser(uid);
      if (!_disposed) notifyListeners();
      return result;
    });
    _pending = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Future<void> toggleFavorite(CatalogRef target) => _mutate(
    () => _repository.setFavorite(uid, target, !favorites.contains(target)),
  );

  Future<void> setFavorite(CatalogRef target, bool saved) =>
      _mutate(() => _repository.setFavorite(uid, target, saved));

  Future<void> importLegacyFavorites() =>
      _mutate(() => _repository.importLegacyFavorites(uid, _legacyFavorites));

  Future<void> rememberPlace(String id) =>
      _mutate(() => _repository.rememberPlace(uid, id));

  Future<void> recordVisit(String id) =>
      _mutate(() => _repository.recordVisit(uid, id));

  Future<int> addTrip(String title, String start, String end) =>
      _mutate(() => _repository.addTrip(uid, title, start, end));

  Future<void> deleteTrip(int id) =>
      _mutate(() => _repository.deleteTrip(uid, id));

  Future<void> saveActivity(TripActivity activity, {required bool isNew}) =>
      _mutate(() => _repository.saveActivity(uid, activity, isNew: isNew));

  Future<void> setActivityCompleted(int id, bool completed) =>
      _mutate(() => _repository.setActivityCompleted(uid, id, completed));

  Future<void> deleteActivity(int id) =>
      _mutate(() => _repository.deleteActivity(uid, id));

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
