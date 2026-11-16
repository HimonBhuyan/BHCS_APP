import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/agency_models.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/formatters.dart';

@immutable
class AgencyAppState {
  final bool isLoggedIn;
  final bool hasCompletedOnboarding;
  final ThemeMode themeMode;
  final bool isOfflineMode;
  final int pendingOfflineActions;
  final String selectedDashboardRange; // Today, This Week, This Month, This Quarter, Custom
  final AppUser currentUser;
  final List<AppUser> employees;
  final List<LeadRecord> leads;
  final List<LeadFollowupItem> followups;
  final List<ClientRecord> clients;
  final List<ChatThread> chatThreads;
  final List<ProjectRecord> projects;
  final List<TaskItem> tasks;
  final List<MeetingRecord> meetings;
  final List<AppNotification> notifications;
  final List<ProposalRecord> proposals;
  final List<InvoiceRecord> invoices;
  final List<ExpenseRecord> expenses;
  final NotificationPreferencesState notificationPrefs;

  const AgencyAppState({
    this.isLoggedIn = false,
    this.hasCompletedOnboarding = false,
    required this.themeMode,
    required this.isOfflineMode,
    required this.pendingOfflineActions,
    required this.selectedDashboardRange,
    required this.currentUser,
    required this.employees,
    required this.leads,
    required this.followups,
    required this.clients,
    required this.chatThreads,
    required this.projects,
    required this.tasks,
    required this.meetings,
    required this.notifications,
    required this.proposals,
    required this.invoices,
    required this.expenses,
    required this.notificationPrefs,
  });

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  int get totalUnreadChatCount =>
      chatThreads.fold<int>(0, (acc, t) => acc + t.unreadCount);

  double get monthlyRevenueInr => invoices
      .where((inv) => inv.status == 'Paid' || inv.status == 'Partially Paid')
      .fold<double>(0, (acc, inv) => acc + inv.paidAmountInr);

  double get outstandingPaymentsInr =>
      invoices.fold<double>(0, (acc, inv) => acc + inv.balanceDueInr);

  int get convertedLeadsCount =>
      leads.where((l) => l.status == 'Converted').length;

  int get newLeadsCount =>
      leads.where((l) => l.status == 'New Lead').length;

  double get conversionRatePercent =>
      leads.isEmpty ? 0 : (convertedLeadsCount / leads.length) * 100;

  AgencyAppState copyWith({
    bool? isLoggedIn,
    bool? hasCompletedOnboarding,
    ThemeMode? themeMode,
    bool? isOfflineMode,
    int? pendingOfflineActions,
    String? selectedDashboardRange,
    AppUser? currentUser,
    List<AppUser>? employees,
    List<LeadRecord>? leads,
    List<LeadFollowupItem>? followups,
    List<ClientRecord>? clients,
    List<ChatThread>? chatThreads,
    List<ProjectRecord>? projects,
    List<TaskItem>? tasks,
    List<MeetingRecord>? meetings,
    List<AppNotification>? notifications,
    List<ProposalRecord>? proposals,
    List<InvoiceRecord>? invoices,
    List<ExpenseRecord>? expenses,
    NotificationPreferencesState? notificationPrefs,
  }) {
    return AgencyAppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      themeMode: themeMode ?? this.themeMode,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      pendingOfflineActions: pendingOfflineActions ?? this.pendingOfflineActions,
      selectedDashboardRange: selectedDashboardRange ?? this.selectedDashboardRange,
      currentUser: currentUser ?? this.currentUser,
      employees: employees ?? this.employees,
      leads: leads ?? this.leads,
      followups: followups ?? this.followups,
      clients: clients ?? this.clients,
      chatThreads: chatThreads ?? this.chatThreads,
      projects: projects ?? this.projects,
      tasks: tasks ?? this.tasks,
      meetings: meetings ?? this.meetings,
      notifications: notifications ?? this.notifications,
      proposals: proposals ?? this.proposals,
      invoices: invoices ?? this.invoices,
      expenses: expenses ?? this.expenses,
      notificationPrefs: notificationPrefs ?? this.notificationPrefs,
    );
  }
}

class AgencyStoreNotifier extends Notifier<AgencyAppState> {
  @override
  AgencyAppState build() {
    ref.onDispose(() => _firestoreSub?.cancel());
    final now = DateTime.now();

    // Official 3 Founders of Blue Hour Creative Studios (The Blue Hour Studios)
    final employees = <AppUser>[
      AppUser(
        id: 'emp-01',
        employeeCode: 'BH-001',
        name: 'Himon Bhuyan',
        email: 'himonbhuyan@gmail.com',
        phone: '+91 70022 01534',
        role: UserRole.superAdmin,
        department: 'Software Architecture, SaaS & AI',
        designation: 'Founder & Principal Software Architect',
        joiningDate: DateTime(2023, 1, 10),
        isOnline: true,
        twoFactorEnabled: true,
        briefingTime: '08:30 AM',
        assignedProjectsCount: 0,
        activeTasksCount: 0,
        convertedLeadsThisMonth: 0,
        performanceScore: 100.0,
      ),
      AppUser(
        id: 'emp-02',
        employeeCode: 'BH-002',
        name: 'Darshana Das',
        email: 'darshana@bluehourstudios.in',
        phone: '+91 84738 91457',
        role: UserRole.founder,
        department: 'Client Growth, Branding & Social Strategy',
        designation: 'Partner — Head of Client Growth & Social Media Strategy',
        joiningDate: DateTime(2023, 1, 10),
        isOnline: true,
        twoFactorEnabled: true,
        briefingTime: '08:30 AM',
        assignedProjectsCount: 0,
        activeTasksCount: 0,
        convertedLeadsThisMonth: 0,
        performanceScore: 100.0,
      ),
      AppUser(
        id: 'emp-03',
        employeeCode: 'BH-003',
        name: 'Drishant Das',
        email: 'drishant@bluehourstudios.in',
        phone: '+91 70028 45190',
        role: UserRole.founder,
        department: 'Hardware Engineering, Embedded & IoT Systems',
        designation: 'Co-Founder — Principal Hardware & IoT Architect',
        joiningDate: DateTime(2023, 1, 10),
        isOnline: true,
        twoFactorEnabled: true,
        briefingTime: '08:30 AM',
        assignedProjectsCount: 0,
        activeTasksCount: 0,
        convertedLeadsThisMonth: 0,
        performanceScore: 100.0,
      ),
    ];

    // Strictly Founders-Only Chat Rooms (No extra dummy channels or fake messages)
    final chatThreads = <ChatThread>[
      ChatThread(
        id: 'founders-hq',
        name: 'Founders Board',
        subtitle: 'Himon Bhuyan • Darshana Das • Drishant Das',
        isChannel: true,
        isPrivate: true,
        unreadCount: 0,
        membersCount: 3,
        lastMessagePreview: 'No messages yet',
        lastActivity: now,
        messages: const [],
      ),
      ChatThread(
        id: 'dm-darshana',
        name: 'Darshana Das',
        subtitle: 'Partner — Head of Client Growth & Social Media Strategy',
        isChannel: false,
        isOnline: true,
        unreadCount: 0,
        membersCount: 2,
        lastMessagePreview: 'No messages yet',
        lastActivity: now,
        messages: const [],
      ),
      ChatThread(
        id: 'dm-drishant',
        name: 'Drishant Das',
        subtitle: 'Co-Founder — Principal Hardware & IoT Architect',
        isChannel: false,
        isOnline: true,
        unreadCount: 0,
        membersCount: 2,
        lastMessagePreview: 'No messages yet',
        lastActivity: now,
        messages: const [],
      ),
      ChatThread(
        id: 'dm-himon',
        name: 'Himon Bhuyan',
        subtitle: 'Founder & Principal Software Architect',
        isChannel: false,
        isOnline: true,
        unreadCount: 0,
        membersCount: 2,
        lastMessagePreview: 'No messages yet',
        lastActivity: now,
        messages: const [],
      ),
    ];

    return AgencyAppState(
      isLoggedIn: false,
      hasCompletedOnboarding: false,
      themeMode: ThemeMode.dark,
      isOfflineMode: false,
      pendingOfflineActions: 0,
      selectedDashboardRange: 'This Month',
      currentUser: employees.first,
      employees: employees,
      leads: const [],
      followups: const [],
      clients: const [],
      chatThreads: chatThreads,
      projects: const [],
      tasks: const [],
      meetings: const [],
      notifications: const [],
      proposals: const [],
      invoices: const [],
      expenses: const [],
      notificationPrefs: const NotificationPreferencesState(),
    );
  }

