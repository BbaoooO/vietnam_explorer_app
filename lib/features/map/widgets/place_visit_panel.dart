import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/place_visit_info.dart';

class PlaceVisitPanel extends StatelessWidget {
  const PlaceVisitPanel({super.key, required this.placeId});
  final String placeId;

  String money(int value) {
    if (value == 0) return 'Miễn phí';
    final digits = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.',
    );
    return '$digits đ';
  }

  Widget heading(String label) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget rateRow(BuildContext context, TicketRate rate) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE0E6E3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(rate.label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(money(rate.priceVnd), style: const TextStyle(
        color: Color(0xFF0F4C3A), fontWeight: FontWeight.bold,
      )),
      const SizedBox(height: 4),
      Text(rate.condition),
      if (rate.validFrom != null || rate.validUntil != null)
        Text('Thời hạn: ${rate.validFrom ?? 'không công bố'} → ${rate.validUntil ?? 'không công bố'}'),
      if (!rate.appliesOn(DateTime.now()))
        const Text('Hiện ngoài thời hạn ưu đãi này.', style: TextStyle(color: Colors.deepOrange)),
    ]),
  );

  Future<void> openSource(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được trang nguồn.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = visitInfoFor(placeId);
    const weekdayNames = <int, String>{
      1: 'Thứ 2', 2: 'Thứ 3', 3: 'Thứ 4', 4: 'Thứ 5',
      5: 'Thứ 6', 6: 'Thứ 7', 7: 'Chủ nhật',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F9F7),
        border: Border.all(color: const Color(0xFFDDE8E1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Vé & giờ tham quan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        heading('Giờ mở cửa'),
        Text(info.openingHours),
        heading('Sáng · Trưa · Chiều · Tối'),
        for (final period in info.periods)
          Padding(padding: const EdgeInsets.only(bottom: 6),
              child: Text('${period.label}: ${period.detail}')),
        heading('Bảng giá & đối tượng ưu đãi'),
        if (info.packages.isEmpty)
          const Text('Chưa cập nhật bảng giá. Không mặc định địa điểm này miễn phí.'),
        for (final package in info.packages) ...[
          Text(package.label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text('${package.rates.length} mức giá'),
          if (package.weekdays.isNotEmpty)
            Text('Lịch: ${package.weekdays.map((d) => weekdayNames[d] ?? '$d').join(', ')}'),
          if (package.note.isNotEmpty) Text(package.note),
          const SizedBox(height: 8),
          for (final rate in package.rates) rateRow(context, rate),
        ],
        if (info.extras.isNotEmpty) ...[
          heading('Dịch vụ bổ sung'),
          for (final rate in info.extras) rateRow(context, rate),
        ],
        heading('Lưu ý'),
        for (final note in info.notes)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('• $note')),
        const Text('Vé còn lại: liên hệ nơi bán vé.'),
        if (info.checkedOn != null)
          Text('Đối chiếu: ${info.checkedOn}. Giá có thể thay đổi.'),
        Wrap(spacing: 8, children: [
          for (final source in info.sources)
            TextButton.icon(
              onPressed: () => openSource(context, source.url),
              icon: const Icon(Icons.open_in_new, size: 15),
              label: Text(source.label),
            ),
        ]),
      ]),
    );
  }
}