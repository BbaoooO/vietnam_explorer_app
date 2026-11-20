const travelSchema = <String>[
  '''
  CREATE TABLE destinations (
    id TEXT PRIMARY KEY NOT NULL,
    position INTEGER NOT NULL,
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    region TEXT NOT NULL,
    image TEXT NOT NULL,
    rating REAL NOT NULL,
    description TEXT NOT NULL,
    best_time TEXT NOT NULL,
    duration TEXT NOT NULL,
    budget TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL
  )
  ''',
  '''
  CREATE TABLE places (
    id TEXT PRIMARY KEY NOT NULL,
    position INTEGER NOT NULL,
    destination_id TEXT REFERENCES destinations(id),
    name TEXT NOT NULL,
    province TEXT NOT NULL,
    region TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    image_file TEXT NOT NULL,
    image_author TEXT NOT NULL,
    image_license TEXT NOT NULL,
    image_license_url TEXT NOT NULL,
    source_url TEXT NOT NULL,
    coordinate_note TEXT NOT NULL
  )
  ''',
  '''
  CREATE TABLE favorites (
    user_id TEXT NOT NULL,
    destination_id TEXT REFERENCES destinations(id),
    place_id TEXT REFERENCES places(id),
    saved_at INTEGER NOT NULL,
    CHECK ((destination_id IS NULL) <> (place_id IS NULL)),
    UNIQUE (user_id, destination_id),
    UNIQUE (user_id, place_id)
  )
  ''',
  '''
  CREATE TABLE trips (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    title TEXT NOT NULL CHECK (length(trim(title)) > 0),
    start_day TEXT NOT NULL,
    end_day TEXT NOT NULL CHECK (end_day >= start_day),
    UNIQUE (user_id, id)
  )
  ''',
  '''
  CREATE TABLE trip_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    trip_id INTEGER NOT NULL,
    destination_id TEXT REFERENCES destinations(id),
    place_id TEXT REFERENCES places(id),
    title TEXT NOT NULL CHECK (length(trim(title)) > 0),
    notes TEXT NOT NULL,
    day TEXT NOT NULL,
    minute INTEGER NOT NULL CHECK (minute BETWEEN 0 AND 1439),
    cost_vnd INTEGER CHECK (cost_vnd >= 0),
    completed INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)),
    CHECK (destination_id IS NULL OR place_id IS NULL),
    FOREIGN KEY (user_id, trip_id) REFERENCES trips(user_id, id) ON DELETE CASCADE
  )
  ''',
  '''
  CREATE TABLE visits (
    user_id TEXT NOT NULL,
    place_id TEXT NOT NULL REFERENCES places(id),
    visited_at INTEGER NOT NULL,
    PRIMARY KEY (user_id, place_id)
  )
  ''',
  '''
  CREATE TABLE recent_places (
    user_id TEXT NOT NULL,
    place_id TEXT NOT NULL REFERENCES places(id),
    viewed_at INTEGER NOT NULL,
    PRIMARY KEY (user_id, place_id)
  )
  ''',
  'CREATE TABLE device_migrations (id TEXT PRIMARY KEY NOT NULL)',
  'CREATE INDEX places_destination ON places(destination_id)',
  'CREATE INDEX items_schedule ON trip_items(user_id, trip_id, day, minute)',
  'CREATE INDEX recent_order ON recent_places(user_id, viewed_at DESC)',
];

const bookingSchema = <String>[
  '''
  CREATE TABLE experience_bookings (
    id TEXT PRIMARY KEY NOT NULL,
    user_id TEXT NOT NULL,
    experience_id TEXT NOT NULL,
    title TEXT NOT NULL,
    place_id TEXT NOT NULL REFERENCES places(id),
    day TEXT NOT NULL,
    minute INTEGER NOT NULL CHECK (minute BETWEEN 0 AND 1439),
    guests INTEGER NOT NULL CHECK (guests > 0),
    unit_price_vnd INTEGER NOT NULL CHECK (unit_price_vnd >= 0),
    created_at INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX bookings_by_user ON experience_bookings(user_id, created_at DESC)',
  'ALTER TABLE trip_items ADD COLUMN booking_id TEXT REFERENCES experience_bookings(id)',
  'CREATE UNIQUE INDEX trip_items_booking ON trip_items(booking_id)',
];
