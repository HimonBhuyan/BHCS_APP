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
  int _selectedDayOffset = 0; // 0 = Today
  String _selectedTypeFilter = 'All';
  bool _showMonthGrid = false;

  void _showScheduleMeetingModal() {
    final titleCtrl = TextEditingController();
    final clientCtrl = TextEditingController();
    final linkCtrl = TextEditingController(
      text: 'https://meet.google.com/',
    );
    final locationCtrl = TextEditingController(text: 'Google Meet');
    final notesCtrl = TextEditingController();
    String selectedType = MeetingRecord.meetingTypes.first;
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
            return DraggableScrollableSheet(
              initialChildSize: 0.86,
              minChildSize: 0.6,
              maxChildSize: 0.94,
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
                        'Automatic FCM reminders (1d, 1h, 15m, 0m) will be dispatched to all participants.',
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
                            final baseDay = DateTime.now()
                                .add(Duration(days: _selectedDayOffset));
                            final start = DateTime(
                              baseDay.year,
                              baseDay.month,
                              baseDay.day,
                              16,
                              30,
                            );
                            ref
                                .read(agencyStoreProvider.notifier)
                                .scheduleMeeting(
                                  title: titleCtrl.text.trim(),
                                  clientOrCompany: clientCtrl.text.trim(),
                                  meetingType: selectedType,
                                  startTime: start,
                                  endTime: start.add(const Duration(hours: 1)),
                                  location: locationCtrl.text.trim(),
                                  onlineLink: linkCtrl.text.trim().isEmpty
                                      ? null
                                      : linkCtrl.text.trim(),
                                  participants: selectedParticipants.toList(),
                                  notes: notesCtrl.text.trim(),
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Meeting "${titleCtrl.text.trim()}" scheduled with ${selectedParticipants.length} participants.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.event_available_rounded),
                          label: const Text('Schedule & Send FCM Invites'),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final textTheme = Theme.of(context).textTheme;
    final today = DateTime.now();

    final filteredMeetings = state.meetings.where((m) {
      if (_selectedTypeFilter != 'All' &&
          m.meetingType != _selectedTypeFilter) {
        return false;
      }
      return true;
    }).toList();

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
                initialDate: today.add(Duration(days: _selectedDayOffset)),
                firstDate: today.subtract(const Duration(days: 90)),
                lastDate: today.add(const Duration(days: 180)),
                onDateChanged: (picked) {
                  setState(() {
                    _selectedDayOffset = picked.difference(today).inDays;
                  });
                },
              ),
            )
          else
            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = today.add(Duration(days: index));
                  final selected = _selectedDayOffset == index;
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
                    onTap: () => setState(() => _selectedDayOffset = index),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 62,
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
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: selected ? Colors.white : null,
                            ),
                          ),
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
            title: 'Scheduled Meetings',
            countBadge: filteredMeetings.length,
          ),
          const SizedBox(height: 10),

          if (filteredMeetings.isEmpty)
            BhArtisticEmptyState(
              icon: Icons.event_available_rounded,
              title: 'No meetings scheduled yet',
              subtitle:
                  'Schedule client discovery calls, architecture reviews, or Founder syncs with automatic FCM reminders.',
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
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Reschedule notification sent to ${mtg.participants.length} participants.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Reschedule'),
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

