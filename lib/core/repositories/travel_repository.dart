import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../data/destination_seed.dart';
import '../data/place_seed.dart';
import '../data/travel_schema.dart';
import '../models/destination.dart';
import '../models/tourism_place.dart';
import '../models/travel_records.dart';

typedef UserTravelRecords = ({
  Set<CatalogRef> favorites,
  List<String> recent,
  List<Trip> trips,
  List<TripActivity> activities,
  Map<String, DateTime> visits,
  bool legacyClaimed,
});

class TravelRepository {
  TravelRepository({DatabaseFactory? factory, String? databasePath})
    : _factory = factory ?? databaseFactory,
      _databasePath = databasePath;

  final DatabaseFactory _factory;
  final String? _databasePath;
  Future<Database>? _opening;

  Future<Database> _open() async {
    final file =
        _databasePath ??
        path.join(await _factory.getDatabasesPath(), 'vietnam_explorer.db');
    return _factory.openDatabase(
      file,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
      ),
    );
  }

  Future<Database> get _database async {
    final opening = _opening ??= _open();
    try {
      return await opening;
    } catch (_) {
      if (identical(_opening, opening)) _opening = null;
      rethrow;
    }
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }

  Future<void> _create(Database db, int version) async {
    for (final statement in travelSchema) {
      await db.execute(statement);
    }
    final batch = db.batch();
    for (final (index, destination) in destinationSeed.indexed) {
      batch.insert('destinations', {
        'id': destination.id,
        'position': index,
        'title': destination.title,
        'subtitle': destination.subtitle,
        'region': destination.region,
        'image': destination.image,
        'rating': destination.rating,
        'description': destination.description,
        'best_time': destination.bestTime,
        'duration': destination.duration,
        'budget': destination.budget,
        'latitude': destination.center.latitude,
        'longitude': destination.center.longitude,
      });
    }
    for (final (index, place) in placeSeed.indexed) {
      batch.insert('places', {
        'id': place.id,
        'position': index,
        'destination_id': place.destinationId,
        'name': place.name,
        'province': place.province,
        'region': place.region,
        'category': place.category,
        'description': place.description,
        'latitude': place.position.latitude,
        'longitude': place.position.longitude,
        'image_file': place.imageFile,
        'image_author': place.imageAuthor,
        'image_license': place.imageLicense,
        'image_license_url': place.imageLicenseUrl,
        'source_url': place.sourceUrl,
        'coordinate_note': place.coordinateNote,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Destination>> loadDestinations() async {
    final rows = await (await _database).query(
      'destinations',
      orderBy: 'position',
    );
    return List.unmodifiable(
      rows.map(
        (row) => Destination(
          id: row['id'] as String,
          title: row['title'] as String,
          subtitle: row['subtitle'] as String,
          region: row['region'] as String,
          image: row['image'] as String,
          rating: (row['rating'] as num).toDouble(),
          description: row['description'] as String,
          bestTime: row['best_time'] as String,
          duration: row['duration'] as String,
          budget: row['budget'] as String,
          center: _position(row),
        ),
      ),
    );
  }

  Future<List<TourismPlace>> loadPlaces() async {
    final rows = await (await _database).query('places', orderBy: 'position');
    return List.unmodifiable(
      rows.map(
        (row) => TourismPlace(
          id: row['id'] as String,
          destinationId: row['destination_id'] as String?,
          name: row['name'] as String,
          province: row['province'] as String,
          region: row['region'] as String,
          category: row['category'] as String,
          description: row['description'] as String,
          position: _position(row),
          imageFile: row['image_file'] as String,
          imageAuthor: row['image_author'] as String,
          imageLicense: row['image_license'] as String,
          imageLicenseUrl: row['image_license_url'] as String,
          sourceUrl: row['source_url'] as String,
          coordinateNote: row['coordinate_note'] as String,
        ),
      ),
    );
  }

  LatLng _position(Map<String, Object?> row) => LatLng(
    (row['latitude'] as num).toDouble(),
    (row['longitude'] as num).toDouble(),
  );

  Future<UserTravelRecords> loadUser(String uid) async {
    final db = await _database;
    return db.transaction((txn) async {
      Future<List<Map<String, Object?>>> rows(
        String table, {
        String? orderBy,
      }) => txn.query(
        table,
        where: 'user_id = ?',
        whereArgs: [uid],
        orderBy: orderBy,
      );
      final favorites = await rows('favorites', orderBy: 'saved_at DESC');
      final recent = await rows(
        'recent_places',
        orderBy: 'viewed_at DESC, rowid DESC',
      );
      final trips = await rows('trips', orderBy: 'start_day, id');
      final activities = await rows('trip_items', orderBy: 'day, minute, id');
      final visits = await rows('visits');
      final legacy = await txn.query(
        'device_migrations',
        where: 'id = ?',
        whereArgs: ['map_saved_place_ids'],
      );
      return (
        favorites: Set<CatalogRef>.unmodifiable(
          favorites.map((row) => catalogRefFromRow(row)!),
        ),
        recent: List<String>.unmodifiable(
          recent.map((row) => row['place_id'] as String),
        ),
        trips: List<Trip>.unmodifiable(trips.map(Trip.fromRow)),
        activities: List<TripActivity>.unmodifiable(
          activities.map(TripActivity.fromRow),
        ),
        visits: Map<String, DateTime>.unmodifiable({
          for (final row in visits)
            row['place_id'] as String: DateTime.fromMillisecondsSinceEpoch(
              row['visited_at'] as int,
            ),
        }),
        legacyClaimed: legacy.isNotEmpty,
      );
    });
  }

  Future<void> setFavorite(String uid, CatalogRef target, bool saved) async {
    final db = await _database;
    if (saved) {
      await _saveFavorite(db, uid, target);
    } else {
      final column = target.kind == CatalogKind.place
          ? 'place_id'
          : 'destination_id';
      await db.delete(
        'favorites',
        where: 'user_id = ? AND $column = ?',
        whereArgs: [uid, target.id],
      );
    }
  }

  Future<void> _saveFavorite(
    DatabaseExecutor db,
    String uid,
    CatalogRef target,
  ) async {
    await db.insert('favorites', {
      'user_id': uid,
      ...catalogRefColumns(target),
      'saved_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> importLegacyFavorites(String uid, List<String> ids) async {
    final db = await _database;
    await db.transaction((txn) async {
      final previous = await txn.query(
        'device_migrations',
        where: 'id = ?',
        whereArgs: ['map_saved_place_ids'],
      );
      if (previous.isNotEmpty) return;
      final places = await txn.query('places', columns: ['id']);
      final known = places.map((row) => row['id']).toSet();
      for (final id in ids.toSet().where(known.contains)) {
        await _saveFavorite(txn, uid, placeRef(id));
      }
      await txn.insert('device_migrations', {'id': 'map_saved_place_ids'});
    });
  }

  Future<void> rememberPlace(String uid, String placeId) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.insert('recent_places', {
        'user_id': uid,
        'place_id': placeId,
        'viewed_at': DateTime.now().microsecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.rawDelete(
        '''
        DELETE FROM recent_places WHERE user_id = ? AND place_id NOT IN (
          SELECT place_id FROM recent_places WHERE user_id = ?
          ORDER BY viewed_at DESC, rowid DESC LIMIT 10
        )
      ''',
        [uid, uid],
      );
    });
  }

  Future<void> recordVisit(String uid, String placeId) async {
    await (await _database).insert('visits', {
      'user_id': uid,
      'place_id': placeId,
      'visited_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> addTrip(
    String uid,
    String title,
    String start,
    String end,
  ) async => (await _database).insert('trips', {
    'user_id': uid,
    'title': title,
    'start_day': start,
    'end_day': end,
  });

  Future<void> deleteTrip(String uid, int id) async {
    await (await _database).delete(
      'trips',
      where: 'user_id = ? AND id = ?',
      whereArgs: [uid, id],
    );
  }

  Future<void> saveActivity(
    String uid,
    TripActivity activity, {
    required bool isNew,
  }) async {
    final db = await _database;
    await db.transaction((txn) async {
      final trips = await txn.query(
        'trips',
        where: 'user_id = ? AND id = ?',
        whereArgs: [uid, activity.tripId],
      );
      if (trips.isEmpty)
        throw StateError('Trip does not exist for this account.');
      final trip = Trip.fromRow(trips.single);
      if (activity.day.compareTo(trip.startDay) < 0 ||
          activity.day.compareTo(trip.endDay) > 0) {
        throw ArgumentError('Activity date is outside the trip.');
      }
      final values = {
        'user_id': uid,
        'trip_id': activity.tripId,
        ...catalogRefColumns(activity.target),
        'title': activity.title,
        'notes': activity.notes,
        'day': activity.day,
        'minute': activity.minute,
        'cost_vnd': activity.costVnd,
        'completed': activity.completed ? 1 : 0,
      };
      if (isNew) {
        await txn.insert('trip_items', values);
      } else {
        final updated = await txn.update(
          'trip_items',
          values,
          where: 'user_id = ? AND trip_id = ? AND id = ?',
          whereArgs: [uid, activity.tripId, activity.id],
        );
        if (updated != 1) throw StateError('Activity no longer exists.');
      }
    });
  }

  Future<void> setActivityCompleted(String uid, int id, bool completed) async {
    final count = await (await _database).update(
      'trip_items',
      {'completed': completed ? 1 : 0},
      where: 'user_id = ? AND id = ?',
      whereArgs: [uid, id],
    );
    if (count != 1) throw StateError('Activity no longer exists.');
  }

  Future<void> deleteActivity(String uid, int id) async {
    await (await _database).delete(
      'trip_items',
      where: 'user_id = ? AND id = ?',
      whereArgs: [uid, id],
    );
  }
}
