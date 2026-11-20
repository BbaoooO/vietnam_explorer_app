import 'travel_records.dart';

class BookableExperience {
  const BookableExperience({
    required this.id,
    required this.title,
    required this.placeId,
    required this.priceVnd,
    required this.startMinutes,
    required this.maxGuests,
  });

  static const lanternNightWalkTitle = 'Lantern Night Walk';

  static const lanternNightWalk = BookableExperience(
    id: 'lantern_night_walk',
    title: lanternNightWalkTitle,
    placeId: 'hoi_an',
    priceVnd: 150000,
    startMinutes: [1080, 1140, 1200],
    maxGuests: 8,
  );

  static BookableExperience? find(String id) =>
      id == lanternNightWalk.id ? lanternNightWalk : null;

  final String id;
  final String title;
  final String placeId;
  final int priceVnd;
  final List<int> startMinutes;
  final int maxGuests;
}

class ExperienceBooking {
  const ExperienceBooking({
    required this.id,
    required this.experienceId,
    required this.title,
    required this.placeId,
    required this.day,
    required this.minute,
    required this.guests,
    required this.unitPriceVnd,
    required this.tripId,
    required this.checkoutConfirmed,
  });

  final String id;
  final String experienceId;
  final String title;
  final String placeId;
  final String day;
  final int minute;
  final int guests;
  final int unitPriceVnd;
  final int? tripId;
  final bool checkoutConfirmed;

  int get totalVnd => guests * unitPriceVnd;

  bool fits(Trip trip) =>
      day.compareTo(trip.startDay) >= 0 && day.compareTo(trip.endDay) <= 0;

  factory ExperienceBooking.fromRow(Map<String, Object?> row) =>
      ExperienceBooking(
        id: row['id'] as String,
        experienceId: row['experience_id'] as String,
        title: row['title'] as String,
        placeId: row['place_id'] as String,
        day: row['day'] as String,
        minute: row['minute'] as int,
        guests: row['guests'] as int,
        unitPriceVnd: row['unit_price_vnd'] as int,
        tripId: row['trip_id'] as int?,
        checkoutConfirmed: row['checkout_confirmed'] == 1,
      );
}

String experienceDay(DateTime date) => date.toIso8601String().substring(0, 10);

// The time slot is a wall-clock time in Vietnam (UTC+7), regardless of the phone zone.
DateTime vietnamNow() => DateTime.now().toUtc().add(const Duration(hours: 7));

bool isFutureExperienceSlot(String day, int minute) {
  final date = DateTime.tryParse(day);
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(day) ||
      date == null ||
      experienceDay(date) != day) {
    return false;
  }
  final localTime = vietnamNow();
  final today = experienceDay(localTime);
  return day.compareTo(today) > 0 ||
      (day == today && minute > localTime.hour * 60 + localTime.minute);
}
