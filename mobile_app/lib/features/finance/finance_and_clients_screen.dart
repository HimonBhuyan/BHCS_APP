import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

class FinanceAndProposalsScreen extends ConsumerStatefulWidget {
  const FinanceAndProposalsScreen({super.key});

  @override
  ConsumerState<FinanceAndProposalsScreen> createState() =>
      _FinanceAndProposalsScreenState();
}

class _FinanceAndProposalsScreenState
    extends ConsumerState<FinanceAndProposalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showCreateFinanceModal() {
    final tabIdx = _tabController.index;
    if (tabIdx == 0) {
      _showCreateInvoiceModal();
    } else if (tabIdx == 1) {
      _showCreateProposalModal();
    } else {
      _showCreateExpenseModal();
    }
  }

  void _showCreateInvoiceModal() {
    final clientCtrl = TextEditingController();
    final projectCtrl = TextEditingController();
    final subtotalCtrl = TextEditingController();

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
                'Generate GST Invoice (INR + 18% GST)',
                style: Theme.of(ctx).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: clientCtrl,
                decoration: const InputDecoration(
                  labelText: 'Client / Company Name *',
                  prefixIcon: Icon(Icons.domain_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: projectCtrl,
                decoration: const InputDecoration(
                  labelText: 'Project / Milestone Name *',
                  prefixIcon: Icon(Icons.rocket_launch_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subtotalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Taxable Base Amount (INR ₹) *',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (clientCtrl.text.trim().isEmpty) return;
                    final subtotal =
                        double.tryParse(subtotalCtrl.text.trim()) ?? 0;
                    final totalInclGst = subtotal * 1.18;
                    ref.read(agencyStoreProvider.notifier).createInvoice(
                          clientName: clientCtrl.text.trim(),
                          projectName: projectCtrl.text.trim().isEmpty
                              ? 'Studio Milestone'
                              : projectCtrl.text.trim(),
                          serviceCategory: 'Software & Digital Engineering',
                          totalAmountInr: totalInclGst,
                          paidAmountInr: 0,
                        );
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text('Issue GST Invoice'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateProposalModal() {
    final clientCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    final subtotalCtrl = TextEditingController();
    final discountCtrl = TextEditingController(text: '0');
    String selectedService = LeadRecord.agencyServices.first;

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
                    'Generate Commercial Proposal (INR)',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: clientCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Client or Lead Name *',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Proposal Title *',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedService,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Service Category',
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
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (clientCtrl.text.trim().isEmpty ||
                            titleCtrl.text.trim().isEmpty) {
                          return;
                        }
                        ref.read(agencyStoreProvider.notifier).createProposal(
                              clientOrLeadName: clientCtrl.text.trim(),
                              title: titleCtrl.text.trim(),
                              serviceCategory: selectedService,
                              subtotalInr: double.tryParse(
                                      subtotalCtrl.text.trim()) ??
                                  0,
                              discountInr: double.tryParse(
                                      discountCtrl.text.trim()) ??
                                  0,
                            );
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                      label: const Text('Save & Generate Proposal'),
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

  void _showCreateExpenseModal() {
    final vendorCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCategory = 'Cloud & Infrastructure';

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
                    'Record Studio Expense (INR)',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: vendorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vendor / Payee Name *',
                      prefixIcon: Icon(Icons.storefront_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Expense Category',
                    ),
                    items: const [
                      'Cloud & Infrastructure',
                      'Hardware & IoT Lab',
                      'SaaS Subscriptions',
                      'Marketing & Ads',
                      'Operations & Travel',
                    ]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedCategory = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (INR ₹) *',
                      prefixIcon: Icon(Icons.currency_rupee_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description / Invoice Reference',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (vendorCtrl.text.trim().isEmpty) return;
                        ref.read(agencyStoreProvider.notifier).createExpense(
                              category: selectedCategory,
                              vendorName: vendorCtrl.text.trim(),
                              description: descCtrl.text.trim().isEmpty
                                  ? selectedCategory
                                  : descCtrl.text.trim(),
                              amountInr:
                                  double.tryParse(amountCtrl.text.trim()) ?? 0,
                            );
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.add_card_rounded, size: 18),
                      label: const Text('Log Studio Expense'),
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

  Widget _financeStatTile(String label, String value, Color color) {
    return BhSurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final notifier = ref.read(agencyStoreProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    if (!state.currentUser.role.canAccessFinance) {
      return Scaffold(
        appBar: AppBar(title: const Text('Finance & GST Ledger')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BhSurfaceCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_person_rounded,
                    size: 48,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'RBAC Restricted Module',
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your active role (${state.currentUser.role.label}) does not have permission to view agency financial ledgers. Switch to Founder or Finance Manager to inspect INR invoices.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        notifier.switchActiveRole(UserRole.founder),
                    child: const Text('Switch to Founder Role'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final totalExpenses = state.expenses.fold<double>(
      0,
      (sum, e) => sum + e.amountInr,
    );

    final fabLabels = ['New Invoice', 'New Proposal', 'Log Expense'];

    return Scaffold(
      appBar: AppBar(
        leading: const BhSmartBackButton(),
        title: const Text('Finance, Invoices & Proposals (INR)'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.electricBlue,
          labelColor: AppColors.electricBlue,
          tabs: const [
            Tab(text: 'GST Invoices'),
            Tab(text: 'Proposals'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateFinanceModal,
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          fabLabels[_tabController.index],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BhAmbientCanvas(
        child: Column(
          children: [
            // Top Financial Summary Strip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _financeStatTile(
                          'Collected (INR)',
                          BhFormatters.inrCompact(state.monthlyRevenueInr),
                          AppColors.successSoft,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _financeStatTile(
                          'Receivables',
                          BhFormatters.inrCompact(state.outstandingPaymentsInr),
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _financeStatTile(
                          'Studio OpEx',
                          BhFormatters.inrCompact(totalExpenses),
                          AppColors.electricBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _financeStatTile(
                          'Net Profit',
                          BhFormatters.inrCompact(state.netProfitInr),
                          state.netProfitInr >= 0
                              ? AppColors.successSoft
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: GST Invoices
                  state.invoices.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: BhArtisticEmptyState(
                              icon: Icons.receipt_long_rounded,
                              title: 'No GST invoices issued yet',
                              subtitle:
                                  'Create an INR GST invoice (+18% GST) for any client project or milestone.',
                              actionLabel: '+ Issue GST Invoice',
                              onAction: _showCreateInvoiceModal,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                          itemCount: state.invoices.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final inv = state.invoices[index];
                            final statusColor = inv.status == 'Paid'
                                ? AppColors.success
                                : (inv.status == 'Overdue'
                                    ? AppColors.error
                                    : AppColors.warning);

                            return BhSurfaceCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        inv.invoiceNumber,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.electricBlue,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          BhStatusPill(
                                            label: inv.status,
                                            color: statusColor,
                                            compact: true,
                                          ),
                                          IconButton(
                                            tooltip: 'Delete Invoice',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            onPressed: () =>
                                                notifier.deleteInvoice(inv.id),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(inv.clientName,
                                      style: textTheme.headlineSmall),
                                  Text(
                                    '${inv.projectName} • Due ${BhFormatters.shortDate(inv.dueDate)}',
                                    style: textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Total (Incl. 18% GST): ${BhFormatters.inr(inv.totalAmountInr)}',
                                            style: textTheme.titleSmall,
                                          ),
                                          Text(
                                            'Paid: ${BhFormatters.inr(inv.paidAmountInr)} • Balance: ${BhFormatters.inr(inv.balanceDueInr)}',
                                            style: textTheme.labelSmall,
                                          ),
                                        ],
                                      ),
                                      if (inv.balanceDueInr > 0)
                                        FilledButton.tonal(
                                          onPressed: () {
                                            notifier
                                                .recordInvoicePayment(inv.id);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Recorded full payment for ${inv.invoiceNumber}.',
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Mark Paid',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  // Tab 2: Proposals & Quotations
                  state.proposals.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: BhArtisticEmptyState(
                              icon: Icons.description_outlined,
                              title: 'No commercial proposals yet',
                              subtitle:
                                  'Draft a client quotation with automatic 18% GST calculation.',
                              actionLabel: '+ New Proposal',
                              onAction: _showCreateProposalModal,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                          itemCount: state.proposals.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final prop = state.proposals[index];
                            return BhSurfaceCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        prop.proposalCode,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.indigo,
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (v) {
                                          if (v == 'delete') {
                                            notifier.deleteProposal(prop.id);
                                          } else {
                                            notifier.updateProposalStatus(
                                              prop.id,
                                              v,
                                            );
                                          }
                                        },
                                        itemBuilder: (_) => const [
                                          PopupMenuItem(
                                            value: 'Sent',
                                            child: Text('Mark Sent'),
                                          ),
                                          PopupMenuItem(
                                            value: 'Accepted',
                                            child: Text('Mark Accepted'),
                                          ),
                                          PopupMenuItem(
                                            value: 'Rejected',
                                            child: Text('Mark Rejected'),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text(
                                              'Delete Proposal',
                                              style: TextStyle(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                        child: BhStatusPill(
                                          label: '${prop.status} ▾',
                                          color: prop.status == 'Accepted'
                                              ? AppColors.success
                                              : AppColors.electricBlue,
                                          compact: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(prop.title,
                                      style: textTheme.titleMedium),
                                  Text(
                                    '${prop.clientOrLeadName} • ${prop.serviceCategory}',
                                    style: textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total: ${BhFormatters.inr(prop.totalAmountInr)} (GST ${BhFormatters.inr(prop.gstAmountInr)})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.successSoft,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Export Proposal PDF',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Generated PDF for ${prop.proposalCode}',
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                            Icons.picture_as_pdf_rounded),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  // Tab 3: Studio Expenses
                  state.expenses.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: BhArtisticEmptyState(
                              icon: Icons.account_balance_wallet_outlined,
                              title: 'No studio expenses logged',
                              subtitle:
                                  'Track cloud hosting, IoT hardware components, and marketing spend in INR.',
                              actionLabel: '+ Log Expense',
                              onAction: _showCreateExpenseModal,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                          itemCount: state.expenses.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final exp = state.expenses[index];
                            return BhSurfaceCard(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.electricBlue
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_rounded,
                                      color: AppColors.electricBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(exp.vendorName,
                                            style: textTheme.titleSmall),
                                        Text(
                                          '${exp.category} • ${exp.description}',
                                          style: textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    BhFormatters.inr(exp.amountInr),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete Expense',
                                    onPressed: () =>
                                        notifier.deleteExpense(exp.id),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Client Management Screen (Section 9)
class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  void _showAddClientModal(BuildContext context, WidgetRef ref) {
    final companyCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+91 ');
    final emailCtrl = TextEditingController();
    final industryCtrl = TextEditingController();
    String selectedService = LeadRecord.agencyServices.first;

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
                    'Add Studio Client Account',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: companyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Company Name *',
                      prefixIcon: Icon(Icons.domain_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: contactCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Primary Contact *',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
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
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedService,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Primary Service Retainer',
                    ),
                    items: LeadRecord.agencyServices
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedService = v);
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (companyCtrl.text.trim().isEmpty) return;
                        ref.read(agencyStoreProvider.notifier).createClient(
                              companyName: companyCtrl.text.trim(),
                              contactPerson: contactCtrl.text.trim().isEmpty
                                  ? 'Client Representative'
                                  : contactCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              address: 'Guwahati / New Delhi, India',
                              industry: industryCtrl.text.trim().isEmpty
                                  ? 'Technology & Digital'
                                  : industryCtrl.text.trim(),
                              service: selectedService,
                              accountManager: ref
                                  .read(agencyStoreProvider)
                                  .currentUser
                                  .name,
                              contractValueInr: 0,
                            );
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.verified_rounded, size: 18),
                      label: const Text('Save Client Account'),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agencyStoreProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BhSmartBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Client Portfolio'),
            Text(
              '${state.clients.length} Active & Retainer Accounts',
              style: textTheme.labelSmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClientModal(context, ref),
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Add Client',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BhAmbientCanvas(
        child: state.clients.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: BhArtisticEmptyState(
                    icon: Icons.domain_rounded,
                    title: 'No client accounts added yet',
                    subtitle:
                        'Convert a lead from the CRM pipeline or tap "+ Add Client" below to onboard your first studio client.',
                    actionLabel: '+ Add Client',
                    onAction: () => _showAddClientModal(context, ref),
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
                itemCount: state.clients.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final client = state.clients[index];
                  return BhFadeSlideIn(
                    delayMs: index * 40,
                    child: BhSurfaceCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              BhAvatar(name: client.companyName, size: 46),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client.companyName,
                                      style: textTheme.headlineSmall,
                                    ),
                                    Text(
                                      '${client.contactPerson} • ${client.industry}',
                                      style: textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              BhStatusPill(
                                label: client.status,
                                color: AppColors.successSoft,
                                compact: true,
                              ),
                              PopupMenuButton<String>(
                                tooltip: 'Client Actions',
                                padding: EdgeInsets.zero,
                                onSelected: (act) async {
                                  final store =
                                      ref.read(agencyStoreProvider.notifier);
                                  if (act == 'edit') {
                                    final compCtrl = TextEditingController(
                                        text: client.companyName);
                                    final cpCtrl = TextEditingController(
                                        text: client.contactPerson);
                                    final emCtrl = TextEditingController(
                                        text: client.email);
                                    final phCtrl = TextEditingController(
                                        text: client.phone);
                                    final nCtrl = TextEditingController(
                                        text: client.notes);
                                    var status = client.status;
                                    await showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (ctx) => StatefulBuilder(
                                        builder: (ctx, setM) => Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                            top: 20,
                                            bottom: MediaQuery.of(ctx)
                                                    .viewInsets
                                                    .bottom +
                                                24,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Edit Client (${client.clientCode})',
                                                  style: Theme.of(ctx)
                                                      .textTheme
                                                      .headlineSmall,
                                                ),
                                                const SizedBox(height: 12),
                                                TextField(
                                                  controller: compCtrl,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Company Name *',
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                TextField(
                                                  controller: cpCtrl,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Contact Person *',
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                TextField(
                                                  controller: phCtrl,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Phone',
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                TextField(
                                                  controller: emCtrl,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Email',
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                DropdownButtonFormField<String>(
                                                  initialValue: status,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Status',
                                                  ),
                                                  items: const [
                                                    'Active',
                                                    'Retainer',
                                                    'On Hold',
                                                  ]
                                                      .map((s) =>
                                                          DropdownMenuItem(
                                                            value: s,
                                                            child: Text(s),
                                                          ))
                                                      .toList(),
                                                  onChanged: (v) {
                                                    if (v != null) {
                                                      setM(() => status = v);
                                                    }
                                                  },
                                                ),
                                                const SizedBox(height: 10),
                                                TextField(
                                                  controller: nCtrl,
                                                  maxLines: 2,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Notes',
                                                  ),
                                                ),
                                                const SizedBox(height: 14),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: FilledButton(
                                                    onPressed: () {
                                                      if (compCtrl.text
                                                          .trim()
                                                          .isEmpty) {
                                                        return;
                                                      }
                                                      store.updateClient(
                                                        clientId: client.id,
                                                        companyName: compCtrl
                                                            .text
                                                            .trim(),
                                                        contactPerson: cpCtrl
                                                            .text
                                                            .trim(),
                                                        email:
                                                            emCtrl.text.trim(),
                                                        phone:
                                                            phCtrl.text.trim(),
                                                        status: status,
                                                        notes:
                                                            nCtrl.text.trim(),
                                                      );
                                                      Navigator.pop(ctx);
                                                    },
                                                    child: const Text(
                                                        'Save Client'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } else if (act == 'delete') {
                                    store.deleteClient(client.id);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit Client'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Delete Client',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: client.servicesPurchased
                                .map(
                                  (s) => BhStatusPill(
                                    label: s,
                                    color: AppColors.electricBlue,
                                    compact: true,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lifetime Billed: ${BhFormatters.inr(client.totalBilledInr)}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.successSoft,
                                ),
                              ),
                              Text(
                                'Outstanding: ${BhFormatters.inr(client.outstandingInr)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: client.outstandingInr > 0
                                      ? AppColors.warning
                                      : AppColors.darkTextSecondary,
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
      ),
    );
  }
}
