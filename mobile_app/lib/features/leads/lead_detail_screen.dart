import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final String leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showScheduleFollowupModal(LeadRecord lead) {
    String selectedType = 'Phone Call';
    final notesCtrl = TextEditingController(
      text: 'Follow up on ${lead.interestedService} commercial proposal.',
    );
    DateTime scheduledDate = DateTime.now().add(const Duration(days: 1));
    final selectedReminders = <String>{
      '1 day before',
      '1 hour before',
      '15 minutes before',
      'At scheduled time',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule Follow-up Reminder',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                  Text(
                    'Laravel Scheduler + Redis Queue will dispatch FCM reminders automatically.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Follow-up Channel',
                      prefixIcon: Icon(Icons.support_agent_rounded),
                    ),
                    items: const [
                      'Phone Call',
                      'WhatsApp',
                      'Email',
                      'Client Meeting',
                      'General Follow-up',
                    ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.event_rounded,
                      color: AppColors.electricBlue,
                    ),
                    title: Text(
                      'Date & Time: ${BhFormatters.dateTimeShort(scheduledDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: scheduledDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setModalState(() {
                            scheduledDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              11,
                              30,
                            );
                          });
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ),
                  const Text(
                    'FCM Reminder Intervals:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      '1 day before',
                      '1 hour before',
                      '15 minutes before',
                      'At scheduled time',
                    ].map((interval) {
                      final active = selectedReminders.contains(interval);
                      return FilterChip(
                        label: Text(
                          interval,
                          style: const TextStyle(fontSize: 11),
                        ),
                        selected: active,
                        onSelected: (v) {
                          setModalState(() {
                            if (v) {
                              selectedReminders.add(interval);
                            } else {
                              selectedReminders.remove(interval);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Follow-up Agenda / Notes',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(agencyStoreProvider.notifier)
                            .scheduleLeadFollowup(
                              leadId: lead.id,
                              companyName: lead.companyName,
                              followupType: selectedType,
                              scheduledAt: scheduledDate,
                              notes: notesCtrl.text.trim(),
                            );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Follow-up scheduled for ${lead.companyName} with ${selectedReminders.length} FCM reminders.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_active_rounded, size: 18),
                      label: const Text('Schedule Reminder'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddNoteModal(LeadRecord lead) {
    final noteCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Lead Note (${lead.companyName})',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                autofocus: true,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Enter call outcomes, technical requirements, or commercial notes...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (noteCtrl.text.trim().isEmpty) return;
                    ref
                        .read(agencyStoreProvider.notifier)
                        .addLeadNote(lead.id, noteCtrl.text.trim());
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save to Timeline'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateProposalModal(LeadRecord lead) {
    final titleCtrl = TextEditingController(
      text: '${lead.interestedService} – Enterprise Proposal',
    );
    final subtotalCtrl = TextEditingController(
      text: lead.estimatedBudgetInr.toStringAsFixed(0),
    );
    final discountCtrl = TextEditingController(text: '25000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generate GST Proposal for ${lead.companyName}',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Proposal Title',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: subtotalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Base Amount (INR ₹)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Discount (INR ₹)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final sub =
                        double.tryParse(subtotalCtrl.text.trim()) ??
                        lead.estimatedBudgetInr;
                    final disc =
                        double.tryParse(discountCtrl.text.trim()) ?? 0;
                    ref.read(agencyStoreProvider.notifier).createProposal(
                          clientOrLeadName: lead.companyName,
                          title: titleCtrl.text.trim(),
                          serviceCategory: lead.interestedService,
                          subtotalInr: sub,
                          discountInr: disc,
                        );
                    ref.read(agencyStoreProvider.notifier).updateLeadStatus(
                          lead.id,
                          'Proposal Sent',
                        );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Proposal generated (+18% GST) and linked to ${lead.companyName}.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('Generate Proposal & Move Stage'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final matchingLeads = state.leads.where((l) => l.id == widget.leadId).toList();
    if (matchingLeads.isEmpty && state.leads.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead Details')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: BhArtisticEmptyState(
            icon: Icons.layers_clear_rounded,
            title: 'Lead record not found',
            subtitle:
                'This lead does not exist yet in the clean workspace. Create a new lead from the CRM pipeline first.',
            actionLabel: 'Back to Pipeline',
            onAction: () => context.go('/leads'),
          ),
        ),
      );
    }
    final lead = matchingLeads.isNotEmpty ? matchingLeads.first : state.leads.first;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(lead.leadCode),
        actions: [
          if (lead.status != 'Converted')
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton.icon(
                onPressed: () {
                  ref
                      .read(agencyStoreProvider.notifier)
                      .updateLeadStatus(lead.id, 'Converted');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '🎉 ${lead.companyName} converted! Client profile created automatically.',
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.verified_rounded, size: 16),
                label: const Text(
                  'Convert to Client',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Top Summary Header Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: BhSurfaceCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BhAvatar(name: lead.companyName, size: 50),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.companyName,
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${lead.contactPerson} • ${lead.industry}',
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                BhStatusPill.fromLeadStatus(lead.status),
                                BhStatusPill.fromPriority(lead.priority),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7 Quick Action Buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _LeadQuickActionButton(
                          icon: Icons.call_rounded,
                          label: 'Call',
                          color: AppColors.successSoft,
                          onTap: () {
                            ref.read(agencyStoreProvider.notifier).addLeadNote(
                                  lead.id,
                                  'Outbound call placed to ${lead.contactPerson} (${lead.phone}).',
                                  type: 'call',
                                  customTitle: 'Outbound Call Logged',
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Calling ${lead.phone}...'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _LeadQuickActionButton(
                          icon: Icons.chat_bubble_rounded,
                          label: 'WhatsApp',
                          color: const Color(0xFF25D366),
                          onTap: () {
                            ref.read(agencyStoreProvider.notifier).addLeadNote(
                                  lead.id,
                                  'Initiated WhatsApp Business thread with ${lead.contactPerson}.',
                                  type: 'whatsapp',
                                  customTitle: 'WhatsApp Message Sent',
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Opening WhatsApp chat with ${lead.contactPerson}...',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _LeadQuickActionButton(
                          icon: Icons.email_rounded,
                          label: 'Email',
                          color: AppColors.electricBlue,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Composing email to ${lead.email}...'),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        _LeadQuickActionButton(
                          icon: Icons.notifications_active_rounded,
                          label: 'Follow-up',
                          color: AppColors.warning,
                          onTap: () => _showScheduleFollowupModal(lead),
                        ),
                        const SizedBox(width: 8),
                        _LeadQuickActionButton(
                          icon: Icons.video_call_rounded,
                          label: 'Meeting',
                          color: AppColors.indigo,
                          onTap: () => context.push('/calendar'),
                        ),
                        const SizedBox(width: 8),
                        _LeadQuickActionButton(
                          icon: Icons.edit_note_rounded,
                          label: 'Add Note',
                          color: AppColors.cyanAccent,
                          onTap: () => _showAddNoteModal(lead),
                        ),
                        const SizedBox(width: 8),
                        _LeadQuickActionButton(
                          icon: Icons.description_rounded,
                          label: 'Proposal',
                          color: AppColors.violetAccent,
                          onTap: () => _showCreateProposalModal(lead),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.electricBlue,
            labelColor: AppColors.electricBlue,
            tabs: const [
              Tab(text: 'Overview & Specs'),
              Tab(text: 'Timeline & Logs'),
              Tab(text: 'Files & Quotes'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Overview & Specs
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    BhSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commercial & Pipeline Details',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(
                            label: 'Interested Service',
                            value: lead.interestedService,
                          ),
                          _InfoRow(
                            label: 'Estimated Budget',
                            value: BhFormatters.inr(lead.estimatedBudgetInr),
                            valueColor: AppColors.successSoft,
                          ),
                          _InfoRow(
                            label: 'Lead Source',
                            value: lead.source,
                          ),
                          _InfoRow(
                            label: 'Assigned Executive',
                            value: lead.assignedEmployeeName,
                          ),
                          _InfoRow(
                            label: 'Expected Closing',
                            value: BhFormatters.shortDate(lead.expectedClosingDate),
                          ),
                          _InfoRow(
                            label: 'Next Scheduled Follow-up',
                            value: lead.nextFollowupAt != null
                                ? BhFormatters.dateTimeShort(lead.nextFollowupAt!)
                                : 'Not scheduled',
                            valueColor: AppColors.warning,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    BhSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact & Company Profile',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Phone', value: lead.phone),
                          _InfoRow(label: 'Email', value: lead.email),
                          _InfoRow(label: 'Website', value: lead.website),
                          _InfoRow(label: 'Location', value: lead.location),
                          _InfoRow(label: 'Industry', value: lead.industry),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    BhSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Executive Notes',
                                style: textTheme.headlineSmall,
                              ),
                              TextButton.icon(
                                onPressed: () => _showAddNoteModal(lead),
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Update Note'),
                              ),
                            ],
                          ),
                          Text(
                            lead.notes,
                            style: textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Tab 2: Activity Timeline
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lead.timeline.isEmpty ? 1 : lead.timeline.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    if (lead.timeline.isEmpty) {
                      return BhSurfaceCard(
                        child: Text(
                          'Lead created on ${BhFormatters.shortDate(lead.createdDate)}. Use the actions above to log calls, notes, or follow-ups.',
                          style: textTheme.bodyMedium,
                        ),
                      );
                    }
                    final item = lead.timeline[index];
                    return BhSurfaceCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_edu_rounded,
                              color: AppColors.electricBlue,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${item.actorName} • ${BhFormatters.relativeTime(item.timestamp)}',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.electricBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Tab 3: Proposal Attachments
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...lead.attachments.map(
                      (fileName) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BhSurfaceCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(fileName, style: textTheme.titleSmall),
                                    Text(
                                      'Signed S3 / R2 Document • Encrypted',
                                      style: textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Opening $fileName...'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.download_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showCreateProposalModal(lead),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create New Proposal PDF'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _LeadQuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

