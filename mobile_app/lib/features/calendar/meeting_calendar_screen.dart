import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

class MeetingCalendarScreen extends ConsumerStatefulWidget {
  const MeetingCalendarScreen({super.key});

  @override
  ConsumerState<MeetingCalendarScreen> createState() =>
      _MeetingCalendarScreenState();
}

class _MeetingCalendarScreenState extends ConsumerState<MeetingCalendarScreen> {
  late DateTime _selectedDate;
  String _selectedTypeFilter = 'All';
  bool _showMonthGrid = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = _dateOnly(DateTime.now());
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _combineDateAndTime(DateTime date, TimeOfDay tod) =>
      DateTime(date.year, date.month, date.day, tod.hour, tod.minute);

  void _showScheduleMeetingModal() {
    final titleCtrl = TextEditingController();
    final clientCtrl = TextEditingController();
    final linkCtrl = TextEditingController(
      text: 'https://meet.google.com/',
    );
    final locationCtrl = TextEditingController(text: 'Google Meet');
    final notesCtrl = TextEditingController();
    String selectedType = MeetingRecord.meetingTypes.first;
    DateTime pickedDate = _selectedDate;
    final defaultStart = DateTime.now().add(const Duration(minutes: 30));
    TimeOfDay pickedStartTime = TimeOfDay(
      hour: defaultStart.hour,
      minute: (defaultStart.minute ~/ 5) * 5,
    );
    int durationMinutes = 60;
    final selectedParticipants = <String>{
      'Himon Bhuyan',
      'Darshana Das',
      'Drishant Das',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final employees = ref.read(agencyStoreProvider).employees;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final previewStart =
                _combineDateAndTime(pickedDate, pickedStartTime);
            final previewEnd =
                previewStart.add(Duration(minutes: durationMinutes));
            final alarmAt =
                previewStart.subtract(const Duration(minutes: 10));

            return DraggableScrollableSheet(
              initialChildSize: 0.88,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 18,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 22,
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Text(
                        'Schedule Studio / Client Meeting',
                        style: Theme.of(ctx).textTheme.headlineMedium,
                      ),
                      Text(
                        'Includes a 10-minute pre-meeting wake alarm + FCM push to participants.',
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Meeting Title *',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                              ),
                              label: Text(
                                BhFormatters.dayMonth(pickedDate),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () async {
                                final res = await showDatePicker(
                                  context: ctx,
                                  initialDate: pickedDate,
                                  firstDate: DateTime.now()
                                      .subtract(const Duration(days: 90)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 365)),
                                );
                                if (res != null) {
                                  setModalState(
                                    () => pickedDate = _dateOnly(res),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.access_time_filled_rounded,
                                size: 17,
                              ),
                              label: Text(
                                BhFormatters.time12h(previewStart),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () async {
                                final res = await showTimePicker(
                                  context: ctx,
                                  initialTime: pickedStartTime,
                                );
                                if (res != null) {
                                  setModalState(() => pickedStartTime = res);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Duration:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          for (final mins in [30, 60, 90, 120])
                            ChoiceChip(
                              label: Text(
                                mins == 60
                                    ? '1 hr'
                                    : (mins == 90
                                        ? '1.5 hr'
                                        : (mins == 120 ? '2 hr' : '${mins}m')),
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: durationMinutes == mins,
                              onSelected: (_) =>
                                  setModalState(() => durationMinutes = mins),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.electricBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                AppColors.electricBlue.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.alarm_on_rounded,
                              size: 16,
                              color: AppColors.electricBlue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${BhFormatters.time12h(previewStart)} – ${BhFormatters.time12h(previewEnd)} • Alarm triggers 10 min before (${BhFormatters.time12h(alarmAt)})',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.electricBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedType,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Meeting Type',
                              ),
                              items: MeetingRecord.meetingTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        t,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setModalState(() => selectedType = v);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: clientCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Client / Company',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: locationCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Location / Platform',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: linkCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Online Meeting Link (Optional)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Invite Studio Participants:',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: employees.map((emp) {
                          final chosen =
                              selectedParticipants.contains(emp.name);
                          return FilterChip(
                            label: Text(
                              emp.name,
                              style: const TextStyle(fontSize: 11.5),
                            ),
                            selected: chosen,
                            onSelected: (v) {
                              setModalState(() {
                                if (v) {
                                  selectedParticipants.add(emp.name);
                                } else {
                                  selectedParticipants.remove(emp.name);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Meeting Agenda & Preparation Notes',
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty) return;
                            final start = _combineDateAndTime(
                              pickedDate,
                              pickedStartTime,
                            );
                            final end =
                                start.add(Duration(minutes: durationMinutes));
                            ref
                                .read(agencyStoreProvider.notifier)
                                .scheduleMeeting(
                                  title: titleCtrl.text.trim(),
                                  clientOrCompany: clientCtrl.text.trim(),
                                  meetingType: selectedType,
                                  startTime: start,
                                  endTime: end,
                                  location: locationCtrl.text.trim(),
                                  onlineLink: linkCtrl.text.trim().isEmpty
                                      ? null
                                      : linkCtrl.text.trim(),
                                  participants: selectedParticipants.toList(),
                                  notes: notesCtrl.text.trim(),
                                );
                            setState(() => _selectedDate = pickedDate);
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Scheduled "${titleCtrl.text.trim()}" at ${BhFormatters.time12h(start)} • Alarm set 10m before.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.event_available_rounded),
                          label: const Text('Schedule & Set 10m Alarm'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showEditMeetingModal(MeetingRecord mtg) async {
    final tCtrl = TextEditingController(text: mtg.title);
    final cCtrl = TextEditingController(text: mtg.clientOrCompany);
    final lCtrl = TextEditingController(text: mtg.location);
    final linkCtrl =
        TextEditingController(text: mtg.onlineMeetingLink ?? '');
    final nCtrl = TextEditingController(text: mtg.notes);
    DateTime pickedDate = _dateOnly(mtg.startTime);
    TimeOfDay pickedStart = TimeOfDay.fromDateTime(mtg.startTime);
    var durationMinutes =
        mtg.endTime.difference(mtg.startTime).inMinutes.clamp(15, 480);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final startPreview = _combineDateAndTime(pickedDate, pickedStart);
          final endPreview =
              startPreview.add(Duration(minutes: durationMinutes));
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Meeting',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tCtrl,
                    decoration: const InputDecoration(labelText: 'Title *'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.calendar_today_rounded,
                              size: 16),
                          label: Text(BhFormatters.dayMonth(pickedDate)),
                          onPressed: () async {
                            final res = await showDatePicker(
                              context: ctx,
                              initialDate: pickedDate,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 90)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365)),
                            );
                            if (res != null) {
                              setModalState(() => pickedDate = _dateOnly(res));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.access_time_rounded, size: 16),
                          label: Text(BhFormatters.time12h(startPreview)),
                          onPressed: () async {
                            final res = await showTimePicker(
                              context: ctx,
                              initialTime: pickedStart,
                            );
                            if (res != null) {
                              setModalState(() => pickedStart = res);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '⏰ ${BhFormatters.time12h(startPreview)} – ${BhFormatters.time12h(endPreview)} • Alarm triggers 10m before',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.electricBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: cCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Client / Topic'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: linkCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Meeting Link'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nCtrl,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                          ),
                          onPressed: () {
                            ref
                                .read(agencyStoreProvider.notifier)
                                .deleteMeeting(mtg.id);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Cancel Mtg'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            if (tCtrl.text.trim().isEmpty) return;
                            final newStart =
                                _combineDateAndTime(pickedDate, pickedStart);
                            final newEnd = newStart
                                .add(Duration(minutes: durationMinutes));
                            ref
                                .read(agencyStoreProvider.notifier)
                                .updateMeeting(
                                  meetingId: mtg.id,
                                  title: tCtrl.text.trim(),
                                  clientOrCompany: cCtrl.text.trim(),
                                  meetingType: mtg.meetingType,
                                  location: lCtrl.text.trim(),
                                  onlineLink: linkCtrl.text.trim(),
                                  startTime: newStart,
                                  endTime: newEnd,
                                  notes: nCtrl.text.trim(),
                                );
                            setState(() => _selectedDate = pickedDate);
                            Navigator.pop(ctx);
                          },
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final textTheme = Theme.of(context).textTheme;
    final today = _dateOnly(DateTime.now());

    final filteredMeetings = state.meetings.where((m) {
      if (!_isSameDay(m.startTime, _selectedDate)) {
        return false;
      }
      if (_selectedTypeFilter != 'All' &&
          m.meetingType != _selectedTypeFilter) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final canPop = GoRouter.maybeOf(context)?.canPop() ?? true;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BhSmartBackButton(),
          title: const Text('Meetings & Studio Calendar'),
          actions: [
          IconButton(
            tooltip: 'Toggle Month / Week View',
            onPressed: () => setState(() => _showMonthGrid = !_showMonthGrid),
            icon: Icon(
              _showMonthGrid
                  ? Icons.view_week_rounded
                  : Icons.calendar_view_month_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showScheduleMeetingModal,
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.video_call_rounded),
        label: const Text(
          'Schedule Meeting',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          // Interactive Date Strip OR Month Calendar Picker
          if (_showMonthGrid)
            BhSurfaceCard(
              padding: const EdgeInsets.all(8),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: today.subtract(const Duration(days: 90)),
                lastDate: today.add(const Duration(days: 180)),
                onDateChanged: (picked) {
                  setState(() {
                    _selectedDate = _dateOnly(picked);
                  });
                },
              ),
            )
          else
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = today.add(Duration(days: index));
                  final selected = _isSameDay(date, _selectedDate);
                  final dayCount = state.meetings
                      .where((m) => _isSameDay(m.startTime, date))
                      .length;
                  const weekdays = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return InkWell(
                    key: ValueKey('calendar_day_${date.year}_${date.month}_${date.day}'),
                    onTap: () => setState(() => _selectedDate = _dateOnly(date)),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: selected ? AppColors.brandGradient : null,
                        color: selected
                            ? null
                            : (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkSurface
                                : Colors.white),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? AppColors.electricBlue
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekdays[date.weekday - 1],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white70
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: selected ? Colors.white : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (dayCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.22)
                                    : AppColors.electricBlue
                                        .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$dayCount mtg',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.electricBlue,
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 14),

          // Meeting Type Filter Chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', ...MeetingRecord.meetingTypes].map((type) {
                final selected = _selectedTypeFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedTypeFilter = type),
                    selectedColor: AppColors.electricBlue,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          BhSectionHeader(
            kicker: 'STUDIO CALENDAR',
            title: 'Meetings • ${BhFormatters.dayMonth(_selectedDate)}',
            countBadge: filteredMeetings.length,
          ),
          const SizedBox(height: 10),

          if (filteredMeetings.isEmpty)
            BhArtisticEmptyState(
              icon: Icons.event_available_rounded,
              title: 'No meetings on ${BhFormatters.dayMonth(_selectedDate)}',
              subtitle:
                  'Tap Schedule Meeting to pick a date & time. A 10-minute pre-meeting alarm is set automatically.',
              actionLabel: '+ Schedule Meeting',
              onAction: _showScheduleMeetingModal,
            )
          else
            ...filteredMeetings.map(
            (mtg) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BhSurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BhStatusPill(
                          label: mtg.meetingType,
                          color: AppColors.indigo,
                          icon: Icons.event_note_rounded,
                        ),
                        Text(
                          '${BhFormatters.dayMonth(mtg.startTime)} • ${BhFormatters.time12h(mtg.startTime)} – ${BhFormatters.time12h(mtg.endTime)}',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.electricBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(mtg.title, style: textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${mtg.clientOrCompany} • ${mtg.location}',
                      style: textTheme.bodySmall,
                    ),
                    if (mtg.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(mtg.description, style: textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: mtg.reminders
                          .map(
                            (r) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.electricBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '🔔 $r',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.electricBlue,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: mtg.participants
                              .take(4)
                              .map(
                                (p) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: BhAvatar(name: p, size: 28),
                                ),
                              )
                              .toList(),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _showEditMeetingModal(mtg),
                              child: const Text('Edit'),
                            ),
                            if (mtg.hasOnlineLink)
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Launching ${mtg.onlineMeetingLink}...',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.videocam_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Join Meeting',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

