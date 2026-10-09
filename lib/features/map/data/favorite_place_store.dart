import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'tourism_places.dart';

class FavoritePlaceStore {
  FavoritePlaceStore._();
  static final instance = FavoritePlaceStore._();
  Future<Database>? _opening;

  Future<Database> get database async {
    try {
      return await (_opening ??= _open());
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<Database> _open() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      path.join(directory, 'map_favorite_places.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE favorite_places (
            place_id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            province TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            saved_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE map_metadata (
            meta_key TEXT PRIMARY KEY,
            meta_value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Map<String, Object?> _row(TourismPlace place) => {
    'place_id': place.id,
    'name': place.name,
    'province': place.province,
    'latitude': place.position.latitude,
    'longitude': place.position.longitude,
    'saved_at': DateTime.now().toUtc().toIso8601String(),
  };

  Future<Set<String>> readIds() async {
    final db = await database;
    final rows = await db.query('favorite_places', columns: ['place_id']);
    return rows.map((row) => row['place_id'] as String).toSet();
  }

  Future<void> save(TourismPlace place) async {
    final db = await database;
    await db.insert('favorite_places', _row(place),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> remove(String placeId) async {
    final db = await database;
    await db.delete('favorite_places', where: 'place_id = ?', whereArgs: [placeId]);
  }

  Future<void> migrateLegacyPlaces(List<TourismPlace> places) async {
    final db = await database;
    await db.transaction((txn) async {
      final migrated = await txn.query('map_metadata',
        where: 'meta_key = ?', whereArgs: ['legacy_favorites_migrated']);
      if (migrated.isNotEmpty) return;
      for (final place in places) {
        await txn.insert('favorite_places', _row(place),
          conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await txn.insert('map_metadata', {
        'meta_key': 'legacy_favorites_migrated', 'meta_value': '1',
      });
    });
  }
}
