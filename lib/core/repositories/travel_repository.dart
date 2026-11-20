import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../data/destination_seed.dart';
import '../data/place_seed.dart';
import '../data/travel_schema.dart';
import '../models/destination.dart';
import '../models/experience_booking.dart';
import '../models/tourism_place.dart';
import '../models/travel_records.dart';

typedef UserTravelRecords = ({
  Set<CatalogRef> favorites,
  List<String> recent,
  List<Trip> trips,
  List<TripActivity> activities,
  List<ExperienceBooking> bookings,
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
        version: 6,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
        onUpgrade: (db, from, _) async {
          if (from < 2) await _createBookingSchema(db);
          if (from < 3) await _addBookingPaymentMethod(db);
          if (from < 4) await _addCheckoutConfirmation(db);
          if (from < 5) await _migrateEnglishContent(db);
          if (from < 6) await _addMissingPlaces(db);
        },
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
    await _createBookingSchema(db);
    await _addBookingPaymentMethod(db);
    await _addCheckoutConfirmation(db);
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
    _seedPlaces(batch);
    await batch.commit(noResult: true);
  }

  void _seedPlaces(Batch batch, {ConflictAlgorithm? conflictAlgorithm}) {
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
      }, conflictAlgorithm: conflictAlgorithm);
    }
  }

  Future<void> _addMissingPlaces(Database db) async {
    final batch = db.batch();
    _seedPlaces(batch, conflictAlgorithm: ConflictAlgorithm.ignore);
    await batch.commit(noResult: true);
  }

  Future<void> _createBookingSchema(Database db) async {
    for (final statement in bookingSchema) {
      await db.execute(statement);
    }
  }

  Future<void> _addBookingPaymentMethod(Database db) async {
    for (final statement in bookingPaymentSchema) {
      await db.execute(statement);
    }
  }

  Future<void> _addCheckoutConfirmation(Database db) async {
    for (final statement in bookingCheckoutSchema) {
      await db.execute(statement);
    }
  }

  Future<void> _migrateEnglishContent(Database db) async {
    final batch = db.batch();
    for (final place in placeSeed) {
      batch.update(
        'places',
        {
          'description': place.description,
          'coordinate_note': place.coordinateNote,
        },
        where: 'id = ?',
        whereArgs: [place.id],
      );
    }
    batch.execute(englishBookingNotesMigration);
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, Object?>>> _bookingRows(
    DatabaseExecutor db,
    String uid, {
    String? id,
  }) => db.rawQuery(
    '''
    SELECT booking.*, item.trip_id
    FROM experience_bookings booking
    LEFT JOIN trip_items item
      ON item.booking_id = booking.id AND item.user_id = booking.user_id
    WHERE booking.user_id = ? ${id == null ? '' : 'AND booking.id = ?'}
    ORDER BY booking.created_at DESC, booking.id
    ''',
    [uid, if (id != null) id],
  );

  Future<ExperienceBooking> confirmExperienceCheckout(
    String uid, {
    required String id,
    required String experienceId,
    required String day,
    required int minute,
    required int guests,
  }) async {
    final offer = BookableExperience.find(experienceId);
    if (offer == null ||
        !offer.startMinutes.contains(minute) ||
        guests < 1 ||
        guests > offer.maxGuests ||
        !RegExp(r'^VE-[A-F0-9]{16}$').hasMatch(id)) {
      throw ArgumentError('Invalid experience booking.');
    }
    return (await _database).transaction<ExperienceBooking>((txn) async {
      final rows = await _bookingRows(txn, uid, id: id);
      if (rows.isNotEmpty) {
        final existing = ExperienceBooking.fromRow(rows.single);
        if (!existing.checkoutConfirmed ||
            existing.experienceId != experienceId ||
            existing.day != day ||
            existing.minute != minute ||
            existing.guests != guests) {
          throw StateError('Booking reference already used.');
        }
        return existing;
      }
      if (!isFutureExperienceSlot(day, minute)) {
        throw ArgumentError('Choose a future time slot in Vietnam.');
      }
      await txn.insert('experience_bookings', {
        'id': id,
        'user_id': uid,
        'experience_id': offer.id,
        'title': offer.title,
        'place_id': offer.placeId,
        'day': day,
        'minute': minute,
        'guests': guests,
        'unit_price_vnd': offer.priceVnd,
        'checkout_confirmed': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      return ExperienceBooking.fromRow(
        (await _bookingRows(txn, uid, id: id)).single,
      );
    });
  }

  Future<void> addBookingToTrip(
    String uid,
    String bookingId,
    int tripId,
  ) async {
    final db = await _database;
    await db.transaction((txn) async {
      final bookings = await _bookingRows(txn, uid, id: bookingId);
      if (bookings.isEmpty)
        throw StateError('Booking not found for this account.');
      final booking = ExperienceBooking.fromRow(bookings.single);
      if (booking.tripId == tripId) return;
      if (booking.tripId != null)
        throw StateError('Booking is already on a trip.');

      final trips = await txn.query(
        'trips',
        where: 'user_id = ? AND id = ?',
        whereArgs: [uid, tripId],
      );
      if (trips.isEmpty || !booking.fits(Trip.fromRow(trips.single))) {
        throw ArgumentError('Choose a trip that covers the booking date.');
      }

      await txn.insert('trip_items', {
        'user_id': uid,
        'trip_id': tripId,
        'booking_id': booking.id,
        'place_id': booking.placeId,
        'title': booking.title,
        'notes':
            'Ticket reference: ${booking.id} · '
            '${booking.guests} guest${booking.guests == 1 ? '' : 's'}',
        'day': booking.day,
        'minute': booking.minute,
        'cost_vnd': booking.totalVnd,
      });
    });
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
      final bookings = await _bookingRows(txn, uid);
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
        bookings: List<ExperienceBooking>.unmodifiable(
          bookings.map(ExperienceBooking.fromRow),
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

  Future<void> updateTrip(
    String uid,
    int tripId, {
    required String title,
    required String start,
    required String end,
    required Set<String> ticketsToDetach,
  }) async {
    bool isValidDay(String value) {
      final parsed = DateTime.tryParse(value);
      return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) &&
          parsed != null &&
          experienceDay(parsed) == value;
    }

    if (title.trim().isEmpty ||
        !isValidDay(start) ||
        !isValidDay(end) ||
        start.compareTo(end) > 0) {
      throw ArgumentError('Invalid trip name or dates.');
    }
    final db = await _database;
    await db.transaction((txn) async {
      const tripFilter = 'user_id = ? AND trip_id = ?';
      const outsideDates = '$tripFilter AND (day < ? OR day > ?)';
      final outsideArgs = [uid, tripId, start, end];
      final outside = await txn.query(
        'trip_items',
        columns: ['booking_id'],
        where: outsideDates,
        whereArgs: outsideArgs,
      );
      final actualTickets = <String>{};
      for (final item in outside) {
        final ticketId = item['booking_id'] as String?;
        if (ticketId == null) {
          throw StateError('Move activities outside the new trip dates first.');
        }
        actualTickets.add(ticketId);
      }
      if (ticketsToDetach.length != actualTickets.length ||
          !ticketsToDetach.containsAll(actualTickets)) {
        throw StateError('Review the affected tickets again.');
      }
      final updated = await txn.update(
        'trips',
        {'title': title.trim(), 'start_day': start, 'end_day': end},
        where: 'user_id = ? AND id = ?',
        whereArgs: [uid, tripId],
      );
      if (updated != 1)
        throw StateError('Trip does not exist for this account.');
      if (actualTickets.isNotEmpty) {
        // A ticket is a separate record and remains in My Tickets.
        await txn.delete(
          'trip_items',
          where: '$outsideDates AND booking_id IS NOT NULL',
          whereArgs: outsideArgs,
        );
      }
    });
  }

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
          where:
              'user_id = ? AND trip_id = ? AND id = ? AND booking_id IS NULL',
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
