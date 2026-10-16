import 'package:flutter/material.dart';

class PlaceVisitPanel extends StatelessWidget {
  const PlaceVisitPanel({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9F7),
        border: Border.all(color: const Color(0xFFDDE8E1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mô tả',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Sẽ cập nhật sau'),
        ],
      ),
    );
  }
}
