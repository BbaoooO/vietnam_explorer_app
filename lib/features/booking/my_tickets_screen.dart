import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/experience_booking.dart';
import '../../core/providers/travel_data.dart';

String formatTicketVnd(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')} ₫';

String formatTicketDay(String day) => day.split('-').reversed.join('/');

String formatTicketTime(int minute) =>
    '${(minute ~/ 60).toString().padLeft(2, '0')}:${(minute % 60).toString().padLeft(2, '0')}';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = context.watch<TravelData>().bookings;
    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: SafeArea(
        child: tickets.isEmpty
            ? const Center(child: Text('You do not have any tickets yet.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: tickets.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) =>
                    ExperienceTicketCard(bookingId: tickets[index].id),
              ),
      ),
    );
  }
}

class ExperienceTicketCard extends StatefulWidget {
  const ExperienceTicketCard({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ExperienceTicketCard> createState() => _ExperienceTicketCardState();
}

class _ExperienceTicketCardState extends State<ExperienceTicketCard> {
  bool _choosingTrip = false;

  Future<void> _chooseTrip(ExperienceBooking ticket) async {
    if (_choosingTrip) return;
    final data = context.read<TravelData>();
    final eligible = data.trips.where(ticket.fits).toList();
    if (eligible.isEmpty) return;
    setState(() => _choosingTrip = true);
    try {
      final selection = await showDialog<int>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text('Select a trip'),
          children: [
            for (final trip in eligible)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, trip.id),
                child: Text(trip.title),
              ),
          ],
        ),
      );
      if (!mounted || selection == null) return;
      await data.addBookingToTrip(ticket.id, selection);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not add the ticket to the trip.')),
      );
    } finally {
      if (mounted) setState(() => _choosingTrip = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TravelData>();
    final ticket = data.bookings
        .where((entry) => entry.id == widget.bookingId)
        .firstOrNull;
    if (ticket == null) return const SizedBox.shrink();
    final trip = data.trips
        .where((entry) => entry.id == ticket.tripId)
        .firstOrNull;
    final canLink = data.trips.any(ticket.fits);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              '${formatTicketDay(ticket.day)} · ${formatTicketTime(ticket.minute)} Vietnam time · ${ticket.guests} guest${ticket.guests == 1 ? '' : 's'}',
            ),
            const SizedBox(height: 6),
            SelectableText('Ticket reference: ${ticket.id}'),
            const SizedBox(height: 8),
            Text(
              ticket.checkoutConfirmed ? 'Booked' : 'Order saved',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text('Total · ${formatTicketVnd(ticket.totalVnd)}'),
            const SizedBox(height: 8),
            if (trip != null)
              Text('Added to ${trip.title}')
            else if (canLink)
              OutlinedButton.icon(
                onPressed: _choosingTrip ? null : () => _chooseTrip(ticket),
                icon: const Icon(Icons.event_available_outlined),
                label: const Text('Add to Planner'),
              )
            else
              const Text(
                'Create a trip that covers the ticket date to add it to your itinerary.',
              ),
          ],
        ),
      ),
    );
  }
}
