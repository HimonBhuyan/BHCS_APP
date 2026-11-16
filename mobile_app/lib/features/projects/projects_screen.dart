import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/bh_widgets.dart';
import '../../data/models/agency_models.dart';
import '../../data/repositories/agency_store.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _selectedCategory = 'All';

  void _showCreateProjectModal() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final state = ref.read(agencyStoreProvider);
    final clientCtrl = TextEditingController(
      text: state.clients.isNotEmpty ? state.clients.first.companyName : '',
    );
    String selectedCategory = ProjectRecord.categories.first;
    String selectedManager = state.employees.first.name;

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Client Project',
                      style: Theme.of(ctx).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Project Name *',
                        prefixIcon: Icon(Icons.rocket_launch_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: clientCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Client / Company Name *',
                        prefixIcon: Icon(Icons.domain_rounded),
                      ),
                    ),
                    if (state.clients.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: state.clients
                            .map(
                              (c) => ActionChip(
                                label: Text(
                                  c.companyName,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed: () => setModalState(
                                  () => clientCtrl.text = c.companyName,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Project Category',
                      ),
                      items: ProjectRecord.categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedCategory = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: budgetCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Project Budget (INR ₹)',
                              hintText: 'e.g. 450000',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedManager,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Project Lead',
                            ),
                            items: state.employees
                                .map((e) => DropdownMenuItem(
                                      value: e.name,
                                      child: Text(
                                        e.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setModalState(() => selectedManager = v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Scope & Deliverables Description',
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) return;
                          final budget =
                              double.tryParse(budgetCtrl.text.trim()) ?? 0;
                          final clientName = clientCtrl.text.trim().isEmpty
                              ? 'Blue Hour Client'
                              : clientCtrl.text.trim();
                          ref.read(agencyStoreProvider.notifier).createProject(
                                name: nameCtrl.text.trim(),
                                clientName: clientName,
                                category: selectedCategory,
                                description: descCtrl.text.trim(),
                                projectManager: selectedManager,
                                budgetInr: budget,
                                deadline:
                                    DateTime.now().add(const Duration(days: 30)),
                              );
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Launch Project Workspace'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openProjectDetailSheet(ProjectRecord project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final state = ref.watch(agencyStoreProvider);
            final currentProj = state.projects.firstWhere(
              (p) => p.id == project.id,
              orElse: () => project,
            );
            final projTasks = state.tasks
                .where((t) => t.projectId == currentProj.id)
                .toList();
            final textTheme = Theme.of(context).textTheme;

            return DraggableScrollableSheet(
              initialChildSize: 0.86,
              minChildSize: 0.6,
              maxChildSize: 0.94,
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
                          currentProj.projectCode,
                          style: const TextStyle(
                            color: AppColors.electricBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    Text(currentProj.name, style: textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${currentProj.clientName} • ${currentProj.category}',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    Text(currentProj.description, style: textTheme.bodyMedium),
                    const SizedBox(height: 16),

                    // Interactive Progress Control
                    BhSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sprint Completion: ${currentProj.progressPercentage}%',
                                style: textTheme.titleSmall,
                              ),
                              Text(
                                BhFormatters.inr(currentProj.budgetInr),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.successSoft,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: currentProj.progressPercentage.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            activeColor: AppColors.electricBlue,
                            label: '${currentProj.progressPercentage}%',
                            onChanged: (val) {
                              final nextPct = val.round();
                              ref
                                  .read(agencyStoreProvider.notifier)
                                  .updateProjectProgress(
                                    currentProj.id,
                                    nextPct,
                                    nextPct == 100
                                        ? 'Completed'
                                        : currentProj.status,
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    if (currentProj.milestones.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text('Project Milestones', style: textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      ...currentProj.milestones.map(
                        (ms) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BhSurfaceCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  ms.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: ms.isCompleted
                                      ? AppColors.successSoft
                                      : AppColors.warning,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(ms.title, style: textTheme.titleSmall),
                                      Text(
                                        'Due ${BhFormatters.shortDate(ms.dueDate)}',
                                        style: textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  BhFormatters.inr(ms.amountInr),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    BhSectionHeader(
                      title: 'Linked Tasks & Subtasks',
                      countBadge: projTasks.length,
                      actionLabel: 'Task Board',
                      onAction: () {
                        Navigator.pop(context);
                        context.push('/tasks');
                      },
                    ),
                    const SizedBox(height: 8),
                    ...projTasks.map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: BhSurfaceCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.title,
                                      style: textTheme.titleSmall,
                                    ),
                                  ),
                                  BhStatusPill(
                                    label: t.status,
                                    color: AppColors.electricBlue,
                                    compact: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${t.assignedEmployee} • ${t.loggedHours}/${t.estimatedHours} hrs logged',
                                style: textTheme.bodySmall,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final textTheme = Theme.of(context).textTheme;

    final filteredProjects = state.projects.where((p) {
      if (_selectedCategory == 'All') return true;
      return p.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Projects & Delivery'),
            Text(
              '${filteredProjects.length} Projects • ${state.tasks.length} Active Tasks',
              style: textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/tasks'),
            icon: const Icon(Icons.checklist_rounded, size: 18),
            label: const Text('Tasks Board'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateProjectModal,
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Project',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: BhAmbientCanvas(
        child: Column(
          children: [
            // Category Filter Chips
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: ['All', ...ProjectRecord.categories].map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
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
            const SizedBox(height: 8),

            Expanded(
              child: filteredProjects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: BhArtisticEmptyState(
                          icon: Icons.rocket_launch_outlined,
                          title: 'No studio projects created yet',
                          subtitle:
                              'Launch your first Website, Software, Social Media, or Hardware & IoT project workspace.',
                          actionLabel: '+ New Project',
                          onAction: _showCreateProjectModal,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: filteredProjects.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final project = filteredProjects[index];
                        final statusColor = project.status == 'Completed'
                            ? AppColors.success
                            : (project.status == 'Delayed'
                                ? AppColors.error
                                : AppColors.electricBlue);

                        return BhFadeSlideIn(
                          delayMs: index * 40,
                          child: BhSurfaceCard(
                            onTap: () => _openProjectDetailSheet(project),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${project.projectCode} • ${project.category}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.electricBlue,
                                      ),
                                    ),
                                    BhStatusPill(
                                      label: project.status,
                                      color: statusColor,
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(project.name, style: textTheme.headlineSmall),
                                const SizedBox(height: 3),
                                Text(
                                  'Client: ${project.clientName} • Lead: ${project.projectManager}',
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress: ${project.progressPercentage}%',
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Due ${BhFormatters.shortDate(project.deadline)}',
                                      style: textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: project.progressPercentage / 100.0,
                                    minHeight: 7,
                                    backgroundColor:
                                        statusColor.withValues(alpha: 0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        statusColor),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: project.assignedTeam
                                          .map(
                                            (m) => Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 6),
                                              child: BhAvatar(name: m, size: 28),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                    Text(
                                      BhFormatters.inr(project.budgetInr),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.successSoft,
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
          ],
        ),
      ),
    );
  }
}

/// Dedicated Task Management Screen (Section 11).
class TasksBoardScreen extends ConsumerStatefulWidget {
  const TasksBoardScreen({super.key});

  @override
  ConsumerState<TasksBoardScreen> createState() => _TasksBoardScreenState();
}

class _TasksBoardScreenState extends ConsumerState<TasksBoardScreen> {
  String _selectedStatus = 'All';

  void _showCreateTaskSheet() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final state = ref.read(agencyStoreProvider);
    ProjectRecord? selectedProj =
        state.projects.isNotEmpty ? state.projects.first : null;
    final projectFallbackCtrl = TextEditingController(
      text: selectedProj?.name ?? 'Studio Sprint',
    );
    String selectedAssignee = state.employees.first.name;
    String selectedPriority = 'High';

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
                    'Create New Studio Task',
                    style: Theme.of(ctx).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Task Title *',
                      prefixIcon: Icon(Icons.task_alt_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (state.projects.isNotEmpty)
                    DropdownButtonFormField<ProjectRecord>(
                      initialValue: selectedProj,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Project'),
                      items: state.projects
                          .map((p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setModalState(() => selectedProj = v);
                      },
                    )
                  else
                    TextField(
                      controller: projectFallbackCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Project / Workstream',
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedAssignee,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Assign Founder',
                          ),
                          items: state.employees
                              .map((e) => DropdownMenuItem(
                                    value: e.name,
                                    child: Text(
                                      e.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => selectedAssignee = v);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedPriority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                          ),
                          items: const ['Low', 'Medium', 'High', 'Critical']
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setModalState(() => selectedPriority = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Task Acceptance Criteria & Notes',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty) return;
                        ref.read(agencyStoreProvider.notifier).createTask(
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              projectId: selectedProj?.id ?? 'proj-general',
                              projectName: selectedProj?.name ??
                                  (projectFallbackCtrl.text.trim().isEmpty
                                      ? 'Studio Sprint'
                                      : projectFallbackCtrl.text.trim()),
                              assignedEmployee: selectedAssignee,
                              priority: selectedPriority,
                              deadline:
                                  DateTime.now().add(const Duration(days: 3)),
                            );
                        Navigator.pop(ctx);
                      },
                      child: const Text('Assign Task & Notify Founder'),
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
  Widget build(BuildContext context) {
    final state = ref.watch(agencyStoreProvider);
    final textTheme = Theme.of(context).textTheme;

    final filtered = state.tasks.where((t) {
      if (_selectedStatus == 'All') return true;
      return t.status == _selectedStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dedicated Task Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskSheet,
        backgroundColor: AppColors.electricBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Create Task'),
      ),
      body: BhAmbientCanvas(
        child: Column(
          children: [
            SizedBox(
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: ['All', ...TaskItem.statuses].map((s) {
                  final selected = _selectedStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(s),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedStatus = s),
                      selectedColor: AppColors.electricBlue,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: BhArtisticEmptyState(
                          icon: Icons.task_alt_rounded,
                          title: 'No tasks on the board',
                          subtitle:
                              'Assign development, IoT hardware, or social growth tasks to Himon, Darshana, or Drishant.',
                          actionLabel: '+ Create Task',
                          onAction: _showCreateTaskSheet,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 92),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        return BhFadeSlideIn(
                          delayMs: index * 35,
                          child: BhSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task.taskCode,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.electricBlue,
                                      ),
                                    ),
                                    BhStatusPill.fromPriority(
                                      task.priority,
                                      compact: true,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(task.title, style: textTheme.titleMedium),
                                const SizedBox(height: 3),
                                Text(
                                  '${task.projectName} • Assigned to ${task.assignedEmployee}',
                                  style: textTheme.bodySmall,
                                ),
                                if (task.subtasks.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  ...task.subtasks.map(
                                    (st) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            st.isCompleted
                                                ? Icons.check_box_rounded
                                                : Icons
                                                    .check_box_outline_blank_rounded,
                                            size: 16,
                                            color: st.isCompleted
                                                ? AppColors.successSoft
                                                : AppColors.darkTextSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              st.title,
                                              style: textTheme.bodySmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      task.isOverdue
                                          ? '⚠️ Overdue (${BhFormatters.shortDate(task.deadline)})'
                                          : 'Due ${BhFormatters.shortDate(task.deadline)}',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: task.isOverdue
                                            ? AppColors.error
                                            : AppColors.darkTextSecondary,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (nextStatus) {
                                        ref
                                            .read(agencyStoreProvider.notifier)
                                            .updateTaskStatus(
                                                task.id, nextStatus);
                                      },
                                      itemBuilder: (ctx) => TaskItem.statuses
                                          .map((s) => PopupMenuItem(
                                                value: s,
                                                child: Text(s),
                                              ))
                                          .toList(),
                                      child: BhStatusPill(
                                        label: '${task.status} ▾',
                                        color: AppColors.electricBlue,
                                        compact: true,
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
          ],
        ),
      ),
    );
  }
}

