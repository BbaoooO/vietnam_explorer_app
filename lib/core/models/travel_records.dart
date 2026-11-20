enum CatalogKind { destination, place }

typedef CatalogRef = ({CatalogKind kind, String id});

CatalogRef destinationRef(String id) => (kind: CatalogKind.destination, id: id);
CatalogRef placeRef(String id) => (kind: CatalogKind.place, id: id);

typedef PlanDraft = ({String title, CatalogRef? target});

class Trip {
  const Trip({
    required this.id,
    required this.title,
    required this.startDay,
    required this.endDay,
  });

  final int id;
  final String title;
  final String startDay;
  final String endDay;

  factory Trip.fromRow(Map<String, Object?> row) => Trip(
    id: row['id'] as int,
    title: row['title'] as String,
    startDay: row['start_day'] as String,
    endDay: row['end_day'] as String,
  );
}

class TripActivity {
  const TripActivity({
    required this.id,
    required this.tripId,
    required this.title,
    required this.notes,
    required this.day,
    required this.minute,
    required this.costVnd,
    required this.completed,
    required this.target,
    this.bookingId,
  });

  final int id;
  final int tripId;
  final String title;
  final String notes;
  final String day;
  final int minute;
  final int? costVnd;
  final bool completed;
  final CatalogRef? target;
  final String? bookingId;

  factory TripActivity.fromRow(Map<String, Object?> row) => TripActivity(
    id: row['id'] as int,
    tripId: row['trip_id'] as int,
    title: row['title'] as String,
    notes: row['notes'] as String,
    day: row['day'] as String,
    minute: row['minute'] as int,
    costVnd: row['cost_vnd'] as int?,
    completed: row['completed'] == 1,
    target: catalogRefFromRow(row),
    bookingId: row['booking_id'] as String?,
  );
}

CatalogRef? catalogRefFromRow(Map<String, Object?> row) {
  if (row['destination_id'] case final String id) return destinationRef(id);
  if (row['place_id'] case final String id) return placeRef(id);
  return null;
}

Map<String, Object?> catalogRefColumns(CatalogRef? target) => {
  'destination_id': target?.kind == CatalogKind.destination ? target?.id : null,
  'place_id': target?.kind == CatalogKind.place ? target?.id : null,
};
