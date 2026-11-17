import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

class NotificationCentreScreen extends ConsumerStatefulWidget {
  const NotificationCentreScreen({super.key});

  @override
  ConsumerState<NotificationCentreScreen> createState() =>
      _NotificationCentreScreenState();
}

class _NotificationCentreScreenState
    extends ConsumerState<NotificationCentreScreen> {
  String _selectedCategory = 'All';
  bool _markReadQueued = false;

  @override
  void initState() {
    super.initState();
    _queueMarkAllRead();
  }

  void _queueMarkAllRead() {
    if (_markReadQueued) return;
    _markReadQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markReadQueued = false;
      if (!mounted) return;
      ref.read(agencyStoreProvider.notifier).markAllNotificationsRead();
    });
  }

  void _showNotificationPreferencesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final prefs = ref.watch(agencyStoreProvider).notificationPrefs;
            final notifier = ref.read(agencyStoreProvider.notifier);

            return DraggableScrollableSheet(
              initialChildSize: 0.78,
              minChildSize: 0.55,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FCM & APNs Preferences',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    Text(
                      'Configure Android Notification Channels, iOS APNs alerts, and Quiet Hours.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Lead Follow-up Reminders'),
                      subtitle: const Text('1 day, 1 hour, 15m before & overdue'),
                      value: prefs.leadReminders,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(leadReminders: v),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Client & Internal Meeting Reminders'),
                      subtitle: const Text('Includes one-tap Join Meeting action'),
                      value: prefs.meetingReminders,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(meetingReminders: v),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Task Assignments & Deadlines'),
                      subtitle: const Text('New tasks, review requests & overdue'),
                      value: prefs.taskReminders,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(taskReminders: v),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Project Milestone Updates'),
                      value: prefs.projectNotifications,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(projectNotifications: v),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Real-Time Chat & Mentions'),
                      subtitle: const Text('Suppressed when viewing active room'),
                      value: prefs.chatNotifications,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(chatNotifications: v),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Finance & GST Payment Alerts'),
                      subtitle: const Text('Restricted to authorised roles'),
                      value: prefs.paymentNotifications,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(paymentNotifications: v),
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Automated Daily Founder Briefing'),
                      subtitle: const Text('Morning executive summary push'),
                      value: prefs.dailyFounderBriefing,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(dailyFounderBriefing: v),
                      ),
                    ),
                    const Divider(height: 24),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Quiet Hours (Do Not Disturb)'),
                      subtitle: Text(
                        '${prefs.quietHoursStart} – ${prefs.quietHoursEnd} (Admin critical alerts bypass)',
                      ),
                      value: prefs.quietHoursEnabled,
                      onChanged: (v) => notifier.updateNotificationPreferences(
                        prefs.copyWith(quietHoursEnabled: v),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          notifier.triggerTestPushNotification();
                        },
                        icon: const Icon(Icons.notifications_active_rounded,
                            size: 18),
                        label: const Text('Send Test OS Notification Banner'),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Leads':
        return Icons.phone_callback_rounded;
      case 'Meetings':
        return Icons.video_camera_front_rounded;
      case 'Tasks':
        return Icons.task_alt_rounded;
      case 'Projects':
        return Icons.rocket_launch_rounded;
      case 'Messages':
        return Icons.forum_rounded;
      case 'Payments':
        return Icons.currency_rupee_rounded;
      case 'Announcements':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Leads':
        return AppColors.electricBlue;
      case 'Meetings':
        return AppColors.indigo;
      case 'Tasks':
        return AppColors.error;
      case 'Projects':
        return AppColors.violetAccent;
      case 'Messages':
        return AppColors.cyanAccent;
      case 'Payments':
        return AppColors.successSoft;
      case 'Announcements':
        return AppColors.warning;
      default:
        return AppColors.electricBlue;
    }
  }

  Widget _buildSwipeBackground(Alignment alignment) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 6),
            const Text(
              'Remove',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ] else ...[
            const Text(
              'Remove',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(AgencyStoreNotifier notifier) async {
    final scopeLabel = _selectedCategory == 'All'
        ? 'all notifications'
        : 'all $_selectedCategory notifications';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear notifications?'),
        content: Text('Remove $scopeLabel from your Notification Centre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      notifier.clearNotifications(category: _selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final notifier = ref.read(agencyStoreProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    if (state.unreadNotificationCount > 0) {
      _queueMarkAllRead();
    }

    final filtered = state.notifications.where((n) {
      if (_selectedCategory == 'All') return true;
      return n.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const BhSmartBackButton(),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${state.unreadNotificationCount} unread alerts',
              style: textTheme.labelSmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Send Test Push Notification',
            onPressed: notifier.triggerTestPushNotification,
            icon: const Icon(Icons.notification_add_outlined),
          ),
          if (state.unreadNotificationCount > 0)
            IconButton(
              tooltip: 'Mark all read',
              onPressed: notifier.markAllNotificationsRead,
              icon: const Icon(Icons.done_all_rounded),
            ),
          IconButton(
            tooltip: 'Notification Preferences',
            onPressed: _showNotificationPreferencesSheet,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Strip
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: AppNotification.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = AppNotification.categories[index];
                final selected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.electricBlue,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : null,
                  ),
                );
              },
            ),
          ),
          if (filtered.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${filtered.length} alert${filtered.length == 1 ? '' : 's'} • Swipe any card to remove',
                      style: textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmClearAll(notifier),
                    icon: const Icon(
                      Icons.clear_all_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    label: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 8),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: BhArtisticEmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: 'Zero unread studio alerts',
                        subtitle:
                            'Real-time FCM & APNs alerts for leads, meetings, tasks, and invoices will appear here.',
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                final item = filtered[index];
                final color = _categoryColor(item.category);

                return Dismissible(
                  key: ValueKey('notif_${item.id}'),
                  direction: DismissDirection.horizontal,
                  background: _buildSwipeBackground(Alignment.centerLeft),
                  secondaryBackground:
                      _buildSwipeBackground(Alignment.centerRight),
                  onDismissed: (_) {
                    final originalIndex = state.notifications
                        .indexWhere((n) => n.id == item.id);
                    notifier.removeNotification(item.id);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                          content: Text('Removed "${item.title}"'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              notifier.restoreNotification(
                                item,
                                index: originalIndex < 0 ? 0 : originalIndex,
                              );
                            },
                          ),
                        ),
                      );
                  },
                  child: BhSurfaceCard(
                    borderColor: item.isRead
                        ? null
                        : AppColors.electricBlue.withValues(alpha: 0.55),
                    onTap: () {
                      notifier.markNotificationRead(item.id);
                      if (item.targetRoute != null) {
                        context.push(item.targetRoute!);
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _categoryIcon(item.category),
                                color: color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      BhStatusPill(
                                        label: item.category,
                                        color: color,
                                        compact: true,
                                      ),
                                      Text(
                                        BhFormatters.relativeTime(item.timestamp),
                                        style: textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.title,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: item.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body,
                                    style: textTheme.bodySmall?.copyWith(
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (item.actions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: item.actions.map((act) {
                              return OutlinedButton(
                                onPressed: () {
                                  notifier.markNotificationRead(item.id);
                                  if (item.targetRoute != null) {
                                    context.push(item.targetRoute!);
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  side: BorderSide(
                                    color: color.withValues(alpha: 0.45),
                                  ),
                                ),
                                child: Text(
                                  act,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

