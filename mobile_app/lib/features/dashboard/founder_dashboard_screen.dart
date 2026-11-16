import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/repositories/agency_store.dart';
import 'ai_and_search_sheets.dart';

class FounderDashboardScreen extends ConsumerStatefulWidget {
  const FounderDashboardScreen({super.key});

  @override
  ConsumerState<FounderDashboardScreen> createState() =>
      _FounderDashboardScreenState();
}

class _FounderDashboardScreenState
    extends ConsumerState<FounderDashboardScreen> {
  bool _showAllKpis = false;

  static const _dateFilters = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'Custom',
  ];

  void _openAiAssistant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AiBusinessAssistantSheet(),
    );
  }

  void _openGlobalSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const GlobalSearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final notifier = ref.read(agencyStoreProvider.notifier);
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeProjectsCount =
        state.projects.where((p) => p.status != 'Completed').length;
    final completedProjectsCount =
        state.projects.where((p) => p.status == 'Completed').length;
    final pendingTasksCount =
        state.tasks.where((t) => t.status != 'Completed').length;
    final pendingFollowupsCount =
        state.followups.where((f) => !f.isCompleted).length;

    final allKpis = [
      (
        'Monthly Revenue',
        BhFormatters.inrCompact(state.monthlyRevenueInr),
        BhFormatters.inr(state.monthlyRevenueInr),
        Icons.currency_rupee_rounded,
        AppColors.successSoft,
        state.invoices.isEmpty ? 'Live' : '${state.invoices.length} Invoices',
        true,
        () => context.push('/finance'),
      ),
      (
        'Outstanding Dues',
        BhFormatters.inrCompact(state.outstandingPaymentsInr),
        '${state.invoices.where((i) => i.balanceDueInr > 0).length} open invoices',
        Icons.account_balance_wallet_outlined,
        AppColors.warning,
        state.outstandingPaymentsInr == 0 ? 'Clear' : 'Pending',
        state.outstandingPaymentsInr == 0,
        () => context.push('/finance'),
      ),
      (
        'Total Leads',
        '${state.leads.length}',
        '${state.newLeadsCount} new inbound',
        Icons.leaderboard_rounded,
        AppColors.electricBlue,
        'CRM',
        true,
        () => context.go('/leads'),
      ),
      (
        'Conversion Rate',
        '${state.conversionRatePercent.toStringAsFixed(1)}%',
        '${state.convertedLeadsCount} converted deals',
        Icons.auto_graph_rounded,
        AppColors.indigo,
        'Funnel',
        true,
        () => context.go('/leads'),
      ),
      (
        'Active Clients',
        '${state.clients.length}',
        'Retainer & Enterprise',
        Icons.domain_rounded,
        AppColors.cyanAccent,
        'Portfolio',
        true,
        () => context.push('/clients'),
      ),
      (
        'Active Projects',
        '$activeProjectsCount',
        '$completedProjectsCount completed',
        Icons.rocket_launch_rounded,
        AppColors.violetAccent,
        'Sprints',
        true,
        () => context.go('/projects'),
      ),
      (
        'Pending Follow-ups',
        '$pendingFollowupsCount',
        'Scheduled CRM touchpoints',
        Icons.phone_callback_rounded,
        const Color(0xFFF97316),
        'Reminders',
        true,
        () => context.go('/leads'),
      ),
      (
        'Upcoming Meetings',
        '${state.meetings.length}',
        'Client & founder syncs',
        Icons.video_camera_front_rounded,
        AppColors.electricBlue,
        'Calendar',
        true,
        () => context.push('/calendar'),
      ),
      (
        'New Leads',
        '${state.newLeadsCount}',
        'Awaiting first contact',
        Icons.fiber_new_rounded,
        AppColors.electricBlue,
        'Inbound',
        true,
        () => context.go('/leads'),
      ),
      (
        'Converted Leads',
        '${state.convertedLeadsCount}',
        'Won & onboarded',
        Icons.verified_rounded,
        AppColors.success,
        'Won',
        true,
        () => context.go('/leads'),
      ),
      (
        'Completed Projects',
        '$completedProjectsCount',
        'Delivered & signed off',
        Icons.check_circle_outline_rounded,
        AppColors.successSoft,
        'Shipped',
        true,
        () => context.go('/projects'),
      ),
      (
        'Pending Tasks',
        '$pendingTasksCount',
        '${state.tasks.where((t) => t.isOverdue).length} overdue',
        Icons.task_alt_rounded,
        AppColors.electricBlue,
        'Tasks',
        true,
        () => context.push('/tasks'),
      ),
    ];

    final visibleKpis = _showAllKpis ? allKpis : allKpis.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const BhBrandLogo(size: 38),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BhWordmark(fontSize: 16.5, subtitle: null),
                  Text(
                    '${state.currentUser.name} • ${state.currentUser.designation}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Global Search',
            onPressed: _openGlobalSearch,
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Calendar & Meetings',
            onPressed: () => context.push('/calendar'),
            icon: const Icon(Icons.calendar_month_rounded),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Notification Centre',
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              if (state.unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${state.unreadNotificationCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAiAssistant,
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome_rounded, size: 20),
        label: const Text(
          'Blue Hour AI',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BhAmbientCanvas(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              // Artistic Founder Command Hero Card
              BhFadeSlideIn(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.executiveHeroGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.electricBlue.withValues(alpha: 0.38),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricBlue.withValues(alpha: 0.2),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.successSoft,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${state.currentUser.accessBadgeLabel} • BRIEFING ${state.currentUser.briefingTime}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const BhBrandLogo(size: 34, showGlow: false),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Welcome, ${state.currentUser.name.split(' ').first}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${state.leads.length} pipeline leads • $activeProjectsCount active projects • ${state.meetings.length} scheduled meetings • ${BhFormatters.inr(state.monthlyRevenueInr)} collected.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickHeaderActionChip(
                              icon: Icons.person_add_alt_1_rounded,
                              label: 'Leads CRM',
                              onTap: () => context.go('/leads'),
                            ),
                            const SizedBox(width: 8),
                            _QuickHeaderActionChip(
                              icon: Icons.video_call_rounded,
                              label: 'Meetings',
                              onTap: () => context.push('/calendar'),
                            ),
                            const SizedBox(width: 8),
                            _QuickHeaderActionChip(
                              icon: Icons.receipt_long_rounded,
                              label: 'Finance & GST',
                              onTap: () => context.push('/finance'),
                            ),
                            const SizedBox(width: 8),
                            _QuickHeaderActionChip(
                              icon: Icons.business_center_rounded,
                              label: 'Clients',
                              onTap: () => context.push('/clients'),
                            ),
                            const SizedBox(width: 8),
                            _QuickHeaderActionChip(
                              icon: Icons.checklist_rounded,
                              label: 'Tasks',
                              onTap: () => context.push('/tasks'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date Filter Strip
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _dateFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final label = _dateFilters[index];
                    final selected = state.selectedDashboardRange == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      onSelected: (_) async {
                        if (label == 'Custom') {
                          await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2027),
                          );
                        }
                        notifier.setDashboardRange(label);
                      },
                      selectedColor: AppColors.electricBlue,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // 12 KPI Cards Grid
              BhSectionHeader(
                kicker: '01 // LIVE METRICS',
                title: 'Executive Telemetry (${state.selectedDashboardRange})',
                actionLabel:
                    _showAllKpis ? 'Compact View (6)' : 'Expand All 12',
                onAction: () => setState(() => _showAllKpis = !_showAllKpis),
              ),
              const SizedBox(height: 10),
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutQuart,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleKpis.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.28,
                  ),
                  itemBuilder: (context, index) {
                    final item = visibleKpis[index];
                    return BhFadeSlideIn(
                      delayMs: index * 35,
                      child: BhKpiCard(
                        title: item.$1,
                        value: item.$2,
                        subtitle: item.$3,
                        icon: item.$4,
                        accentColor: item.$5,
                        trendText: item.$6,
                        isPositiveTrend: item.$7,
                        onTap: item.$8,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // Live Revenue Analytics Chart
              const BhSectionHeader(
                kicker: '02 // FINANCIAL ANALYTICS',
                title: 'Revenue Trajectory (INR)',
                subtitle: 'Real-time ledger computed from studio invoices',
              ),
              const SizedBox(height: 10),
              BhSurfaceCard(
                padding: const EdgeInsets.fromLTRB(16, 18, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              BhFormatters.inr(state.monthlyRevenueInr),
                              style: textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.electricBlue,
                              ),
                            ),
                            Text(
                              state.invoices.isEmpty
                                  ? 'No invoices recorded yet — add invoices in Finance'
                                  : '${state.invoices.length} invoice(s) tracked in ledger',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const BhStatusPill(
                          label: 'INR (₹)',
                          color: AppColors.electricBlue,
                          icon: Icons.insights_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (val) => FlLine(
                              color: (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder)
                                  .withValues(alpha: 0.5),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: const FlTitlesData(
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: 5,
                          minY: 0,
                          maxY: (state.monthlyRevenueInr > 0
                              ? state.monthlyRevenueInr * 1.25
                              : 100),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: AppColors.electricBlue,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.electricBlue
                                        .withValues(alpha: 0.30),
                                    AppColors.electricBlue
                                        .withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                              spots: [
                                const FlSpot(0, 0),
                                const FlSpot(1, 0),
                                const FlSpot(2, 0),
                                const FlSpot(3, 0),
                                FlSpot(4, state.monthlyRevenueInr * 0.5),
                                FlSpot(5, state.monthlyRevenueInr),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Today's Schedule & Meetings
              BhSectionHeader(
                kicker: '03 // CALENDAR',
                title: 'Scheduled Meetings',
                countBadge: state.meetings.length,
                actionLabel: 'Schedule',
                onAction: () => context.push('/calendar'),
              ),
              const SizedBox(height: 10),
              if (state.meetings.isEmpty)
                BhArtisticEmptyState(
                  kicker: 'STUDIO CALENDAR',
                  title: 'No Meetings Scheduled Yet',
                  description:
                      'Schedule client demos, sales calls, or founder syncs with automatic FCM reminders.',
                  icon: Icons.video_camera_front_rounded,
                  actionLabel: 'Schedule Meeting',
                  onAction: () => context.push('/calendar'),
                )
              else
                ...state.meetings.take(3).map(
                      (mtg) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BhSurfaceCard(
                          onTap: () => context.push('/calendar'),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.indigo.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.videocam_rounded,
                                  color: AppColors.indigo,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(mtg.title, style: textTheme.titleMedium),
                                    Text(
                                      '${mtg.clientOrCompany} • ${BhFormatters.time12h(mtg.startTime)}',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              BhStatusPill(
                                label: mtg.meetingType,
                                color: AppColors.electricBlue,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 22),

              // The 3 Founders Leadership Section
              const BhSectionHeader(
                kicker: '04 // STUDIO LEADERSHIP',
                title: 'The 3 Founders — Blue Hour Studios',
                subtitle:
                    'Software & AI • Client Growth & Social • Hardware & IoT',
              ),
              const SizedBox(height: 10),
              BhSurfaceCard(
                child: Column(
                  children: state.employees.map((emp) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          BhAvatar(
                            name: emp.name,
                            size: 42,
                            isOnline: emp.isOnline,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(emp.name, style: textTheme.titleMedium),
                                Text(
                                  emp.designation,
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          BhStatusPill(
                            label: emp.accessBadgeLabel,
                            color: emp.isSuperAdmin
                                ? AppColors.electricBlue
                                : (emp.id == 'emp-02'
                                    ? AppColors.indigo
                                    : AppColors.cyanAccent),
                            icon: emp.isSuperAdmin
                                ? Icons.shield_rounded
                                : null,
                            compact: true,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickHeaderActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickHeaderActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