  static const _kIsLoggedIn = 'bh_is_logged_in';
  static const _kOnboardingDone = 'bh_has_completed_onboarding';
  static const _kActiveFounderId = 'bh_active_founder_id';
  static const _kThemeIsDark = 'bh_theme_is_dark';
  static const _kWorkspaceJson = 'bh_workspace_json_v1';

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _firestoreSub;
  String _lastSyncedJson = '';

  bool get _isFirebaseReady =>
      !Platform.environment.containsKey('FLUTTER_TEST') &&
      Firebase.apps.isNotEmpty;

  @override
  set state(AgencyAppState value) {
    super.state = value;
    unawaited(_saveToPrefs());
  }

  Future<void> flushToStorage() => _saveToPrefs();

  Map<String, dynamic> _encodeWorkspacePayload(AgencyAppState s) {
    return <String, dynamic>{
      'leads': s.leads
          .map((l) => {
                'id': l.id,
                'leadCode': l.leadCode,
                'companyName': l.companyName,
                'contactPerson': l.contactPerson,
                'phone': l.phone,
                'email': l.email,
                'website': l.website,
                'location': l.location,
                'industry': l.industry,
                'source': l.source,
                'interestedService': l.interestedService,
                'estimatedBudgetInr': l.estimatedBudgetInr,
                'assignedEmployeeName': l.assignedEmployeeName,
                'priority': l.priority,
                'status': l.status,
                'expectedClosingDate':
                    l.expectedClosingDate.toIso8601String(),
                'createdDate': l.createdDate.toIso8601String(),
                'nextFollowupAt': l.nextFollowupAt?.toIso8601String(),
                'notes': l.notes,
              })
          .toList(),
      'clients': s.clients
          .map((c) => {
                'id': c.id,
                'clientCode': c.clientCode,
                'companyName': c.companyName,
                'contactPerson': c.contactPerson,
                'email': c.email,
                'phone': c.phone,
                'website': c.website,
                'address': c.address,
                'industry': c.industry,
                'servicesPurchased': c.servicesPurchased,
                'accountManager': c.accountManager,
                'status': c.status,
                'totalBilledInr': c.totalBilledInr,
                'outstandingInr': c.outstandingInr,
                'activeProjectsCount': c.activeProjectsCount,
                'onboardedAt': c.onboardedAt.toIso8601String(),
                'notes': c.notes,
              })
          .toList(),
      'projects': s.projects
          .map((p) => {
                'id': p.id,
                'projectCode': p.projectCode,
                'name': p.name,
                'clientName': p.clientName,
                'category': p.category,
                'description': p.description,
                'projectManager': p.projectManager,
                'assignedTeam': p.assignedTeam,
                'startDate': p.startDate.toIso8601String(),
                'deadline': p.deadline.toIso8601String(),
                'budgetInr': p.budgetInr,
                'status': p.status,
                'progressPercentage': p.progressPercentage,
              })
          .toList(),
      'tasks': s.tasks
          .map((t) => {
                'id': t.id,
                'taskCode': t.taskCode,
                'title': t.title,
                'description': t.description,
                'projectId': t.projectId,
                'projectName': t.projectName,
                'assignedEmployee': t.assignedEmployee,
                'priority': t.priority,
                'status': t.status,
                'startDate': t.startDate.toIso8601String(),
                'deadline': t.deadline.toIso8601String(),
              })
          .toList(),
      'meetings': s.meetings
          .map((m) => {
                'id': m.id,
                'meetingCode': m.meetingCode,
                'title': m.title,
                'clientOrCompany': m.clientOrCompany,
                'description': m.description,
                'startTime': m.startTime.toIso8601String(),
                'endTime': m.endTime.toIso8601String(),
                'meetingType': m.meetingType,
                'location': m.location,
                'onlineMeetingLink': m.onlineMeetingLink,
                'participants': m.participants,
                'assignedEmployee': m.assignedEmployee,
                'notes': m.notes,
              })
          .toList(),
      'proposals': s.proposals
          .map((p) => {
                'id': p.id,
                'proposalCode': p.proposalCode,
                'clientOrLeadName': p.clientOrLeadName,
                'title': p.title,
                'serviceCategory': p.serviceCategory,
                'subtotalInr': p.subtotalInr,
                'discountInr': p.discountInr,
                'gstAmountInr': p.gstAmountInr,
                'totalAmountInr': p.totalAmountInr,
                'validUntil': p.validUntil.toIso8601String(),
                'status': p.status,
                'preparedBy': p.preparedBy,
              })
          .toList(),
      'invoices': s.invoices
          .map((i) => {
                'id': i.id,
                'invoiceNumber': i.invoiceNumber,
                'clientName': i.clientName,
                'projectName': i.projectName,
                'serviceCategory': i.serviceCategory,
                'issueDate': i.issueDate.toIso8601String(),
                'dueDate': i.dueDate.toIso8601String(),
                'totalAmountInr': i.totalAmountInr,
                'paidAmountInr': i.paidAmountInr,
                'status': i.status,
              })
          .toList(),
      'expenses': s.expenses
          .map((e) => {
                'id': e.id,
                'expenseCode': e.expenseCode,
                'category': e.category,
                'vendorName': e.vendorName,
                'description': e.description,
                'amountInr': e.amountInr,
                'date': e.date.toIso8601String(),
              })
          .toList(),
      'followups': s.followups
          .map((f) => {
                'id': f.id,
                'leadId': f.leadId,
                'companyName': f.companyName,
                'assignedEmployee': f.assignedEmployee,
                'followupType': f.followupType,
                'scheduledAt': f.scheduledAt.toIso8601String(),
                'notes': f.notes,
                'isCompleted': f.isCompleted,
              })
          .toList(),
      'notifications': s.notifications
          .map((n) => {
                'id': n.id,
                'category': n.category,
                'title': n.title,
                'body': n.body,
                'timestamp': n.timestamp.toIso8601String(),
                'isRead': n.isRead,
                'targetRoute': n.targetRoute,
                'entityId': n.entityId,
                'actions': n.actions,
              })
          .toList(),
      'chatThreadUnreads': {
        for (final t in s.chatThreads) t.id: t.unreadCount,
      },
      'chatMessages': {
        for (final t in s.chatThreads)
          t.id: t.messages
              .map((m) => {
                    'id': m.id,
                    'threadId': m.threadId,
                    'senderId': m.senderId,
                    'senderName': m.senderName,
                    'senderRole': m.senderRole,
                    'body': m.body,
                    'timestamp': m.timestamp.toIso8601String(),
                    'isMe': m.isMe,
                    'messageType': m.messageType,
                    'attachmentName': m.attachmentName,
                    'attachmentSize': m.attachmentSize,
                    'voiceDurationSec': m.voiceDurationSec,
                    'replyToSender': m.replyToSender,
                    'replyToPreview': m.replyToPreview,
                    'reactions': m.reactions,
                    'isPinned': m.isPinned,
                  })
              .toList(),
      },
    };
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = state;
      await prefs.setBool(_kIsLoggedIn, s.isLoggedIn);
      await prefs.setBool(_kOnboardingDone, s.hasCompletedOnboarding);
      await prefs.setString(_kActiveFounderId, s.currentUser.id);
      await prefs.setBool(_kThemeIsDark, s.themeMode == ThemeMode.dark);

      final payload = _encodeWorkspacePayload(s);
      final encodedJson = jsonEncode(payload);
      await prefs.setString(_kWorkspaceJson, encodedJson);
      if (!s.isOfflineMode && encodedJson != _lastSyncedJson) {
        _lastSyncedJson = encodedJson;
        unawaited(_pushToLiveBackends(payload, encodedJson, prefs));
      }
    } catch (_) {
      // Ignore storage errors in widget tests
    }
  }

  static const _kSqlEndpoints = <String>[
    'http://127.0.0.1:8090/index.php?action=sync',
    'http://192.168.1.133:8090/index.php?action=sync',
  ];

  /// Pushes all live workspace records & chat messages to both Firebase Cloud
  /// Firestore (`krypt-6a44c` -> `blue_hour_hq/workspace`) and XAMPP MySQL (`blue_hour_hq`).
  Future<void> _pushToLiveBackends(
    Map<String, dynamic> payload,
    String encodedJson,
    SharedPreferences prefs,
  ) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;

    // 1. Real-time Firebase Cloud Firestore sync (`krypt-6a44c`)
    if (_isFirebaseReady) {
      try {
        await FirebaseFirestore.instance
            .collection('blue_hour_hq')
            .doc('workspace')
            .set({
          'payload': payload,
          'updatedBy': state.currentUser.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // Non-blocking fallback to local cache + SQL
      }
    }

    // 2. Live XAMPP MySQL (`blue_hour_hq`) sync
    final client = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 1500);
    try {
      for (final url in _kSqlEndpoints) {
        try {
          final req = await client.postUrl(Uri.parse(url));
          req.headers.contentType = ContentType.json;
          req.write(encodedJson);
          final resp = await req.close();
          await resp.drain<void>();
          if (resp.statusCode == 200) {
            break;
          }
        } catch (_) {
          // Try next endpoint (ADB loopback -> Wi-Fi LAN)
        }
      }

      final firebaseDbUrl = prefs.getString('bh_firebase_db_url');
      if (firebaseDbUrl != null && firebaseDbUrl.trim().isNotEmpty) {
        final cleanUrl = firebaseDbUrl.trim().replaceAll(RegExp(r'/$'), '');
        final req = await client.putUrl(
          Uri.parse('$cleanUrl/blue_hour_hq.json'),
        );
        req.headers.contentType = ContentType.json;
        req.write(encodedJson);
        final resp = await req.close();
        await resp.drain<void>();
      }
    } catch (_) {
      // Non-blocking background sync
    } finally {
      client.close(force: true);
    }
  }

  bool _shouldSurfaceNotification(String category) {
    final prefs = state.notificationPrefs;
    switch (category) {
      case 'Leads':
        return prefs.leadReminders;
      case 'Meetings':
        return prefs.meetingReminders;
      case 'Tasks':
        return prefs.taskReminders;
      case 'Projects':
        return prefs.projectNotifications;
      case 'Messages':
        return prefs.chatNotifications;
      case 'Payments':
        return prefs.paymentNotifications;
      default:
        return true;
    }
  }

  void _startRealtimeFirestoreListener() {
    if (!_isFirebaseReady || _firestoreSub != null) return;
    _firestoreSub = FirebaseFirestore.instance
        .collection('blue_hour_hq')
        .doc('workspace')
        .snapshots()
        .listen((snap) {
      final data = snap.data();
      if (data == null || data['payload'] is! Map) return;
      final remotePayload = Map<String, dynamic>.from(data['payload'] as Map);
      final encodedRemote = jsonEncode(remotePayload);
      if (encodedRemote == _lastSyncedJson) return;

      final updatedBy = data['updatedBy']?.toString();
      final existingIds = state.notifications.map((n) => n.id).toSet();

      _lastSyncedJson = encodedRemote;
      final nextState = _applyWorkspaceMap(
        state,
        remotePayload,
        state.currentUser.id,
      );
      super.state = nextState;
      unawaited(
        SharedPreferences.getInstance().then(
          (p) => p.setString(_kWorkspaceJson, encodedRemote),
        ),
      );

      // Fire smooth OS notification banners for incoming notifications from Co-Founders
      if (updatedBy != state.currentUser.id) {
        final incoming = nextState.notifications
            .where((n) => !n.isRead && !existingIds.contains(n.id))
            .take(3);
        for (final notif in incoming) {
          if (_shouldSurfaceNotification(notif.category)) {
            unawaited(
              BhNotificationService.instance.showLocalNotification(
                id: notif.id.hashCode & 0x7FFFFFFF,
                title: notif.title,
                body: notif.body,
                category: notif.category,
                targetRoute: notif.targetRoute ?? '/notifications',
              ),
            );
          }
        }
      }
    }, onError: (_) {});
  }

  Future<String?> _pullFromLiveSqlBackend() async {
    const pullUrls = <String>[
      'http://127.0.0.1:8090/index.php?action=pull',
      'http://192.168.1.133:8090/index.php?action=pull',
    ];
    final client = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 1200);
    try {
      for (final url in pullUrls) {
        try {
          final req = await client.getUrl(Uri.parse(url));
          final resp = await req.close();
          if (resp.statusCode == 200) {
            final body = await resp.transform(utf8.decoder).join();
            if (body.isNotEmpty) return body;
          }
        } catch (_) {
          // Try next endpoint
        }
      }
    } catch (_) {
      // Ignore offline pull errors
    } finally {
      client.close(force: true);
    }
    return null;
  }

  AgencyAppState _applyWorkspaceMap(
    AgencyAppState base,
    Map<String, dynamic> decoded,
    String founderId,
  ) {
    var restoredLeads = base.leads;
    var restoredFollowups = base.followups;
    var restoredClients = base.clients;
    var restoredProjects = base.projects;
    var restoredTasks = base.tasks;
    var restoredMeetings = base.meetings;
    var restoredProposals = base.proposals;
    var restoredInvoices = base.invoices;
    var restoredExpenses = base.expenses;
    var restoredNotifications = base.notifications;
    var restoredThreads = base.chatThreads;

    if (decoded['leads'] is List) {
      restoredLeads = (decoded['leads'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return LeadRecord(
          id: m['id'] as String,
          leadCode: m['leadCode'] as String,
          companyName: m['companyName'] as String,
          contactPerson: m['contactPerson'] as String,
          phone: m['phone'] as String,
          email: m['email'] as String,
          website: m['website'] as String,
          location: m['location'] as String,
          industry: m['industry'] as String,
          source: m['source'] as String,
          interestedService: m['interestedService'] as String,
          estimatedBudgetInr: (m['estimatedBudgetInr'] as num).toDouble(),
          assignedEmployeeName: m['assignedEmployeeName'] as String,
          priority: m['priority'] as String,
          status: m['status'] as String,
          expectedClosingDate:
              DateTime.parse(m['expectedClosingDate'] as String),
          createdDate: DateTime.parse(m['createdDate'] as String),
          nextFollowupAt: m['nextFollowupAt'] != null
              ? DateTime.parse(m['nextFollowupAt'] as String)
              : null,
          notes: m['notes'] as String,
        );
      }).toList();
    }

    if (decoded['followups'] is List) {
      restoredFollowups = (decoded['followups'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return LeadFollowupItem(
          id: m['id'] as String,
          leadId: m['leadId'] as String,
          companyName: m['companyName'] as String,
          assignedEmployee: m['assignedEmployee'] as String,
          followupType: m['followupType'] as String,
          scheduledAt: DateTime.parse(m['scheduledAt'] as String),
          notes: m['notes'] as String,
          isCompleted: m['isCompleted'] as bool? ?? false,
        );
      }).toList();
    }

    if (decoded['clients'] is List) {
      restoredClients = (decoded['clients'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return ClientRecord(
          id: m['id'] as String,
          clientCode: m['clientCode'] as String,
          companyName: m['companyName'] as String,
          contactPerson: m['contactPerson'] as String,
          email: m['email'] as String,
          phone: m['phone'] as String,
          website: m['website'] as String,
          address: m['address'] as String,
          industry: m['industry'] as String,
          servicesPurchased:
              List<String>.from(m['servicesPurchased'] as List),
          accountManager: m['accountManager'] as String,
          status: m['status'] as String,
          totalBilledInr: (m['totalBilledInr'] as num).toDouble(),
          outstandingInr: (m['outstandingInr'] as num).toDouble(),
          activeProjectsCount: m['activeProjectsCount'] as int,
          onboardedAt: DateTime.parse(m['onboardedAt'] as String),
          notes: m['notes'] as String,
        );
      }).toList();
    }

    if (decoded['projects'] is List) {
      restoredProjects = (decoded['projects'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return ProjectRecord(
          id: m['id'] as String,
          projectCode: m['projectCode'] as String,
          name: m['name'] as String,
          clientName: m['clientName'] as String,
          category: m['category'] as String,
          description: m['description'] as String,
          projectManager: m['projectManager'] as String,
          assignedTeam: List<String>.from(m['assignedTeam'] as List),
          startDate: DateTime.parse(m['startDate'] as String),
          deadline: DateTime.parse(m['deadline'] as String),
          budgetInr: (m['budgetInr'] as num).toDouble(),
          status: m['status'] as String,
          progressPercentage: m['progressPercentage'] as int,
        );
      }).toList();
    }

    if (decoded['tasks'] is List) {
      restoredTasks = (decoded['tasks'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return TaskItem(
          id: m['id'] as String,
          taskCode: m['taskCode'] as String,
          title: m['title'] as String,
          description: m['description'] as String,
          projectId: m['projectId'] as String,
          projectName: m['projectName'] as String,
          assignedEmployee: m['assignedEmployee'] as String,
          priority: m['priority'] as String,
          status: m['status'] as String,
          startDate: DateTime.parse(m['startDate'] as String),
          deadline: DateTime.parse(m['deadline'] as String),
        );
      }).toList();
    }

    if (decoded['meetings'] is List) {
      restoredMeetings = (decoded['meetings'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return MeetingRecord(
          id: m['id'] as String,
          meetingCode: m['meetingCode'] as String,
          title: m['title'] as String,
          clientOrCompany: m['clientOrCompany'] as String,
          description: m['description'] as String,
          startTime: DateTime.parse(m['startTime'] as String),
          endTime: DateTime.parse(m['endTime'] as String),
          meetingType: m['meetingType'] as String,
          location: m['location'] as String,
          onlineMeetingLink: m['onlineMeetingLink'] as String?,
          participants: List<String>.from(m['participants'] as List),
          assignedEmployee: m['assignedEmployee'] as String,
          notes: m['notes'] as String,
        );
      }).toList();
    }

    if (decoded['proposals'] is List) {
      restoredProposals = (decoded['proposals'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return ProposalRecord(
          id: m['id'] as String,
          proposalCode: m['proposalCode'] as String,
          clientOrLeadName: m['clientOrLeadName'] as String,
          title: m['title'] as String,
          serviceCategory: m['serviceCategory'] as String,
          subtotalInr: (m['subtotalInr'] as num).toDouble(),
          discountInr: (m['discountInr'] as num).toDouble(),
          gstAmountInr: (m['gstAmountInr'] as num).toDouble(),
          totalAmountInr: (m['totalAmountInr'] as num).toDouble(),
          validUntil: DateTime.parse(m['validUntil'] as String),
          status: m['status'] as String,
          preparedBy: m['preparedBy'] as String,
        );
      }).toList();
    }

    if (decoded['invoices'] is List) {
      restoredInvoices = (decoded['invoices'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return InvoiceRecord(
          id: m['id'] as String,
          invoiceNumber: m['invoiceNumber'] as String,
          clientName: m['clientName'] as String,
          projectName: m['projectName'] as String,
          serviceCategory: m['serviceCategory'] as String,
          issueDate: DateTime.parse(m['issueDate'] as String),
          dueDate: DateTime.parse(m['dueDate'] as String),
          totalAmountInr: (m['totalAmountInr'] as num).toDouble(),
          paidAmountInr: (m['paidAmountInr'] as num).toDouble(),
          status: m['status'] as String,
        );
      }).toList();
    }

    if (decoded['expenses'] is List) {
      restoredExpenses = (decoded['expenses'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return ExpenseRecord(
          id: m['id'] as String,
          expenseCode: m['expenseCode'] as String,
          category: m['category'] as String,
          vendorName: m['vendorName'] as String,
          description: m['description'] as String,
          amountInr: (m['amountInr'] as num).toDouble(),
          date: DateTime.parse(m['date'] as String),
        );
      }).toList();
    }

    if (decoded['notifications'] is List) {
      restoredNotifications = (decoded['notifications'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        return AppNotification(
          id: m['id'] as String,
          category: m['category'] as String,
          title: m['title'] as String,
          body: m['body'] as String,
          timestamp: DateTime.parse(m['timestamp'] as String),
          isRead: m['isRead'] as bool? ?? false,
          targetRoute: m['targetRoute'] as String?,
          entityId: m['entityId'] as String?,
          actions: m['actions'] is List
              ? List<String>.from(m['actions'] as List)
              : const [],
        );
      }).toList();
    }

    final unreadMap = decoded['chatThreadUnreads'] is Map
        ? Map<String, dynamic>.from(decoded['chatThreadUnreads'] as Map)
        : <String, dynamic>{};

    if (decoded['chatMessages'] is Map) {
      final msgMap = Map<String, dynamic>.from(decoded['chatMessages'] as Map);
      restoredThreads = base.chatThreads.map((t) {
        final rawMsgs = msgMap[t.id];
        final savedUnread = (unreadMap[t.id] as num?)?.toInt() ?? 0;
        if (rawMsgs is! List || rawMsgs.isEmpty) {
          return t.copyWith(
            unreadCount: savedUnread,
            messages: const [],
            lastMessagePreview: 'No messages yet',
          );
        }
        final msgs = rawMsgs.map((item) {
          final m = Map<String, dynamic>.from(item as Map);
          final rawReactions = m['reactions'];
          final parsedReactions = <String, int>{};
          if (rawReactions is Map) {
            rawReactions.forEach((k, v) {
              if (v is num) parsedReactions[k.toString()] = v.toInt();
            });
          }
          final senderId = m['senderId'] as String;
          return ChatMessage(
            id: m['id'] as String,
            threadId: m['threadId'] as String,
            senderId: senderId,
            senderName: m['senderName'] as String,
            senderRole: m['senderRole'] as String,
            body: m['body'] as String,
            timestamp: DateTime.parse(m['timestamp'] as String),
            isMe: senderId == founderId,
            messageType: m['messageType'] as String? ?? 'text',
            attachmentName: m['attachmentName'] as String?,
            attachmentSize: m['attachmentSize'] as String?,
            voiceDurationSec: (m['voiceDurationSec'] as num?)?.toInt(),
            replyToSender: m['replyToSender'] as String?,
            replyToPreview: m['replyToPreview'] as String?,
            reactions: parsedReactions,
            isPinned: m['isPinned'] as bool? ?? false,
          );
        }).toList();
        return t.copyWith(
          unreadCount: savedUnread,
          messages: msgs,
          lastMessagePreview: '${msgs.last.senderName}: ${msgs.last.body}',
          lastActivity: msgs.last.timestamp,
        );
      }).toList();
    }

    return base.copyWith(
      leads: restoredLeads,
      followups: restoredFollowups,
      clients: restoredClients,
      projects: restoredProjects,
      tasks: restoredTasks,
      meetings: restoredMeetings,
      proposals: restoredProposals,
      invoices: restoredInvoices,
      expenses: restoredExpenses,
      notifications: restoredNotifications,
      chatThreads: restoredThreads,
    );
  }

  /// Restores persisted Founder login session & workspace records on app launch,
  /// pulling live state from Cloud Firestore (`krypt-6a44c`) and XAMPP MySQL.
  Future<AgencyAppState> hydrateFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;
      final onboardingDone = prefs.getBool(_kOnboardingDone) ?? false;
      final activeFounderId =
          prefs.getString(_kActiveFounderId) ?? state.employees.first.id;
      final isDark = prefs.getBool(_kThemeIsDark) ?? true;

      final matchedFounder = state.employees.firstWhere(
        (e) => e.id == activeFounderId,
        orElse: () => state.employees.first,
      );

      Map<String, dynamic>? decodedMap;

      // 1. Try local persisted workspace cache first
      final rawJson = prefs.getString(_kWorkspaceJson);
      if (rawJson != null && rawJson.isNotEmpty) {
        decodedMap = jsonDecode(rawJson) as Map<String, dynamic>;
      }

      // 2. If Cloud Firestore (`krypt-6a44c`) is ready, pull the latest cloud snapshot
      if (_isFirebaseReady) {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('blue_hour_hq')
              .doc('workspace')
              .get();
          final data = snap.data();
          if (data != null && data['payload'] is Map) {
            decodedMap = Map<String, dynamic>.from(data['payload'] as Map);
          }
        } catch (_) {
          // Non-blocking fallback to SQL/local cache
        }
        _startRealtimeFirestoreListener();
      }

      // 3. Fallback to XAMPP MySQL if still empty
      if (decodedMap == null &&
          !Platform.environment.containsKey('FLUTTER_TEST')) {
        final sqlJson = await _pullFromLiveSqlBackend();
        if (sqlJson != null && sqlJson.isNotEmpty) {
          decodedMap = jsonDecode(sqlJson) as Map<String, dynamic>;
        }
      }

      var nextState = state.copyWith(
        isLoggedIn: isLoggedIn,
        hasCompletedOnboarding: onboardingDone,
        currentUser: matchedFounder,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      );

      if (decodedMap != null) {
        _lastSyncedJson = jsonEncode(decodedMap);
        nextState = _applyWorkspaceMap(nextState, decodedMap, matchedFounder.id);
      }

      super.state = nextState;
      if (isLoggedIn) {
        unawaited(
          BhNotificationService.instance.syncFounderDeviceToken(
            matchedFounder.id,
            matchedFounder.name,
          ),
        );
      }
      return nextState;
    } catch (_) {
      return state;
    }
  }

  void completeOnboarding() {
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  List<ChatThread> _recomputeThreadsForFounder(
      List<ChatThread> threads, String founderId) {
    return threads.map((t) {
      if (t.messages.isEmpty) return t;
      return t.copyWith(
        messages: t.messages
            .map((m) => m.copyWith(isMe: m.senderId == founderId))
            .toList(),
      );
    }).toList();
  }

  void loginAsFounder(String employeeId) {
    final matched = state.employees.firstWhere(
      (e) => e.id == employeeId,
      orElse: () => state.employees.first,
    );
    state = state.copyWith(
      isLoggedIn: true,
      hasCompletedOnboarding: true,
      currentUser: matched,
      chatThreads:
          _recomputeThreadsForFounder(state.chatThreads, matched.id),
    );
    unawaited(
      BhNotificationService.instance.syncFounderDeviceToken(
        matched.id,
        matched.name,
      ),
    );
  }

  void logout() {
    state = state.copyWith(isLoggedIn: false);
  }

  void toggleThemeMode() {
    state = state.copyWith(
      themeMode:
          state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void toggleOfflineSimulation() {
    final nextOffline = !state.isOfflineMode;
    state = state.copyWith(
      isOfflineMode: nextOffline,
      pendingOfflineActions: nextOffline ? state.pendingOfflineActions : 0,
    );
  }

  void setDashboardRange(String range) {
    state = state.copyWith(selectedDashboardRange: range);
  }

  void switchActiveFounder(String employeeId) {
    final matched = state.employees.firstWhere(
      (e) => e.id == employeeId,
      orElse: () => state.employees.first,
    );
    state = state.copyWith(
      currentUser: matched,
      chatThreads:
          _recomputeThreadsForFounder(state.chatThreads, matched.id),
    );
  }

  void switchActiveRole(UserRole role) {
    // Only Himon Bhuyan (emp-01) is permitted to hold Super Admin privileges
    if (!state.currentUser.isSuperAdmin && role == UserRole.superAdmin) {
      return;
    }
    state = state.copyWith(
      currentUser: state.currentUser.copyWith(role: role),
    );
  }

  void updateBriefingTime(String newTime) {
    state = state.copyWith(
      currentUser: state.currentUser.copyWith(briefingTime: newTime),
    );
  }

  void toggleTwoFactor(bool enabled) {
    state = state.copyWith(
      currentUser: state.currentUser.copyWith(twoFactorEnabled: enabled),
    );
  }

  void createLead({
    required String companyName,
    required String contactPerson,
    required String phone,
    required String email,
    required String source,
    required String interestedService,
    required double budgetInr,
    required String priority,
    required String assignedEmployee,
    required String location,
    required String industry,
    required String notes,
  }) {
    final now = DateTime.now();
    final nextNumber = 1001 + state.leads.length;
    final newLead = LeadRecord(
      id: 'lead-${now.millisecondsSinceEpoch}',
      leadCode: 'BH-LD-$nextNumber',
      companyName: companyName,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      website: 'https://${companyName.toLowerCase().replaceAll(' ', '')}.in',
      location: location.isEmpty ? 'Guwahati, Assam' : location,
      industry: industry.isEmpty ? 'Technology & Digital' : industry,
      source: source,
      interestedService: interestedService,
      estimatedBudgetInr: budgetInr,
      assignedEmployeeName: assignedEmployee,
      priority: priority,
      status: 'New Lead',
      expectedClosingDate: now.add(const Duration(days: 14)),
      createdDate: now,
      nextFollowupAt: now.add(const Duration(days: 1)),
      notes: notes,
      timeline: [
        LeadActivityItem(
          id: 'act-${now.millisecondsSinceEpoch}',
          type: 'status',
          title: 'Lead Created & Assigned to $assignedEmployee',
          description:
              'Captured via $source for $interestedService (${BhFormatters.inr(budgetInr)}).',
          actorName: state.currentUser.name,
          timestamp: now,
        ),
      ],
    );

    final newNotif = AppNotification(
      id: 'notif-${now.millisecondsSinceEpoch}',
      category: 'Leads',
      title: 'New Lead Added: $companyName',
      body:
          '$interestedService • Est. Budget ${BhFormatters.inr(budgetInr)} • Assigned to $assignedEmployee',
      timestamp: now,
      targetRoute: '/leads/${newLead.id}',
      entityId: newLead.id,
      actions: const ['View Lead'],
    );

    state = state.copyWith(
      leads: [newLead, ...state.leads],
      notifications: [newNotif, ...state.notifications],
      pendingOfflineActions:
          state.isOfflineMode ? state.pendingOfflineActions + 1 : 0,
    );
    unawaited(
      BhNotificationService.instance.dispatchRemoteFcmPush(
        title: newNotif.title,
        body: newNotif.body,
        senderId: state.currentUser.id,
        category: 'Leads',
        targetRoute: newNotif.targetRoute ?? '/leads',
      ),
    );
  }

  void updateLeadStatus(String leadId, String newStatus, {String? lostReason}) {
    final now = DateTime.now();
    LeadRecord? convertedLead;

    final updatedLeads = state.leads.map((lead) {
      if (lead.id != leadId) return lead;
      final activity = LeadActivityItem(
        id: 'act-${now.millisecondsSinceEpoch}',
        type: 'status',
        title: 'Pipeline Stage Updated → $newStatus',
        description: lostReason != null && lostReason.isNotEmpty
            ? 'Reason: $lostReason'
            : 'Updated by ${state.currentUser.name}',
        actorName: state.currentUser.name,
        timestamp: now,
      );
      final updated = lead.copyWith(
        status: newStatus,
        lostReason: lostReason,
        timeline: [activity, ...lead.timeline],
      );
      if (newStatus == 'Converted') {
        convertedLead = updated;
      }
      return updated;
    }).toList();

    var updatedClients = state.clients;
    if (convertedLead != null &&
        !state.clients
            .any((c) => c.companyName == convertedLead!.companyName)) {
      final newClient = ClientRecord(
        id: 'cli-${now.millisecondsSinceEpoch}',
        clientCode: 'BH-CL-${101 + state.clients.length}',
        companyName: convertedLead!.companyName,
        contactPerson: convertedLead!.contactPerson,
        email: convertedLead!.email,
        phone: convertedLead!.phone,
        website: convertedLead!.website,
        address: convertedLead!.location,
        industry: convertedLead!.industry,
        servicesPurchased: [convertedLead!.interestedService],
        accountManager: convertedLead!.assignedEmployeeName,
        status: 'Active',
        totalBilledInr: convertedLead!.estimatedBudgetInr,
        outstandingInr: convertedLead!.estimatedBudgetInr * 0.5,
        activeProjectsCount: 1,
        onboardedAt: now,
        notes:
            'Automatically created from converted lead ${convertedLead!.leadCode}.',
      );
      updatedClients = [newClient, ...state.clients];
    }

    state = state.copyWith(
      leads: updatedLeads,
      clients: updatedClients,
    );
  }

  void createClient({
    required String companyName,
    required String contactPerson,
    required String email,
    required String phone,
    required String address,
    required String industry,
    required String service,
    required String accountManager,
    required double contractValueInr,
  }) {
    final now = DateTime.now();
    final newClient = ClientRecord(
      id: 'cli-${now.millisecondsSinceEpoch}',
      clientCode: 'BH-CL-${101 + state.clients.length}',
      companyName: companyName,
      contactPerson: contactPerson,
      email: email,
      phone: phone,
      website: 'https://${companyName.toLowerCase().replaceAll(' ', '')}.in',
      address: address,
      industry: industry,
      servicesPurchased: [service],
      accountManager: accountManager,
      status: 'Active',
      totalBilledInr: contractValueInr,
      outstandingInr: 0,
      activeProjectsCount: 1,
      onboardedAt: now,
      notes: 'Onboarded by ${state.currentUser.name}.',
    );
    state = state.copyWith(clients: [newClient, ...state.clients]);
  }

  void addLeadNote(String leadId, String noteText,
      {String type = 'note', String? customTitle}) {
    final now = DateTime.now();
    final updatedLeads = state.leads.map((lead) {
      if (lead.id != leadId) return lead;
      final item = LeadActivityItem(
        id: 'act-${now.millisecondsSinceEpoch}',
        type: type,
        title: customTitle ?? 'Founder Note Added',
        description: noteText,
        actorName: state.currentUser.name,
        timestamp: now,
      );
      return lead.copyWith(
        notes: noteText,
        timeline: [item, ...lead.timeline],
      );
    }).toList();
    state = state.copyWith(leads: updatedLeads);
  }

  void scheduleLeadFollowup({
    required String leadId,
    required String companyName,
    required String followupType,
    required DateTime scheduledAt,
    required String notes,
  }) {
    final now = DateTime.now();
    final fu = LeadFollowupItem(
      id: 'fu-${now.millisecondsSinceEpoch}',
      leadId: leadId,
      companyName: companyName,
      assignedEmployee: state.currentUser.name,
      followupType: followupType,
      scheduledAt: scheduledAt,
      notes: notes,
    );

    final updatedLeads = state.leads.map((l) {
      if (l.id != leadId) return l;
      final item = LeadActivityItem(
        id: 'act-${now.millisecondsSinceEpoch}',
        type: 'call',
        title: 'Scheduled $followupType Follow-up',
        description: '${BhFormatters.dateTimeShort(scheduledAt)} — $notes',
        actorName: state.currentUser.name,
        timestamp: now,
      );
      return l.copyWith(
        nextFollowupAt: scheduledAt,
        timeline: [item, ...l.timeline],
      );
    }).toList();

    final newNotif = AppNotification(
      id: 'notif-${now.millisecondsSinceEpoch}',
      category: 'Leads',
      title: 'Lead Follow-up Scheduled',
      body:
          '$followupType with $companyName scheduled for ${BhFormatters.dateTimeShort(scheduledAt)}.',
      timestamp: now,
      targetRoute: '/leads/$leadId',
      entityId: leadId,
      actions: const ['View Lead', 'Mark Completed'],
    );

    state = state.copyWith(
      followups: [fu, ...state.followups],
      leads: updatedLeads,
      notifications: [newNotif, ...state.notifications],
    );
    if (state.notificationPrefs.leadReminders) {
      unawaited(
        BhNotificationService.instance.scheduleReminderSequence(
          entityId: fu.id,
          title: 'Follow-up: $companyName',
          subtitle: '$followupType • $notes',
          targetTime: scheduledAt,
          category: 'Leads',
          targetRoute: '/leads/$leadId',
        ),
      );
    }
  }

  void toggleFollowupCompleted(String followupId) {
    final updated = state.followups.map((f) {
      if (f.id != followupId) return f;
      return f.copyWith(isCompleted: !f.isCompleted);
    }).toList();
    state = state.copyWith(followups: updated);
  }

  String? _dmThreadIdForFounderId(String founderId) {
    switch (founderId) {
      case 'emp-01':
        return 'dm-himon';
      case 'emp-02':
        return 'dm-darshana';
      case 'emp-03':
        return 'dm-drishant';
      default:
        return null;
    }
  }

  void sendChatMessage({
    required String threadId,
    required String body,
    String messageType = 'text',
    String? attachmentName,
    int? voiceDurationSec,
    String? replyToSender,
    String? replyToPreview,
  }) {
    final now = DateTime.now();
    final msgId = 'msg-${now.microsecondsSinceEpoch}';
    final previewLabel = messageType == 'voice'
        ? '🎙️ Voice Note (${voiceDurationSec ?? 8}s)'
        : (attachmentName != null && body.isEmpty
            ? '📎 $attachmentName'
            : body);

    final newMsg = ChatMessage(
      id: msgId,
      threadId: threadId,
      senderId: state.currentUser.id,
      senderName: state.currentUser.name,
      senderRole: state.currentUser.designation,
      body: body,
      timestamp: now,
      isMe: true,
      messageType: messageType,
      attachmentName: attachmentName,
      attachmentSize: attachmentName != null ? '2.1 MB' : null,
      voiceDurationSec: voiceDurationSec,
      replyToSender: replyToSender,
      replyToPreview: replyToPreview,
    );

    final targetThread = state.chatThreads.firstWhere(
      (t) => t.id == threadId,
      orElse: () => state.chatThreads.first,
    );

    // If this is a 1-on-1 Founder DM, also sync the message into the sender's reciprocal DM thread
    // so when the recipient Founder switches profile and opens their DM with the sender, the message is there.
    final reciprocalDmId = !targetThread.isChannel
        ? _dmThreadIdForFounderId(state.currentUser.id)
        : null;

    final updatedThreads = state.chatThreads.map((t) {
      if (t.id == threadId) {
        return t.copyWith(
          unreadCount: 0,
          lastMessagePreview: '${state.currentUser.name}: $previewLabel',
          lastActivity: now,
          messages: [...t.messages, newMsg],
        );
      }
      if (reciprocalDmId != null &&
          t.id == reciprocalDmId &&
          t.id != threadId) {
        final mirroredMsg = newMsg.copyWith(threadId: reciprocalDmId);
        return t.copyWith(
          unreadCount: t.unreadCount + 1,
          lastMessagePreview: '${state.currentUser.name}: $previewLabel',
          lastActivity: now,
          messages: [...t.messages, mirroredMsg],
        );
      }
      return t;
    }).toList();

    var nextNotifications = state.notifications;
    if (state.notificationPrefs.chatNotifications) {
      final chatNotif = AppNotification(
        id: 'notif-msg-${now.microsecondsSinceEpoch}',
        category: 'Messages',
        title: targetThread.isChannel
            ? 'New Message in ${targetThread.name}'
            : 'Direct Message to ${targetThread.name}',
        body: '${state.currentUser.name}: $previewLabel',
        timestamp: now,
        targetRoute: '/chat',
        entityId: threadId,
        actions: const ['Open Chat'],
      );
      nextNotifications = [chatNotif, ...state.notifications];
    }

    state = state.copyWith(
      chatThreads: updatedThreads,
      notifications: nextNotifications,
      pendingOfflineActions:
          state.isOfflineMode ? state.pendingOfflineActions + 1 : 0,
    );

    if (state.notificationPrefs.chatNotifications && !state.isOfflineMode) {
      List<String>? dmRecipients;
      if (!targetThread.isChannel) {
        if (threadId == 'dm-himon') dmRecipients = const ['emp-01'];
        if (threadId == 'dm-darshana') dmRecipients = const ['emp-02'];
        if (threadId == 'dm-drishant') dmRecipients = const ['emp-03'];
      }
      unawaited(
        BhNotificationService.instance.dispatchRemoteFcmPush(
          title: targetThread.isChannel
              ? 'Founders Board • ${state.currentUser.name}'
              : 'Direct Message from ${state.currentUser.name}',
          body: previewLabel,
          senderId: state.currentUser.id,
          category: 'Messages',
          targetRoute: '/chat',
          targetFounderIds: dmRecipients,
        ),
      );
    }
  }

  void markThreadRead(String threadId) {
    final updatedThreads = state.chatThreads.map((t) {
      if (t.id != threadId) return t;
      return t.copyWith(unreadCount: 0);
    }).toList();
    state = state.copyWith(chatThreads: updatedThreads);
  }

  void toggleMessageReaction(String threadId, String messageId, String emoji) {
    final updatedThreads = state.chatThreads.map((t) {
      final hasMessage = t.messages.any((m) => m.id == messageId);
      if (!hasMessage && t.id != threadId) return t;
      final updatedMessages = t.messages.map((m) {
        if (m.id != messageId) return m;
        final nextReactions = Map<String, int>.from(m.reactions);
        if (nextReactions.containsKey(emoji)) {
          nextReactions.remove(emoji);
        } else {
          nextReactions[emoji] = 1;
        }
        return m.copyWith(reactions: nextReactions);
      }).toList();
      return t.copyWith(messages: updatedMessages);
    }).toList();
    state = state.copyWith(chatThreads: updatedThreads);
  }

  void togglePinMessage(String threadId, String messageId) {
    final updatedThreads = state.chatThreads.map((t) {
      final hasMessage = t.messages.any((m) => m.id == messageId);
      if (!hasMessage && t.id != threadId) return t;
      final updatedMessages = t.messages.map((m) {
        if (m.id != messageId) return m;
        return m.copyWith(isPinned: !m.isPinned);
      }).toList();
      return t.copyWith(messages: updatedMessages);
    }).toList();
    state = state.copyWith(chatThreads: updatedThreads);
  }

  void deleteChatMessage(String threadId, String messageId) {
    final updatedThreads = state.chatThreads.map((t) {
      final hasMessage = t.messages.any((m) => m.id == messageId);
      if (!hasMessage && t.id != threadId) return t;
      final remaining = t.messages.where((m) => m.id != messageId).toList();
      return t.copyWith(
        messages: remaining,
        lastMessagePreview: remaining.isEmpty
            ? 'No messages yet'
            : '${remaining.last.senderName}: ${remaining.last.body}',
      );
    }).toList();
    state = state.copyWith(chatThreads: updatedThreads);
  }

  void createChannel({
    required String name,
    required String subtitle,
    required bool isPrivate,
  }) {
    final now = DateTime.now();
    final newChannel = ChatThread(
      id: 'ch-${now.millisecondsSinceEpoch}',
      name: name,
      subtitle: subtitle,
      isChannel: true,
      isPrivate: isPrivate,
      membersCount: state.employees.length,
      lastMessagePreview: 'No messages yet',
      lastActivity: now,
      messages: const [],
    );
    state = state.copyWith(chatThreads: [newChannel, ...state.chatThreads]);
  }

  void clearThreadMessages(String threadId) {
    final updatedThreads = state.chatThreads.map((t) {
      if (t.id != threadId) return t;
      return t.copyWith(
        unreadCount: 0,
        lastMessagePreview: 'No messages yet',
        messages: const [],
      );
    }).toList();
    state = state.copyWith(chatThreads: updatedThreads);
  }

  void createProject({
    required String name,
    required String clientName,
    required String category,
    required String description,
    required String projectManager,
    required double budgetInr,
    required DateTime deadline,
  }) {
    final now = DateTime.now();
    final newProj = ProjectRecord(
      id: 'proj-${now.millisecondsSinceEpoch}',
      projectCode: 'BH-PRJ-${101 + state.projects.length}',
      name: name,
      clientName: clientName,
      category: category,
      description: description,
      projectManager: projectManager,
      assignedTeam: [projectManager, state.currentUser.name],
      startDate: now,
      deadline: deadline,
      budgetInr: budgetInr,
      status: 'In Progress',
      progressPercentage: 0,
    );
    state = state.copyWith(projects: [newProj, ...state.projects]);
  }

  void updateProjectProgress(String projectId, int newProgress, String status) {
    final updated = state.projects.map((p) {
      if (p.id != projectId) return p;
      return p.copyWith(progressPercentage: newProgress, status: status);
    }).toList();
    state = state.copyWith(projects: updated);
  }

  void createTask({
    required String title,
    required String description,
    required String projectId,
    required String projectName,
    required String assignedEmployee,
    required String priority,
    required DateTime deadline,
  }) {
    final now = DateTime.now();
    final task = TaskItem(
      id: 'tsk-${now.millisecondsSinceEpoch}',
      taskCode: 'BH-TSK-${101 + state.tasks.length}',
      title: title,
      description: description,
      projectId: projectId,
      projectName: projectName,
      assignedEmployee: assignedEmployee,
      priority: priority,
      status: 'To Do',
      startDate: now,
      deadline: deadline,
    );
    state = state.copyWith(tasks: [task, ...state.tasks]);
  }

  void updateTaskStatus(String taskId, String newStatus) {
    final updated = state.tasks.map((t) {
      if (t.id != taskId) return t;
      return t.copyWith(status: newStatus);
    }).toList();
    state = state.copyWith(tasks: updated);
  }

  void scheduleMeeting({
    required String title,
    required String clientOrCompany,
    required String meetingType,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    String? onlineLink,
    required List<String> participants,
    required String notes,
  }) {
    final now = DateTime.now();
    final mtg = MeetingRecord(
      id: 'mtg-${now.millisecondsSinceEpoch}',
      meetingCode: 'BH-MTG-${101 + state.meetings.length}',
      title: title,
      clientOrCompany: clientOrCompany,
      description: notes,
      startTime: startTime,
      endTime: endTime,
      meetingType: meetingType,
      location: location,
      onlineMeetingLink: onlineLink,
      participants: participants,
      assignedEmployee: state.currentUser.name,
      notes: notes,
    );

    final notif = AppNotification(
      id: 'notif-${now.millisecondsSinceEpoch}',
      category: 'Meetings',
      title: 'Meeting Scheduled: $title',
      body:
          '$clientOrCompany • ${BhFormatters.dateTimeShort(startTime)} (Reminders: 1d, 1h, 15m)',
      timestamp: now,
      targetRoute: '/calendar',
      entityId: mtg.id,
      actions: [
        'View Meeting',
        if (onlineLink != null && onlineLink.isNotEmpty) 'Join Meeting',
      ],
    );

    state = state.copyWith(
      meetings: [mtg, ...state.meetings],
      notifications: [notif, ...state.notifications],
    );
    if (state.notificationPrefs.meetingReminders) {
      unawaited(
        BhNotificationService.instance.scheduleReminderSequence(
          entityId: mtg.id,
          title: 'Meeting: $title',
          subtitle: '$clientOrCompany • $location',
          targetTime: startTime,
          category: 'Meetings',
          targetRoute: '/calendar',
        ),
      );
      unawaited(
        BhNotificationService.instance.dispatchRemoteFcmPush(
          title: notif.title,
          body: notif.body,
          senderId: state.currentUser.id,
          category: 'Meetings',
          targetRoute: '/calendar',
        ),
      );
    }
  }

  Future<void> triggerTestPushNotification() async {
    final now = DateTime.now();
    final testNotif = AppNotification(
      id: 'notif-test-${now.microsecondsSinceEpoch}',
      category: 'Announcements',
      title: 'Blue Hour HQ • Live Push Active',
      body:
          'System notifications, scheduled reminders, and real-time Founders chat alerts are working smoothly.',
      timestamp: now,
      targetRoute: '/notifications',
      actions: const ['View Centre'],
    );
    state = state.copyWith(
      notifications: [testNotif, ...state.notifications],
    );
    await BhNotificationService.instance.showLocalNotification(
      id: now.millisecondsSinceEpoch & 0x7FFFFFFF,
      title: testNotif.title,
      body: testNotif.body,
      category: 'Announcements',
      targetRoute: '/notifications',
    );
    unawaited(
      BhNotificationService.instance.dispatchRemoteFcmPush(
        title: testNotif.title,
        body: testNotif.body,
        senderId: state.currentUser.id,
        category: 'Announcements',
        targetRoute: '/notifications',
        includeAllFounders: true,
      ),
    );
  }

  void markNotificationRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id != id) return n;
      return n.copyWith(isRead: true);
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllNotificationsRead() {
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void updateNotificationPreferences(NotificationPreferencesState prefs) {
    state = state.copyWith(notificationPrefs: prefs);
  }

  void createProposal({
    required String clientOrLeadName,
    required String title,
    required String serviceCategory,
    required double subtotalInr,
    required double discountInr,
  }) {
    final taxable = (subtotalInr - discountInr).clamp(0.0, double.infinity);
    final gst = taxable * 0.18;
    final total = taxable + gst;
    final now = DateTime.now();
    final prop = ProposalRecord(
      id: 'prop-${now.millisecondsSinceEpoch}',
      proposalCode: 'BH-PRP-${101 + state.proposals.length}',
      clientOrLeadName: clientOrLeadName,
      title: title,
      serviceCategory: serviceCategory,
      subtotalInr: subtotalInr,
      discountInr: discountInr,
      gstAmountInr: gst,
      totalAmountInr: total,
      validUntil: now.add(const Duration(days: 14)),
      status: 'Sent',
      preparedBy: state.currentUser.name,
    );
    state = state.copyWith(proposals: [prop, ...state.proposals]);
  }

  void createInvoice({
    required String clientName,
    required String projectName,
    required String serviceCategory,
    required double totalAmountInr,
    required double paidAmountInr,
  }) {
    final now = DateTime.now();
    final inv = InvoiceRecord(
      id: 'inv-${now.millisecondsSinceEpoch}',
      invoiceNumber: 'BH-INV-${101 + state.invoices.length}',
      clientName: clientName,
      projectName: projectName,
      serviceCategory: serviceCategory,
      issueDate: now,
      dueDate: now.add(const Duration(days: 14)),
      totalAmountInr: totalAmountInr,
      paidAmountInr: paidAmountInr,
      status: paidAmountInr >= totalAmountInr
          ? 'Paid'
          : (paidAmountInr > 0 ? 'Partially Paid' : 'Sent'),
    );
    state = state.copyWith(invoices: [inv, ...state.invoices]);
  }

  void recordInvoicePayment(String invoiceId) {
    final updated = state.invoices.map((inv) {
      if (inv.id != invoiceId) return inv;
      return inv.copyWith(
        paidAmountInr: inv.totalAmountInr,
        status: 'Paid',
      );
    }).toList();
    state = state.copyWith(invoices: updated);
  }

  void createExpense({
    required String category,
    required String vendorName,
    required String description,
    required double amountInr,
  }) {
    final now = DateTime.now();
    final exp = ExpenseRecord(
      id: 'exp-${now.millisecondsSinceEpoch}',
      expenseCode: 'BH-EXP-${101 + state.expenses.length}',
      category: category,
      vendorName: vendorName,
      description: description,
      amountInr: amountInr,
      date: now,
    );
    state = state.copyWith(expenses: [exp, ...state.expenses]);
  }

  /// Dynamic AI Business Assistant response generator using live agency state.
  String generateAiAssistantResponse(String query) {
    final q = query.toLowerCase();
    final now = DateTime.now();

    if (q.contains('seven days') ||
        q.contains('7 days') ||
        q.contains('follow-up') ||
        q.contains('followup')) {
      final staleLeads = state.leads.where((l) {
        if (l.status == 'Converted' || l.status == 'Lost') return false;
        if (l.nextFollowupAt == null) return true;
        return l.nextFollowupAt!
            .isBefore(now.subtract(const Duration(days: 7)));
      }).toList();

      if (staleLeads.isEmpty) {
        return 'No overdue leads (>7 days without follow-up) found in your pipeline.';
      }
      final lines = staleLeads
          .map((l) =>
              '• **${l.companyName}** (${l.leadCode}) — Budget: ${BhFormatters.inr(l.estimatedBudgetInr)} • Lead Partner: ${l.assignedEmployeeName}')
          .join('\n');
      return 'Found **${staleLeads.length} active leads** requiring follow-up:\n\n$lines';
    }

    if (q.contains('employee') ||
        q.contains('founder') ||
        q.contains('converted the most')) {
      return 'Blue Hour Creative Studios is led by its 3 Founders:\n'
          '• **Himon Bhuyan** — Founder & Principal Software Architect\n'
          '• **Darshana Das** — Partner — Head of Client Growth & Social Media Strategy\n'
          '• **Drishant Das** — Co-Founder — Principal Hardware & IoT Architect\n\n'
          'Converted leads in pipeline: **${state.convertedLeadsCount}** of **${state.leads.length}** total leads.';
    }

    if (q.contains('website') || q.contains('projects') || q.contains('iot')) {
      if (state.projects.isEmpty) {
        return 'Your studio project board is currently clean (0 active projects). Tap **New Project** in the Projects tab to launch a client sprint.';
      }
      final listText = state.projects
          .map((p) =>
              '• **${p.name}** (${p.clientName}) — ${p.progressPercentage}% complete • Lead: ${p.projectManager}')
          .join('\n');
      return 'You have **${state.projects.length} active studio projects**:\n\n$listText';
    }

    if (q.contains('payment') ||
        q.contains('pending') ||
        q.contains('overdue') ||
        q.contains('revenue')) {
      final unpaid = state.invoices.where((i) => i.balanceDueInr > 0).toList();
      if (unpaid.isEmpty) {
        return 'Collected revenue: **${BhFormatters.inr(state.monthlyRevenueInr)}** • Outstanding receivables: **₹0**.';
      }
      final lines = unpaid
          .map((i) =>
              '• **${i.clientName}** (${i.invoiceNumber}) — Balance Due: **${BhFormatters.inr(i.balanceDueInr)}** (${i.status})')
          .join('\n');
      return 'Total collected revenue is **${BhFormatters.inr(state.monthlyRevenueInr)}** with **${BhFormatters.inr(state.outstandingPaymentsInr)}** in pending payments:\n\n$lines';
    }

    return '**Blue Hour Creative Studios — Live Workspace Status:**\n'
        '• **Founders:** Himon Bhuyan (Software & AI), Darshana Das (Client Growth & Social), Drishant Das (Hardware & IoT)\n'
        '• **CRM Pipeline:** ${state.leads.length} leads (${state.convertedLeadsCount} converted)\n'
        '• **Active Projects:** ${state.projects.length} projects • ${state.tasks.length} tasks\n'
        '• **Meetings Scheduled:** ${state.meetings.length}\n'
        '• **Finance Ledger:** ${BhFormatters.inr(state.monthlyRevenueInr)} collected • ${BhFormatters.inr(state.outstandingPaymentsInr)} receivables.';
  }
}

final agencyStoreProvider =
    NotifierProvider<AgencyStoreNotifier, AgencyAppState>(
  AgencyStoreNotifier.new,
);
