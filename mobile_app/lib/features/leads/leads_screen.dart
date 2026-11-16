import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

class LeadsScreen extends ConsumerStatefulWidget {
  const LeadsScreen({super.key});

  @override
  ConsumerState<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends ConsumerState<LeadsScreen> {
  bool _isKanbanView = true;
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';
  String _selectedSourceFilter = 'All';

  void _showCreateLeadSheet() {
    final companyCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+91 ');
    final emailCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final industryCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    String selectedSource = LeadRecord.leadSources.first;
    String selectedService = LeadRecord.agencyServices.first;
    String selectedPriority = 'High';
    final employees = ref.read(agencyStoreProvider).employees;
    String assignedEmployee = employees.first.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final existingLeads = ref.read(agencyStoreProvider).leads;
            final duplicateMatch = companyCtrl.text.trim().length > 3 &&
                existingLeads.any((l) =>
                    l.companyName.toLowerCase() ==
                    companyCtrl.text.trim().toLowerCase());

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
                    top: 16,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create New CRM Lead',
                            style: Theme.of(ctx).textTheme.headlineMedium,
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (duplicateMatch)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Duplicate Detection: A lead with this company name already exists in the pipeline.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      TextField(
                        controller: companyCtrl,
                        onChanged: (_) => setModalState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          prefixIcon: Icon(Icons.business_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: contactCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Contact Person *',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number *',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedService,
                        decoration: const InputDecoration(
                          labelText: 'Interested Service',
                          prefixIcon: Icon(Icons.layers_outlined),
                        ),
                        items: LeadRecord.agencyServices
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setModalState(() => selectedService = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedSource,
                              decoration: const InputDecoration(
                                labelText: 'Lead Source',
                              ),
                              items: LeadRecord.leadSources
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => selectedSource = v);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedPriority,
                              decoration: const InputDecoration(
                                labelText: 'Lead Priority',
                              ),
                              items: const ['Low', 'Medium', 'High', 'Urgent']
                                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => selectedPriority = v);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: budgetCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Est. Budget (INR ₹)',
                                prefixIcon: Icon(Icons.currency_rupee_rounded),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: assignedEmployee,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Assign Owner',
                              ),
                              items: employees
                                  .map((e) => DropdownMenuItem(
                                        value: e.name,
                                        child: Text(
                                          e.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setModalState(() => assignedEmployee = v);
                              },
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
                                labelText: 'City / Location',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: industryCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Industry',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Requirement Summary & Notes',
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (companyCtrl.text.trim().isEmpty ||
                                contactCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter Company Name and Contact Person.',
                                  ),
                                ),
                              );
                              return;
                            }
                            final budget =
                                double.tryParse(budgetCtrl.text.trim()) ?? 500000;
                            ref.read(agencyStoreProvider.notifier).createLead(
                                  companyName: companyCtrl.text.trim(),
                                  contactPerson: contactCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  source: selectedSource,
                                  interestedService: selectedService,
                                  budgetInr: budget,
                                  priority: selectedPriority,
                                  assignedEmployee: assignedEmployee,
                                  location: locationCtrl.text.trim(),
                                  industry: industryCtrl.text.trim(),
                                  notes: notesCtrl.text.trim(),
                                );
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Lead "${companyCtrl.text.trim()}" added to pipeline.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          label: const Text('Save Lead & Schedule Reminder'),
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

  void _exportCsvPreview(List<LeadRecord> leads) {
    final csvBuffer = StringBuffer(
      'Lead ID,Company,Contact,Phone,Service,Source,Budget INR,Status,Assigned To\n',
    );
    for (final l in leads) {
      csvBuffer.writeln(
        '${l.leadCode},"${l.companyName}","${l.contactPerson}",${l.phone},"${l.interestedService}",${l.source},${l.estimatedBudgetInr.toStringAsFixed(0)},${l.status},"${l.assignedEmployeeName}"',
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CRM Pipeline CSV / Excel Export'),
        content: SingleChildScrollView(
          child: SelectableText(
            csvBuffer.toString(),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported ${leads.length} lead records to BlueHour_Leads_Export.csv',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded, size: 17),
            label: const Text('Download CSV'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final textTheme = Theme.of(context).textTheme;

    final filteredLeads = state.leads.where((lead) {
      if (_selectedStatusFilter != 'All' &&
          lead.status != _selectedStatusFilter) {
        return false;
      }
      if (_selectedSourceFilter != 'All' &&
          lead.source != _selectedSourceFilter) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return lead.companyName.toLowerCase().contains(q) ||
            lead.contactPerson.toLowerCase().contains(q) ||
            lead.leadCode.toLowerCase().contains(q) ||
            lead.interestedService.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    final totalPipelineValueInr = filteredLeads.fold<double>(
      0,
      (sum, l) => sum + l.estimatedBudgetInr,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CRM & Lead Pipeline'),
            Text(
              '${filteredLeads.length} Leads • Pipeline Value ${BhFormatters.inrCompact(totalPipelineValueInr)}',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Export CSV / Excel',
            onPressed: () => _exportCsvPreview(filteredLeads),
            icon: const Icon(Icons.file_download_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.view_kanban_rounded, size: 17),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.view_list_rounded, size: 17),
                ),
              ],
              selected: {_isKanbanView},
              onSelectionChanged: (s) => setState(() => _isKanbanView = s.first),
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateLeadSheet,
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Lead',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BhAmbientCanvas(
        child: Column(
          children: [
            // Search & Source Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Search company, contact, ID or service...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    tooltip: 'Filter by Lead Source',
                    onSelected: (v) => setState(() => _selectedSourceFilter = v),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'All', child: Text('All Sources')),
                      ...LeadRecord.leadSources.map(
                        (s) => PopupMenuItem(value: s, child: Text(s)),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.electricBlue.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list_rounded,
                            size: 18,
                            color: AppColors.electricBlue,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _selectedSourceFilter == 'All'
                                ? 'Source'
                                : _selectedSourceFilter,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.electricBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status Filter Chips (for List view or quick stage jump)
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'All',
                  ...LeadRecord.pipelineStatuses,
                ].map((status) {
                  final selected = _selectedStatusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _selectedStatusFilter = status),
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
            const SizedBox(height: 10),

            // Main View: Kanban Pipeline OR List View
            Expanded(
              child: _isKanbanView
                  ? _buildKanbanPipeline(context, filteredLeads)
                  : _buildLeadListView(context, filteredLeads),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanPipeline(BuildContext context, List<LeadRecord> leads) {
    final stages = _selectedStatusFilter == 'All'
        ? LeadRecord.pipelineStatuses
        : [_selectedStatusFilter];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
      itemCount: stages.length,
      separatorBuilder: (_, _) => const SizedBox(width: 14),
      itemBuilder: (context, index) {
        final stage = stages[index];
        final stageLeads = leads.where((l) => l.status == stage).toList();
        final stageTotal = stageLeads.fold<double>(
          0,
          (sum, l) => sum + l.estimatedBudgetInr,
        );

        return SizedBox(
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stage Header Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkElevatedSurface
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BhStatusPill.fromLeadStatus(stage),
                    Text(
                      '${stageLeads.length} • ${BhFormatters.inrCompact(stageTotal)}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: stageLeads.isEmpty
                    ? BhSurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.layers_outlined,
                                size: 26,
                                color: AppColors.electricBlue.withValues(alpha: 0.55),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No leads in "$stage"',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap "+ Add Lead" to populate this pipeline stage.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: stageLeads.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          return BhFadeSlideIn(
                            delayMs: idx * 40,
                            child: _LeadCardItem(lead: stageLeads[idx]),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeadListView(BuildContext context, List<LeadRecord> leads) {
    if (leads.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BhArtisticEmptyState(
            icon: Icons.filter_alt_outlined,
            title: 'Your CRM pipeline is clean',
            subtitle:
                'No dummy leads are preloaded. Tap "+ Add Lead" below to capture your first real studio inquiry.',
            actionLabel: '+ Add First Lead',
            onAction: _showCreateLeadSheet,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: leads.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return BhFadeSlideIn(
          delayMs: index * 35,
          child: _LeadCardItem(lead: leads[index]),
        );
      },
    );
  }
}

class _LeadCardItem extends ConsumerWidget {
  final LeadRecord lead;

  const _LeadCardItem({required this.lead});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return BhSurfaceCard(
      onTap: () => context.push('/leads/${lead.id}'),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lead.leadCode,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.electricBlue,
                  letterSpacing: 0.4,
                ),
              ),
              BhStatusPill.fromPriority(lead.priority, compact: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lead.companyName,
            style: textTheme.headlineSmall?.copyWith(fontSize: 15.5),
          ),
          const SizedBox(height: 3),
          Text(
            '${lead.contactPerson} • ${lead.location}',
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    lead.interestedService,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.electricBlue,
                    ),
                  ),
                ),
                Text(
                  BhFormatters.inr(lead.estimatedBudgetInr),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.successSoft,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  BhAvatar(name: lead.assignedEmployeeName, size: 24),
                  const SizedBox(width: 7),
                  Text(
                    lead.assignedEmployeeName,
                    style: textTheme.labelMedium,
                  ),
                ],
              ),
              PopupMenuButton<String>(
                tooltip: 'Move Pipeline Stage',
                onSelected: (newStage) {
                  ref
                      .read(agencyStoreProvider.notifier)
                      .updateLeadStatus(lead.id, newStage);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${lead.companyName} moved to "$newStage"',
                      ),
                    ),
                  );
                },
                itemBuilder: (ctx) => LeadRecord.pipelineStatuses
                    .map(
                      (s) => PopupMenuItem(
                        value: s,
                        child: Text(s),
                      ),
                    )
                    .toList(),
                child: BhStatusPill.fromLeadStatus(lead.status, compact: true),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

