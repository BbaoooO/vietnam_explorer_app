import 'package:flutter/material.dart';

class PlannerItem {
  final String id;
  final String time;
  final String title;
  final String description;
  final IconData icon;
  final String estimatedCost;
  final bool isCompleted;

  PlannerItem({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
    required this.estimatedCost,
    this.isCompleted = false,
  });
}

class DailyItinerary {
  final int day;
  final String date;
  final List<PlannerItem> items;

  DailyItinerary({
    required this.day,
    required this.date,
    required this.items,
  });
}

