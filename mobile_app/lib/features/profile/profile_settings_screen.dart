import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/services/server_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';
import '../dashboard/ai_and_search_sheets.dart';

class ProfileAndSettingsScreen extends ConsumerWidget {
  const ProfileAndSettingsScreen({super.key});

  void _showEmployeeDirectoryModal(BuildContext context, List<AppUser> employees) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.5,
          maxChildSize: 0.94,
          expand: false,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Studio Founders & Leadership Directory',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${employees.length} Founders • Guwahati & New Delhi, India',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                ...employees.map(
                  (emp) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: BhSurfaceCard(
                      child: Row(
                        children: [
                          BhAvatar(
                            name: emp.name,
                            size: 44,
                            isOnline: emp.isOnline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${emp.name} (${emp.employeeCode})',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '${emp.designation} • ${emp.department}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${emp.assignedProjectsCount} Projects • ${emp.activeTasksCount} Active Tasks • ${emp.performanceScore}% Score',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.electricBlue,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          BhStatusPill(
                            label: emp.accessBadgeLabel,
                            color: emp.isSuperAdmin
                                ? AppColors.electricBlue
                                : AppColors.indigo,
                            icon: emp.isSuperAdmin
                                ? Icons.shield_rounded
                                : null,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeviceSessionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Sanctum Device Sessions',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.phone_android_rounded,
                  color: AppColors.successSoft,
                ),
                title: Text('Infinix NOTE 50S 5G (This Device)'),
                subtitle: Text('Android 16 • FCM Token Active • Guwahati, IN'),
                trailing: BhStatusPill(
                  label: 'Current',
                  color: AppColors.successSoft,
                  compact: true,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Revoked secondary device tokens via Laravel Sanctum.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, size: 17),
                  label: const Text('Revoke Other Device Sessions'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agencyStoreProvider);
    final notifier = ref.read(agencyStoreProvider.notifier);
    final user = state.currentUser;
    final textTheme = Theme.of(context).textTheme;
    final isDark = state.themeMode == ThemeMode.dark;

    final moreModules = [
      (
        'Clients',
        '${state.clients.length} Accounts',
        Icons.domain_rounded,
        AppColors.cyanAccent,
        () => context.push('/clients'),
      ),
      (
        'Tasks',
        '${state.tasks.length} Active',
        Icons.task_alt_rounded,
        AppColors.electricBlue,
        () => context.push('/tasks'),
      ),
      (
        'Calendar',
        '${state.meetings.length} Meetings',
        Icons.calendar_month_rounded,
        AppColors.indigo,
        () => context.push('/calendar'),
      ),
      (
        'Finance & GST',
        'INR Invoices',
        Icons.currency_rupee_rounded,
        AppColors.successSoft,
        () => context.push('/finance'),
      ),
      (
        'Notifications',
        '${state.unreadNotificationCount} Unread',
        Icons.notifications_active_rounded,
        AppColors.warning,
        () => context.push('/notifications'),
      ),
      (
        'Studio Team',
        '${state.employees.length} Members',
        Icons.groups_rounded,
        AppColors.violetAccent,
        () => _showEmployeeDirectoryModal(context, state.employees),
      ),
      (
        'Blue Hour AI',
        'Ask Assistant',
        Icons.auto_awesome_rounded,
        AppColors.electricBlue,
        () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AiBusinessAssistantSheet(),
          );
        },
      ),
      (
        'Global Search',
        'All Modules',
        Icons.manage_search_rounded,
        AppColors.cyanAccent,
        () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const GlobalSearchSheet(),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const BhBrandLogo(
              size: 32,
              borderRadius: 9,
              useLightTile: false,
            ),
            const SizedBox(width: 10),
            const BhWordmark(
              fontSize: 15,
              subSize: 7.5,
              center: false,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Dark / Light Theme',
            onPressed: notifier.toggleThemeMode,
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: BhAmbientCanvas(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
          // Executive User Profile Card
          BhSurfaceCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                BhAvatar(
                  name: user.name,
                  size: 60,
                  isOnline: true,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              style: textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(width: 8),
                          BhStatusPill(
                            label: user.accessBadgeLabel,
                            color: user.isSuperAdmin
                                ? AppColors.electricBlue
                                : AppColors.indigo,
                            icon: user.isSuperAdmin
                                ? Icons.shield_rounded
                                : null,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${user.designation} • ${user.employeeCode}',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.electricBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // More Modules Hub Grid (Section 4)
          const BhSectionHeader(
            title: 'All Studio Modules',
            subtitle: 'Quick navigation across Blue Hour HQ',
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: moreModules.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.25,
            ),
            itemBuilder: (context, index) {
              final m = moreModules[index];
              return BhSurfaceCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                onTap: m.$5,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: m.$4.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(m.$3, color: m.$4, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.$1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall,
                          ),
                          Text(
                            m.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          // Super Admin Governance & RBAC Simulator (Strictly Himon Bhuyan Only)
          BhSectionHeader(
            title: user.isSuperAdmin
                ? 'Super Admin Command & RBAC Governance'
                : 'Access Tier & Governance',
            subtitle: user.isSuperAdmin
                ? 'Exclusive Super Admin controls for Himon Bhuyan'
                : 'Super Admin privileges reserved exclusively for Himon Bhuyan',
          ),
          const SizedBox(height: 10),
          if (user.isSuperAdmin)
            BhSurfaceCard(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    key: ValueKey(user.id),
                    initialValue: user.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Super Admin: Inspect Founder Account',
                      prefixIcon: Icon(Icons.shield_rounded),
                    ),
                    items: state.employees
                        .map(
                          (f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(
                              '${f.name} (${f.accessBadgeLabel}) — ${f.designation}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (founderId) {
                      if (founderId != null) {
                        notifier.switchActiveFounder(founderId);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    key: ValueKey('${user.id}-${user.role}'),
                    initialValue: user.role,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Super Admin: RBAC Permission Simulator',
                      prefixIcon: Icon(Icons.admin_panel_settings_rounded),
                    ),
                    items: UserRole.values
                        .map(
                          (r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              '${r.label} — ${r.subtitle}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (nextRole) {
                      if (nextRole != null) {
                        notifier.switchActiveRole(nextRole);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.cloud_done_rounded,
                      color: AppColors.electricBlue,
                    ),
                    title: const Text('Live Cloud Server URL (Railway)'),
                    subtitle: Text(
                      BhServerConfig.instance.liveBaseUrl ??
                          'Local Studio Wi-Fi (192.168.29.26:8090)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final urlCtrl = TextEditingController(
                          text: BhServerConfig.instance.liveBaseUrl ?? '',
                        );
                        String? statusMsg;
                        bool? statusOk;
                        bool testing = false;
                        await showDialog<void>(
                          context: context,
                          builder: (ctx) => StatefulBuilder(
                            builder: (ctx, setD) => AlertDialog(
                              title: const Text('Cloud API Server (Railway)'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Paste your Railway *.up.railway.app URL. It syncs to all 3 Founders automatically via Firestore.',
                                    style: TextStyle(fontSize: 12.5),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: urlCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'HTTPS Base URL',
                                      hintText:
                                          'https://blue-hour-api.up.railway.app',
                                    ),
                                  ),
                                  if (statusMsg != null) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      statusMsg!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: statusOk == true
                                            ? AppColors.successSoft
                                            : AppColors.error,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: testing
                                      ? null
                                      : () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                                FilledButton(
                                  onPressed: testing
                                      ? null
                                      : () async {
                                          setD(() => testing = true);
                                          final res = await notifier
                                              .saveAndTestLiveServerUrl(
                                            urlCtrl.text,
                                          );
                                          if (ctx.mounted) {
                                            setD(() {
                                              testing = false;
                                              statusOk = res.ok;
                                              statusMsg = res.message;
                                            });
                                          }
                                        },
                                  child: Text(
                                    testing ? 'Testing...' : 'Save & Test',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (context.mounted && statusMsg != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(statusMsg!)),
                          );
                        }
                      },
                      child: const Text('Configure'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.45),
                        ),
                      ),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Clear all studio data?'),
                            content: const Text(
                              'This removes all leads, clients, projects, tasks, meetings, invoices, notifications, and chat messages across Firestore, MySQL, and this device.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Clear All Data'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          notifier.resetWorkspaceToClean();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Workspace cleared across Firestore, MySQL & device.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.cleaning_services_rounded, size: 17),
                      label: const Text(
                        'Wipe All Demo / Test Data',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            BhSurfaceCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      color: AppColors.warning,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Super Admin Controls Locked',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'You are signed in as ${user.name} (${user.accessBadgeLabel}). Only Himon Bhuyan holds Super Admin governance privileges.',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 22),

          // Appearance, Automation & Security Settings
          const BhSectionHeader(
            title: 'Preferences, Automation & Security',
          ),
          const SizedBox(height: 10),
          BhSurfaceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.dark_mode_rounded,
                    color: AppColors.electricBlue,
                  ),
                  title: const Text('Signature Dark Mode'),
                  subtitle: const Text(
                    'Deep Navy (#0B1020) & Electric Blue (#3B82F6)',
                  ),
                  value: isDark,
                  onChanged: (_) => notifier.toggleThemeMode(),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.wb_sunny_rounded,
                    color: AppColors.warning,
                  ),
                  title: const Text('Automated Daily Founder Briefing'),
                  subtitle: Text(
                    'Scheduled push summary at ${user.briefingTime} IST',
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 8, minute: 30),
                      );
                      if (picked != null && context.mounted) {
                        notifier.updateBriefingTime(picked.format(context));
                      }
                    },
                    child: const Text('Configure'),
                  ),
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.cloud_sync_rounded,
                    color: AppColors.cyanAccent,
                  ),
                  title: const Text('Simulate Offline Mode (Drift Cache)'),
                  subtitle: const Text(
                    'Test offline banner, local persistence & conflict queue',
                  ),
                  value: state.isOfflineMode,
                  onChanged: (_) => notifier.toggleOfflineSimulation(),
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.fingerprint_rounded,
                    color: AppColors.electricBlue,
                  ),
                  title: const Text('Biometric App Lock'),
                  subtitle: const Text(
                    'Require Fingerprint / Face ID when opening or resuming',
                  ),
                  value: state.biometricLockEnabled,
                  onChanged: (nextVal) async {
                    final ok =
                        await BhBiometricAuthService.instance.authenticate(
                      reason: nextVal
                          ? 'Confirm biometrics to lock Blue Hour HQ'
                          : 'Confirm biometrics to disable App Lock',
                    );
                    if (!context.mounted) return;
                    if (ok) {
                      notifier.toggleBiometricLock(nextVal);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            nextVal
                                ? 'Biometric App Lock enabled.'
                                : 'Biometric App Lock disabled.',
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Biometric verification cancelled.'),
                        ),
                      );
                    }
                  },
                ),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(
                    Icons.security_rounded,
                    color: AppColors.successSoft,
                  ),
                  title: const Text('Two-Factor Authentication (2FA)'),
                  subtitle: const Text('TOTP + Sanctum device token binding'),
                  value: user.twoFactorEnabled,
                  onChanged: notifier.toggleTwoFactor,
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.devices_rounded,
                    color: AppColors.indigo,
                  ),
                  title: const Text('Device & Session Management'),
                  subtitle: const Text('1 active device (Android 16)'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                  ),
                  onTap: () => _showDeviceSessionsModal(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () {
              notifier.logout();
              context.go('/login');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text(
              'Sign Out of Blue Hour HQ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

