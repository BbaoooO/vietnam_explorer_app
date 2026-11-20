import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/experience_booking.dart';
import '../../core/providers/travel_data.dart';
import 'my_tickets_screen.dart';

String _newBookingCode() {
  final random = Random.secure();
  final code = List.generate(
    8,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  return 'VE-${code.toUpperCase()}';
}

class ExperienceBookingScreen extends StatefulWidget {
  const ExperienceBookingScreen({super.key, required this.offer});

  final BookableExperience offer;

  @override
  State<ExperienceBookingScreen> createState() =>
      _ExperienceBookingScreenState();
}

class _ExperienceBookingScreenState extends State<ExperienceBookingScreen> {
  late DateTime _day = DateUtils.dateOnly(
    vietnamNow().add(const Duration(days: 1)),
  );
  int? _minute;
  int _guests = 1;
  bool _saving = false;
  String? _error;
  ExperienceBooking? _booking;
  final _bookingCodes = <(String, int, int), String>{};

  Future<void> _pickDay() async {
    final today = DateUtils.dateOnly(vietnamNow());
    final lastDay = DateUtils.addDaysToDate(today, 90);
    final day = await showDatePicker(
      context: context,
      initialDate: _day.isBefore(today) ? today : _day,
      firstDate: today,
      lastDate: lastDay,
    );
    if (!mounted || day == null) return;
    setState(() {
      _day = day;
      _minute = null;
      _error = null;
    });
  }

  Future<void> _payDemo(int minute) async {
    if (_saving || _booking != null) return;
    final day = experienceDay(_day);
    if (!isFutureExperienceSlot(day, minute)) {
      setState(() {
        _minute = null;
        _error = 'Khung giờ này đã qua. Hãy chọn khung giờ khác.';
      });
      return;
    }

    final data = context.read<TravelData>();
    final key = (day, minute, _guests);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final ticket = await data.bookDemoExperience(
        id: _bookingCodes.putIfAbsent(key, _newBookingCode),
        experienceId: widget.offer.id,
        day: day,
        minute: minute,
        guests: _guests,
      );
      if (mounted) setState(() => _booking = ticket);
    } catch (_) {
      if (mounted)
        setState(() => _error = 'Chưa xác nhận được vé thử. Hãy thử lại.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;
    final minute = _minute;
    final offer = widget.offer;
    final day = experienceDay(_day);
    final availableSlots = offer.startMinutes
        .where((slot) => isFutureExperienceSlot(day, slot))
        .toList();
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(booking == null ? 'Đặt vé trải nghiệm' : 'Đã tạo vé thử'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: booking != null
                ? [
                    const Text('Vé thử đã được lưu trong Hồ sơ → Vé của tôi.'),
                    const SizedBox(height: 12),
                    ExperienceTicketCard(bookingId: booking.id),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Xong'),
                    ),
                  ]
                : [
                    Text(offer.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Phố cổ Hội An · ${formatTicketVnd(offer.priceVnd)}/khách',
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickDay,
                      icon: const Icon(Icons.event_outlined),
                      label: Text('Ngày trải nghiệm · ${formatTicketDay(day)}'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Khung giờ tại Hội An',
                      style: theme.textTheme.titleMedium,
                    ),
                    if (availableSlots.isEmpty)
                      const Text(
                        'Hôm nay đã hết khung giờ. Hãy chọn ngày khác.',
                      ),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final slot in availableSlots)
                          ChoiceChip(
                            label: Text(formatTicketTime(slot)),
                            selected: slot == minute,
                            onSelected: _saving
                                ? null
                                : (_) => setState(() {
                                    _minute = slot;
                                    _error = null;
                                  }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: _guests,
                      decoration: const InputDecoration(labelText: 'Số khách'),
                      items: [
                        for (var count = 1; count <= offer.maxGuests; count++)
                          DropdownMenuItem(
                            value: count,
                            child: Text('$count khách'),
                          ),
                      ],
                      onChanged: _saving
                          ? null
                          : (count) {
                              if (count != null)
                                setState(() => _guests = count);
                            },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tổng tiền thử · ${formatTicketVnd(offer.priceVnd * _guests)}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    const Text('Thanh toán mô phỏng, không thu tiền.'),
                    if (_error case final error?) ...[
                      const SizedBox(height: 8),
                      Text(
                        error,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed:
                          _saving ||
                              minute == null ||
                              !availableSlots.contains(minute)
                          ? null
                          : () => _payDemo(minute),
                      child: Text(
                        _saving ? 'Đang tạo vé thử…' : 'Thanh toán thử',
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
