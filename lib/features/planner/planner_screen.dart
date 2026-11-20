import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_nav.dart';
import '../../core/explorer_app_bar.dart';
import '../../core/models/travel_records.dart';
import '../../core/models/tourism_place.dart';
import '../map/models/place_selection.dart';
import '../map/widgets/map_place_picker.dart';
import '../../core/providers/travel_data.dart';

String _dayKey(DateTime day) => day.toIso8601String().substring(0, 10);

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  int? _tripId;
  bool _busy = false;

  void _writeError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not update the itinerary. Please try again.'),
      ),
    );
  }

  Future<void> _write(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      _writeError();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createTrip() async {
    final data = context.read<TravelData>();
    final result = await showDialog<({String title, String start, String end})>(
      context: context,
      builder: (_) => const _TripDialog(),
    );
    if (!mounted || result == null) return;
    await _write(() async {
      final id = await data.addTrip(result.title, result.start, result.end);
      if (mounted) setState(() => _tripId = id);
    });
  }

  Future<void> _editActivity(
    Trip trip, {
    TripActivity? activity,
    PlanDraft? draft,
  }) async {
    final data = context.read<TravelData>();
    final navigation = context.read<AppNav>();
    final result = await showDialog<TripActivity>(
      context: context,
      builder: (_) => _ActivityDialog(
        trip: trip,
        activity: activity,
        draft: draft,
        places: data.places,
        targetTitle: data.title,
      ),
    );
    if (!mounted || result == null) return;
    await _write(() async {
      await data.saveActivity(result, isNew: activity == null);
      if (mounted && draft != null && navigation.plannerDraft.value == draft) {
        navigation.plannerDraft.value = null;
      }
    });
  }

  Future<void> _deleteTrip(Trip trip) async {
    final data = context.read<TravelData>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete trip?'),
        content: Text('Activities in “${trip.title}” will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _write(() => data.deleteTrip(trip.id));
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<TravelData>();
    final navigation = context.read<AppNav>();
    final trip = data.trips.isEmpty
        ? null
        : data.trips.where((trip) => trip.id == _tripId).firstOrNull ??
              data.trips.first;
    final activities = data.activities
        .where((item) => item.tripId == trip?.id)
        .toList();
    return Scaffold(
      appBar: const ExplorerAppBar(),
      floatingActionButton: trip == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _busy ? null : () => _editActivity(trip),
              icon: const Icon(Icons.add),
              label: const Text('Add activity'),
            ),
      body: ValueListenableBuilder<PlanDraft?>(
        valueListenable: navigation.plannerDraft,
        builder: (context, draft, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            Text(
              'Trip itinerary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (draft != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(draft.title),
                  subtitle: Text(
                    trip == null
                        ? 'Create a trip to add this activity.'
                        : 'Ready to add to ${trip.title}',
                  ),
                  onTap: _busy || trip == null
                      ? null
                      : () => _editActivity(trip, draft: draft),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trip != null)
                        IconButton(
                          tooltip: 'Add place to trip',
                          onPressed: _busy
                              ? null
                              : () => _editActivity(trip, draft: draft),
                          icon: const Icon(Icons.add),
                        ),
                      IconButton(
                        tooltip: 'Dismiss suggestion',
                        onPressed: () => navigation.plannerDraft.value = null,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            if (trip != null) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      key: ValueKey(trip.id),
                      initialValue: trip.id,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Trip'),
                      items: [
                        for (final entry in data.trips)
                          DropdownMenuItem(
                            value: entry.id,
                            child: Text(
                              entry.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _busy
                          ? null
                          : (id) => setState(() => _tripId = id),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete trip',
                    onPressed: _busy ? null : () => _deleteTrip(trip),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${trip.startDay} → ${trip.endDay}'),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _busy ? null : _createTrip,
                icon: const Icon(Icons.add),
                label: const Text('Create trip'),
              ),
            ),
            const SizedBox(height: 8),
            if (activities.isEmpty)
              Text(
                trip == null
                    ? 'You have no trips yet.'
                    : 'This trip has no activities yet.',
              ),
            for (var i = 0; i < activities.length; i++) ...[
              if (i == 0 || activities[i - 1].day != activities[i].day)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                  child: Text(
                    activities[i].day,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              _activityTile(context, data, navigation, trip!, activities[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _activityTile(
    BuildContext context,
    TravelData data,
    AppNav nav,
    Trip trip,
    TripActivity item,
  ) {
    final time = TimeOfDay(hour: item.minute ~/ 60, minute: item.minute % 60);
    final target = item.target;
    return Card(
      child: ListTile(
        leading: Checkbox(
          value: item.completed,
          onChanged: _busy
              ? null
              : (value) => _write(
                  () => data.setActivityCompleted(item.id, value ?? false),
                ),
        ),
        title: Text(item.title),
        subtitle: Text(
          [
            time.format(context),
            if (item.costVnd != null && item.bookingId == null)
              '${item.costVnd} VND',
            if (item.bookingId != null) 'Ticket price: ${item.costVnd} VND',
            if (item.notes.isNotEmpty) item.notes,
          ].join(' · '),
        ),
        trailing: PopupMenuButton<String>(
          enabled: !_busy,
          onSelected: (action) {
            switch (action) {
              case 'edit':
                _editActivity(trip, activity: item);
              case 'map':
                if (target != null) nav.openMap(target);
              case 'delete':
                _write(() => data.deleteActivity(item.id));
            }
          },
          itemBuilder: (_) => [
            if (item.bookingId == null)
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (target != null)
              const PopupMenuItem(value: 'map', child: Text('Open map')),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                item.bookingId == null
                    ? 'Delete activity'
                    : 'Remove ticket from itinerary',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDialog extends StatefulWidget {
  const _TripDialog();

  @override
  State<_TripDialog> createState() => _TripDialogState();
}

class _TripDialogState extends State<_TripDialog> {
  final _title = TextEditingController();
  final _form = GlobalKey<FormState>();
  DateTime _start = DateUtils.dateOnly(DateTime.now());
  DateTime _end = DateUtils.dateOnly(DateTime.now());

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool start}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: start ? _start : _end,
      firstDate: start ? DateTime(2000) : _start,
      lastDate: DateTime(2100),
    );
    if (!mounted || date == null) return;
    setState(() {
      if (start) {
        _start = date;
        if (_end.isBefore(date)) _end = date;
      } else {
        _end = date;
      }
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create trip'),
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _title,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Trip name'),
            validator: (text) => text == null || text.trim().isEmpty
                ? 'Enter a trip name'
                : null,
          ),
          TextButton(
            onPressed: () => _pickDate(start: true),
            child: Text('Start date · ${_dayKey(_start)}'),
          ),
          TextButton(
            onPressed: () => _pickDate(start: false),
            child: Text('End date · ${_dayKey(_end)}'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(context, (
            title: _title.text.trim(),
            start: _dayKey(_start),
            end: _dayKey(_end),
          ));
        },
        child: const Text('Create'),
      ),
    ],
  );
}

class _ActivityDialog extends StatefulWidget {
  const _ActivityDialog({
    required this.trip,
    required this.places,
    required this.targetTitle,
    this.activity,
    this.draft,
  });

  final Trip trip;
  final TripActivity? activity;
  final PlanDraft? draft;
  final List<TourismPlace> places;
  final String? Function(CatalogRef) targetTitle;

  @override
  State<_ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<_ActivityDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(
    text: widget.activity?.title ?? widget.draft?.title ?? '',
  );
  late final _notes = TextEditingController(text: widget.activity?.notes ?? '');
  late final _cost = TextEditingController(
    text: widget.activity?.costVnd?.toString() ?? '',
  );
  late CatalogRef? _target = widget.activity?.target ?? widget.draft?.target;
  late DateTime _day = DateTime.parse(
    widget.activity?.day ?? widget.trip.startDay,
  );
  late TimeOfDay _time = TimeOfDay(
    hour: (widget.activity?.minute ?? 540) ~/ 60,
    minute: (widget.activity?.minute ?? 540) % 60,
  );

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.activity == null ? 'Add activity' : 'Edit activity'),
    scrollable: true,
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Activity name'),
            validator: (text) => text == null || text.trim().isEmpty
                ? 'Enter an activity name'
                : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: Text(
              _target == null
                  ? 'Choose a place (optional)'
                  : widget.targetTitle(_target!) ?? _target!.id,
            ),
            trailing: _target == null
                ? null
                : IconButton(
                    tooltip: 'Remove linked place',
                    onPressed: () => setState(() => _target = null),
                    icon: const Icon(Icons.close),
                  ),
            onTap: () async {
              final result = await Navigator.of(context).push<RouteLocation>(
                MaterialPageRoute<RouteLocation>(
                  builder: (_) => MapPlacePicker(
                    title: 'Choose a place',
                    places: widget.places,
                  ),
                ),
              );
              if (!mounted) return;
              if (result?.place case final TourismPlace place) {
                setState(() {
                  _target = placeRef(place.id);
                  if (_title.text.trim().isEmpty) _title.text = place.name;
                });
              }
            },
          ),
          TextFormField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes'),
          ),
          TextFormField(
            controller: _cost,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Estimated cost (VND)',
            ),
            validator: (text) {
              final value = text?.trim() ?? '';
              if (value.isEmpty) return null;
              final parsed = int.tryParse(value);
              return parsed == null || parsed < 0
                  ? 'Enter a whole number of zero or more'
                  : null;
            },
          ),
          TextButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _day,
                firstDate: DateTime.parse(widget.trip.startDay),
                lastDate: DateTime.parse(widget.trip.endDay),
              );
              if (mounted && date != null) setState(() => _day = date);
            },
            child: Text('Date · ${_dayKey(_day)}'),
          ),
          TextButton(
            onPressed: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (mounted && time != null) setState(() => _time = time);
            },
            child: Text('Time · ${_time.format(context)}'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.pop(
            context,
            TripActivity(
              id: widget.activity?.id ?? 0,
              tripId: widget.trip.id,
              title: _title.text.trim(),
              notes: _notes.text.trim(),
              day: _dayKey(_day),
              minute: _time.hour * 60 + _time.minute,
              costVnd: int.tryParse(_cost.text.trim()),
              completed: widget.activity?.completed ?? false,
              target: _target,
            ),
          );
        },
        child: const Text('Save'),
      ),
    ],
  );
}
