import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/repositories/agency_store.dart';

/// Interactive AI Business Assistant modal bottom sheet (Section 20).
class AiBusinessAssistantSheet extends ConsumerStatefulWidget {
  const AiBusinessAssistantSheet({super.key});

  @override
  ConsumerState<AiBusinessAssistantSheet> createState() =>
      _AiBusinessAssistantSheetState();
}

class _AiBusinessAssistantSheetState
    extends ConsumerState<AiBusinessAssistantSheet> {
  final TextEditingController _queryController = TextEditingController();
  final List<(bool isUser, String text)> _conversation = [];

  static const _suggestedPrompts = [
    "What is our net profit & margin?",
    "Draft a client proposal pitch.",
    "Draft a WhatsApp follow-up message.",
    "Show me all leads that haven't received a follow-up in seven days.",
    "Which employee converted the most leads this month?",
    "How many active website development projects do we have?",
    "Show me all clients with pending payments.",
    "Summarise today's business activities.",
  ];

  @override
  void initState() {
    super.initState();
    final initialSummary = ref
        .read(agencyStoreProvider.notifier)
        .generateAiAssistantResponse("Summarise today's business activities.");
    _conversation.add((false, initialSummary));
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _submitQuery(String prompt) {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) return;
    final reply = ref
        .read(agencyStoreProvider.notifier)
        .generateAiAssistantResponse(trimmed);
    setState(() {
      _conversation.add((true, trimmed));
      _conversation.add((false, reply));
      _queryController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
                child: Row(
                  children: [
                    const BhBrandLogo(
                      size: 42,
                      borderRadius: 13,
                      useLightTile: false,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blue Hour AI Intelligence',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            'RBAC-scoped to ${state.currentUser.name} (${state.currentUser.role.label})',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Suggested Prompt Chips
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestedPrompts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final prompt = _suggestedPrompts[index];
                    return ActionChip(
                      avatar: const Icon(
                        Icons.bolt_rounded,
                        size: 15,
                        color: AppColors.electricBlue,
                      ),
                      label: Text(
                        prompt,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () => _submitQuery(prompt),
                    );
                  },
                ),
              ),

              // Conversation List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _conversation.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _conversation[index];
                    final isUser = item.$1;
                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.84,
                        ),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: isUser ? AppColors.brandGradient : null,
                          color: isUser
                              ? null
                              : (isDark
                                  ? AppColors.darkElevatedSurface
                                  : AppColors.lightElevatedSurface),
                          borderRadius: BorderRadius.circular(16),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.$2,
                              style: TextStyle(
                                color: isUser
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary),
                                fontSize: 13.5,
                                height: 1.48,
                              ),
                            ),
                            if (!isUser) ...[
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: item.$2),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Copied AI response'),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.copy_rounded,
                                          size: 13,
                                          color: AppColors.electricBlue,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Copy',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.electricBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Input bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        onSubmitted: _submitQuery,
                        decoration: const InputDecoration(
                          hintText:
                              'Ask about leads, revenue, overdue tasks or proposals...',
                          prefixIcon: Icon(Icons.psychology_outlined, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: () => _submitQuery(_queryController.text),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.electricBlue,
                        padding: const EdgeInsets.all(14),
                      ),
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Global Debounced Search Sheet across Leads, Clients, Employees, Projects, Tasks, Messages, Meetings, Invoices (Section 22).
class GlobalSearchSheet extends ConsumerStatefulWidget {
  const GlobalSearchSheet({super.key});

  @override
  ConsumerState<GlobalSearchSheet> createState() => _GlobalSearchSheetState();
}

class _GlobalSearchSheetState extends ConsumerState<GlobalSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final q = _query.trim().toLowerCase();

    final matchedLeads = state.leads
        .where((l) =>
            q.isEmpty ||
            l.companyName.toLowerCase().contains(q) ||
            l.contactPerson.toLowerCase().contains(q) ||
            l.interestedService.toLowerCase().contains(q))
        .take(3)
        .toList();

    final matchedProjects = state.projects
        .where((p) =>
            q.isEmpty ||
            p.name.toLowerCase().contains(q) ||
            p.clientName.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .take(3)
        .toList();

    final matchedClients = state.clients
        .where((c) =>
            q.isEmpty ||
            c.companyName.toLowerCase().contains(q) ||
            c.contactPerson.toLowerCase().contains(q))
        .take(2)
        .toList();

    final matchedTasks = state.tasks
        .where((t) =>
            q.isEmpty ||
            t.title.toLowerCase().contains(q) ||
            t.assignedEmployee.toLowerCase().contains(q))
        .take(2)
        .toList();

    final matchedInvoices = state.invoices
        .where((inv) =>
            q.isEmpty ||
            inv.invoiceNumber.toLowerCase().contains(q) ||
            inv.clientName.toLowerCase().contains(q))
        .take(2)
        .toList();

    final matchedFounders = state.employees
        .where((emp) =>
            q.isEmpty ||
            emp.name.toLowerCase().contains(q) ||
            emp.designation.toLowerCase().contains(q) ||
            emp.department.toLowerCase().contains(q))
        .toList();

    final matchedMessages = <(String threadName, String senderName, String body)>[];
    for (final thread in state.chatThreads) {
      for (final msg in thread.messages) {
        if (q.isEmpty ||
            msg.body.toLowerCase().contains(q) ||
            msg.senderName.toLowerCase().contains(q) ||
            thread.name.toLowerCase().contains(q)) {
          matchedMessages.add((thread.name, msg.senderName, msg.body));
        }
      }
    }
    final topMessages = matchedMessages.take(3).toList();

    final hasAnyRecords = matchedLeads.isNotEmpty ||
        matchedProjects.isNotEmpty ||
        matchedClients.isNotEmpty ||
        matchedTasks.isNotEmpty ||
        matchedInvoices.isNotEmpty ||
        topMessages.isNotEmpty ||
        matchedFounders.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText:
                      'Search leads, clients, projects, tasks, messages, invoices...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () => setState(() => _query = ''),
                          icon: const Icon(Icons.clear_rounded),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: !hasAnyRecords
                    ? const Center(
                        child: BhArtisticEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matching studio records',
                          subtitle:
                              'Try searching for Himon, Darshana, Drishant, or add new leads and projects first.',
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        children: [
                          if (matchedFounders.isNotEmpty) ...[
                            const BhSectionHeader(
                              kicker: 'LEADERSHIP',
                              title: 'Founders & Architects',
                            ),
                            const SizedBox(height: 8),
                            ...matchedFounders.map(
                              (emp) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: BhSurfaceCard(
                                  padding: const EdgeInsets.all(12),
                                  onTap: () {
                                    Navigator.pop(context);
                                    context.go('/profile');
                                  },
                                  child: Row(
                                    children: [
                                      BhAvatar(
                                        name: emp.name,
                                        size: 38,
                                        isOnline: emp.isOnline,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              emp.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium,
                                            ),
                                            Text(
                                              emp.designation,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      BhStatusPill(
                                        label: emp.employeeCode,
                                        color: AppColors.electricBlue,
                                        compact: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (matchedLeads.isNotEmpty) ...[
                      const BhSectionHeader(title: 'CRM Leads'),
                      const SizedBox(height: 8),
                      ...matchedLeads.map(
                        (l) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/leads/${l.id}');
                            },
                            child: Row(
                              children: [
                                BhAvatar(name: l.companyName, size: 38),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.companyName,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        '${l.contactPerson} • ${BhFormatters.inr(l.estimatedBudgetInr)}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                BhStatusPill.fromLeadStatus(l.status, compact: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (matchedProjects.isNotEmpty) ...[
                      const BhSectionHeader(title: 'Projects'),
                      const SizedBox(height: 8),
                      ...matchedProjects.map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/projects');
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppColors.indigo.withValues(alpha: 0.16),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Icon(
                                    Icons.rocket_launch_rounded,
                                    color: AppColors.indigo,
                                    size: 19,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      Text(
                                        '${p.clientName} • ${p.progressPercentage}% complete',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (matchedClients.isNotEmpty) ...[
                      const BhSectionHeader(title: 'Clients'),
                      const SizedBox(height: 8),
                      ...matchedClients.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                BhAvatar(name: c.companyName, size: 36),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${c.companyName} (${c.clientCode})',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                                Text(
                                  BhFormatters.inrCompact(c.totalBilledInr),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.successSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (matchedTasks.isNotEmpty) ...[
                      const BhSectionHeader(title: 'Tasks'),
                      const SizedBox(height: 8),
                      ...matchedTasks.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.task_alt_rounded,
                                  color: AppColors.electricBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${t.taskCode}: ${t.title}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                BhStatusPill.fromPriority(t.priority, compact: true),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (matchedInvoices.isNotEmpty) ...[
                      const BhSectionHeader(title: 'Invoices (INR)'),
                      const SizedBox(height: 8),
                      ...matchedInvoices.map(
                        (inv) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${inv.invoiceNumber} • ${inv.clientName}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  BhFormatters.inr(inv.totalAmountInr),
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (topMessages.isNotEmpty) ...[
                      const BhSectionHeader(title: 'Founder Messages'),
                      const SizedBox(height: 8),
                      ...topMessages.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () {
                              Navigator.pop(context);
                              context.go('/chat');
                            },
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.forum_rounded,
                                  color: AppColors.electricBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${m.$1} • ${m.$2}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(
                                              color: AppColors.electricBlue,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      Text(
                                        m.$3,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

