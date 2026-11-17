import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue_hour_hq/main.dart';
import 'package:blue_hour_hq/core/theme/app_theme.dart';
import 'package:blue_hour_hq/data/models/agency_models.dart';
import 'package:blue_hour_hq/data/repositories/agency_store.dart';
import 'package:blue_hour_hq/features/chat/chat_screen.dart';
import 'package:blue_hour_hq/features/calendar/meeting_calendar_screen.dart';
import 'package:blue_hour_hq/features/notifications/notification_centre_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('1. Splash Screen renders official Blue Hour brand identity & orbital animation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BlueHourHqApp(),
      ),
    );

    expect(
      find.textContaining('BLUE HOUR', findRichText: true),
      findsWidgets,
    );
    expect(find.text('CREATIVE STUDIOS'), findsOneWidget);
    expect(find.text('SOFTWARE & AI'), findsOneWidget);
    expect(find.text('GROWTH & SOCIAL'), findsOneWidget);
    expect(find.text('HARDWARE & IOT'), findsOneWidget);
    expect(find.text('FOUNDERS COMMAND OS'), findsOneWidget);
  });

  test('2. Initial workspace has strictly the 3 Founders and zero dummy data', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(agencyStoreProvider);

    // Strictly 3 Founders
    expect(state.employees.length, 3);
    expect(
      state.employees.map((e) => e.name).toList(),
      ['Himon Bhuyan', 'Darshana Das', 'Drishant Das'],
    );

    // Strictly Himon Bhuyan holds Super Admin privileges; Darshana & Drishant do not
    expect(state.employees[0].isSuperAdmin, isTrue);
    expect(state.employees[0].role, UserRole.superAdmin);
    expect(state.employees[0].accessBadgeLabel, 'SUPER ADMIN');

    expect(state.employees[1].isSuperAdmin, isFalse);
    expect(state.employees[1].role, UserRole.founder);
    expect(state.employees[1].accessBadgeLabel, 'PARTNER');

    expect(state.employees[2].isSuperAdmin, isFalse);
    expect(state.employees[2].role, UserRole.founder);
    expect(state.employees[2].accessBadgeLabel, 'CO-FOUNDER');

    // Verify Darshana cannot elevate herself to Super Admin
    final notifier = container.read(agencyStoreProvider.notifier);
    notifier.switchActiveFounder('emp-02');
    notifier.switchActiveRole(UserRole.superAdmin);
    expect(
      container.read(agencyStoreProvider).currentUser.role,
      UserRole.founder,
    );

    // Zero dummy data across all modules
    expect(state.leads, isEmpty);
    expect(state.followups, isEmpty);
    expect(state.clients, isEmpty);
    expect(state.projects, isEmpty);
    expect(state.tasks, isEmpty);
    expect(state.meetings, isEmpty);
    expect(state.proposals, isEmpty);
    expect(state.invoices, isEmpty);
    expect(state.expenses, isEmpty);
    expect(state.notifications, isEmpty);

    // Strictly Founders-only chat threads (Founders Board + 3 Founder DMs) with zero dummy messages
    expect(
      state.chatThreads.map((t) => t.id).toList(),
      ['founders-hq', 'dm-darshana', 'dm-drishant', 'dm-himon'],
    );
    for (final thread in state.chatThreads) {
      expect(thread.messages, isEmpty);
      expect(thread.lastMessagePreview, 'No messages yet');
    }
  });

  test(
      '3. Multi-Founder Messaging: Founders Board group chat, bidirectional 1-on-1 DMs, Voice Notes, Attachments, Reactions, Pins & Delete',
      () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);

    // Active Founder defaults to Himon Bhuyan (emp-01)
    expect(container.read(agencyStoreProvider).currentUser.name, 'Himon Bhuyan');

    // A. Himon sends a message in Founders Board ('founders-hq')
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: 'Shipping v2 cloud sync architecture today.',
    );

    var board = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq');
    expect(board.messages.length, 1);
    expect(board.messages.first.senderName, 'Himon Bhuyan');
    expect(board.messages.first.isMe, isTrue);

    // Notification generated for Messages
    expect(
      container
          .read(agencyStoreProvider)
          .notifications
          .any((n) => n.category == 'Messages'),
      isTrue,
    );

    // B. Switch active Founder to Darshana Das (emp-02)
    notifier.switchActiveFounder('emp-02');
    expect(container.read(agencyStoreProvider).currentUser.name, 'Darshana Das');

    board = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq');
    // Himon's message is now isMe == false from Darshana's perspective
    expect(board.messages.first.isMe, isFalse);

    // Darshana replies in Founders Board
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: 'Client growth campaign deck is ready for review.',
      replyToSender: 'Himon Bhuyan',
      replyToPreview: 'Shipping v2 cloud sync architecture today.',
    );

    board = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq');
    expect(board.messages.length, 2);
    expect(board.messages.last.senderName, 'Darshana Das');
    expect(board.messages.last.isMe, isTrue);
    expect(board.messages.last.replyToSender, 'Himon Bhuyan');

    // C. Switch to Drishant Das (emp-03) and send a Voice Note + Document Attachment
    notifier.switchActiveFounder('emp-03');
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: 'IoT sensor telemetry firmware benchmark',
      messageType: 'voice',
      voiceDurationSec: 15,
    );
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: 'Attached PCB schematic',
      messageType: 'document',
      attachmentName: 'BH_IoT_Node_v3_Schematic.pdf',
    );

    board = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq');
    expect(board.messages.length, 4);
    expect(board.messages[2].messageType, 'voice');
    expect(board.messages[2].voiceDurationSec, 15);
    expect(board.messages[3].attachmentName, 'BH_IoT_Node_v3_Schematic.pdf');

    // D. Reactions & Pinning on Founders Board message
    final firstMsgId = board.messages.first.id;
    notifier.toggleMessageReaction('founders-hq', firstMsgId, '🔥');
    board = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq');
    expect(board.messages.first.reactions['🔥'], 1);

    // Toggling the same reaction again removes it cleanly
    notifier.toggleMessageReaction('founders-hq', firstMsgId, '🔥');
    board = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq');
    expect(board.messages.first.reactions.containsKey('🔥'), isFalse);

    // Pin and unpin message
    notifier.togglePinMessage('founders-hq', firstMsgId);
    board = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq');
    expect(board.messages.first.isPinned, isTrue);

    // E. Bidirectional 1-on-1 Direct Message sync between Himon and Darshana
    notifier.switchActiveFounder('emp-01'); // Himon
    notifier.sendChatMessage(
      threadId: 'dm-darshana',
      body: 'Hey Darshana, let us sync on the Assam Tourism pitch at 4 PM.',
    );

    // Check dm-darshana (Himon's view) AND dm-himon (Darshana's view)
    final dmDarshana = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'dm-darshana');
    final dmHimon = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'dm-himon');

    expect(dmDarshana.messages.length, 1);
    expect(dmHimon.messages.length, 1);
    expect(dmHimon.unreadCount, 1);
    expect(
      dmHimon.messages.first.body,
      'Hey Darshana, let us sync on the Assam Tourism pitch at 4 PM.',
    );

    // Mark read & delete message
    notifier.markThreadRead('dm-himon');
    expect(
      container
          .read(agencyStoreProvider)
          .chatThreads
          .firstWhere((t) => t.id == 'dm-himon')
          .unreadCount,
      0,
    );

    notifier.deleteChatMessage('dm-darshana', dmDarshana.messages.first.id);
    expect(
      container
          .read(agencyStoreProvider)
          .chatThreads
          .firstWhere((t) => t.id == 'dm-darshana')
          .messages,
      isEmpty,
    );
    expect(
      container
          .read(agencyStoreProvider)
          .chatThreads
          .firstWhere((t) => t.id == 'dm-himon')
          .messages,
      isEmpty,
    );
  });

  testWidgets(
      '4. Chat UI Widget Test: ChatListScreen & ChatRoomScreen interactive messaging in Light & Dark themes',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const ChatListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Founders Board and the other 2 Founders are shown
    expect(find.text('Founders Direct Chat'), findsOneWidget);
    expect(find.text('Founders Board'), findsOneWidget);
    expect(find.text('Darshana Das'), findsOneWidget);
    expect(find.text('Drishant Das'), findsOneWidget);

    // Tap on Founders Board to open ChatRoomScreen
    await tester.tap(find.text('Founders Board'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No messages yet'), findsOneWidget);

    // Type and send a message as Himon Bhuyan
    await tester.enterText(
      find.byType(TextField),
      'Hello Co-Founders, testing real-time board chat!',
    );
    await tester.pump();
    await tester.tap(find.byTooltip('Send Message'));
    await tester.pumpAndSettle();

    expect(
      find.text('Hello Co-Founders, testing real-time board chat!'),
      findsOneWidget,
    );
    expect(find.text('Himon Bhuyan'), findsWidgets);
  });

  test(
      '5. CRM Leads, Client Conversion, Projects, Tasks, Meetings, GST Invoices & Persistent Storage Hydration',
      () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();

    final notifier = container.read(agencyStoreProvider.notifier);

    // Login as Darshana Das & switch to Light Theme
    notifier.loginAsFounder('emp-02');
    notifier.setThemeMode(ThemeMode.light);

    // Create a Lead and convert to Client
    notifier.createLead(
      companyName: 'Brahmaputra Retail Labs',
      contactPerson: 'Ananya Baruah',
      phone: '+91 98640 11223',
      email: 'ananya@brahmaputraretail.in',
      source: 'LinkedIn',
      interestedService: 'E-commerce Development',
      budgetInr: 450000,
      priority: 'High',
      assignedEmployee: 'Darshana Das',
      location: 'Guwahati, Assam',
      industry: 'Retail & D2C',
      notes: 'Full omnichannel Shopify + ERP integration',
    );
    final leadId = container.read(agencyStoreProvider).leads.first.id;
    notifier.updateLeadStatus(leadId, 'Converted');

    expect(container.read(agencyStoreProvider).convertedLeadsCount, 1);
    expect(container.read(agencyStoreProvider).clients.length, 1);
    expect(
      container.read(agencyStoreProvider).clients.first.companyName,
      'Brahmaputra Retail Labs',
    );

    // Create Project, Task, Meeting, Invoice, Proposal, Expense & Chat Message
    notifier.createProject(
      name: 'Brahmaputra D2C Platform',
      clientName: 'Brahmaputra Retail Labs',
      category: 'E-commerce Development',
      description: 'Headless storefront + inventory sync',
      projectManager: 'Himon Bhuyan',
      budgetInr: 450000,
      deadline: DateTime.now().add(const Duration(days: 30)),
    );
    notifier.createInvoice(
      clientName: 'Brahmaputra Retail Labs',
      projectName: 'Brahmaputra D2C Platform',
      serviceCategory: 'E-commerce Development',
      totalAmountInr: 531000,
      paidAmountInr: 250000,
    );
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: 'Brahmaputra Retail Labs advance payment received!',
    );
    final msgId = container
        .read(agencyStoreProvider)
        .chatThreads
        .firstWhere((t) => t.id == 'founders-hq')
        .messages
        .first
        .id;
    notifier.toggleMessageReaction('founders-hq', msgId, '🚀');
    notifier.togglePinMessage('founders-hq', msgId);

    // Flush async SharedPreferences writes before disposing
    await notifier.flushToStorage();
    container.dispose();

    // Simulate closing the app from Recent Apps and cold-starting a new ProviderContainer
    final restartedContainer = ProviderContainer();
    addTearDown(restartedContainer.dispose);

    final restored = await restartedContainer
        .read(agencyStoreProvider.notifier)
        .hydrateFromStorage();

    expect(restored.isLoggedIn, isTrue);
    expect(restored.hasCompletedOnboarding, isTrue);
    expect(restored.currentUser.name, 'Darshana Das');
    expect(restored.themeMode, ThemeMode.light);
    expect(restored.leads.length, 1);
    expect(restored.clients.length, 1);
    expect(restored.projects.length, 1);
    expect(restored.invoices.length, 1);
    expect(restored.monthlyRevenueInr, 250000);

    final restoredBoard =
        restored.chatThreads.firstWhere((t) => t.id == 'founders-hq');
    expect(restoredBoard.messages.length, 1);
    expect(
      restoredBoard.messages.first.body,
      'Brahmaputra Retail Labs advance payment received!',
    );
    expect(restoredBoard.messages.first.reactions['🚀'], 1);
    expect(restoredBoard.messages.first.isPinned, isTrue);
  });

  test(
      '6. Notifications: Test Push Alert, Meeting Reminders, Follow-up Alerts & Read States',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);

    // 1. Trigger a live test push notification
    await notifier.triggerTestPushNotification();
    expect(container.read(agencyStoreProvider).unreadNotificationCount, 1);
    expect(
      container.read(agencyStoreProvider).notifications.first.category,
      'Announcements',
    );

    // 2. Schedule a Meeting -> creates a Meeting notification with 1d/1h/15m/0m reminders
    notifier.scheduleMeeting(
      title: 'Blue Hour Sprint Sync',
      clientOrCompany: 'Internal Founders',
      meetingType: 'Founder Meeting',
      startTime: DateTime.now().add(const Duration(hours: 2)),
      endTime: DateTime.now().add(const Duration(hours: 3)),
      location: 'Google Meet',
      onlineLink: 'https://meet.google.com/blue-hour-sync',
      participants: const ['Himon Bhuyan', 'Darshana Das', 'Drishant Das'],
      notes: 'Review cloud release & client pipeline',
    );
    expect(container.read(agencyStoreProvider).unreadNotificationCount, 2);
    expect(
      container
          .read(agencyStoreProvider)
          .notifications
          .any((n) => n.category == 'Meetings'),
      isTrue,
    );

    // 3. Toggle notification preferences & mark all read
    final prefs = container.read(agencyStoreProvider).notificationPrefs;
    notifier.updateNotificationPreferences(
      prefs.copyWith(quietHoursEnabled: true),
    );
    expect(
      container.read(agencyStoreProvider).notificationPrefs.quietHoursEnabled,
      isTrue,
    );

    notifier.markAllNotificationsRead();
    expect(container.read(agencyStoreProvider).unreadNotificationCount, 0);
  });

  testWidgets(
      '7. Notifications UI: Swipe-to-remove, Undo restore & Clear all',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);
    await notifier.triggerTestPushNotification();
    notifier.createLead(
      companyName: 'Swipe Test Studio',
      contactPerson: 'Aarav',
      phone: '+91 98640 00000',
      email: 'aarav@example.com',
      source: 'Website',
      interestedService: 'Brand Identity',
      budgetInr: 75000,
      priority: 'High',
      assignedEmployee: 'Himon Bhuyan',
      location: 'Guwahati, Assam',
      industry: 'Design Studio',
      notes: 'Swipe-to-dismiss verification alert',
    );
    expect(container.read(agencyStoreProvider).notifications.length, 2);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const NotificationCentreScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Dismissible), findsNWidgets(2));

    // Swipe first notification card to remove it
    await tester.drag(
      find.byType(Dismissible).first,
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(container.read(agencyStoreProvider).notifications.length, 1);
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo to restore the dismissed notification
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(container.read(agencyStoreProvider).notifications.length, 2);

    // Tap the visible "Clear all" button & confirm dialog
    await tester.tap(find.text('Clear all'));
    await tester.pumpAndSettle();
    expect(find.text('Clear notifications?'), findsOneWidget);
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();
    expect(container.read(agencyStoreProvider).notifications, isEmpty);
    expect(find.text('Zero unread studio alerts'), findsOneWidget);

    // Verify Meetings & Studio Calendar always shows Back button
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const MeetingCalendarScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back'), findsOneWidget);
  });

  test(
      '8. All workspace actions generate notifications & Chat unread count excludes hidden self-DM',
      () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);

    // Client added
    notifier.createClient(
      companyName: 'Kamakhya Heritage Hospitality',
      contactPerson: 'Rohan Nath',
      email: 'rohan@kamakhya.in',
      phone: '+91 98640 22334',
      address: 'Guwahati',
      industry: 'Hospitality',
      service: 'Brand Strategy',
      accountManager: 'Darshana Das',
      contractValueInr: 180000,
    );

    // Project added & updated
    notifier.createProject(
      name: 'Heritage Booking Engine',
      clientName: 'Kamakhya Heritage Hospitality',
      category: 'Web & Booking',
      description: 'Direct hotel reservation platform',
      projectManager: 'Himon Bhuyan',
      budgetInr: 180000,
      deadline: DateTime.now().add(const Duration(days: 30)),
    );
    final projId = container.read(agencyStoreProvider).projects.first.id;
    notifier.updateProjectProgress(projId, 50, 'In Progress');

    // To-Do task added & updated
    notifier.createTask(
      title: 'Design Booking Flow Wireframes',
      description: 'Mobile-first room search & GST checkout',
      projectId: projId,
      projectName: 'Heritage Booking Engine',
      assignedEmployee: 'Darshana Das',
      priority: 'High',
      deadline: DateTime.now().add(const Duration(days: 5)),
    );
    final taskId = container.read(agencyStoreProvider).tasks.first.id;
    notifier.updateTaskStatus(taskId, 'Completed');

    // Proposal, Invoice, Payment, Expense
    notifier.createProposal(
      clientOrLeadName: 'Kamakhya Heritage Hospitality',
      title: 'Annual Digital Retainer',
      serviceCategory: 'Performance Marketing',
      subtotalInr: 100000,
      discountInr: 0,
    );
    notifier.createInvoice(
      clientName: 'Kamakhya Heritage Hospitality',
      projectName: 'Heritage Booking Engine',
      serviceCategory: 'Web & Booking',
      totalAmountInr: 118000,
      paidAmountInr: 50000,
    );
    final invId = container.read(agencyStoreProvider).invoices.first.id;
    notifier.recordInvoicePayment(invId);
    notifier.createExpense(
      category: 'Cloud Hosting',
      vendorName: 'AWS India',
      description: 'Staging & Prod clusters',
      amountInr: 4500,
    );

    final notifs = container.read(agencyStoreProvider).notifications;
    expect(notifs.any((n) => n.title.contains('New Client Added')), isTrue);
    expect(notifs.any((n) => n.title.contains('New Project Added')), isTrue);
    expect(notifs.any((n) => n.title.contains('New To-Do Task')), isTrue);
    expect(notifs.any((n) => n.title.contains('To-Do Updated')), isTrue);
    expect(notifs.any((n) => n.title.contains('New Proposal Sent')), isTrue);
    expect(notifs.any((n) => n.title.contains('New GST Invoice')), isTrue);
    expect(notifs.any((n) => n.title.contains('Payment Received')), isTrue);
    expect(notifs.any((n) => n.title.contains('Expense Logged')), isTrue);

    // Chat unread badge count checks:
    // Himon sends DM to Darshana -> mirrors into dm-himon (hidden from Himon), so Himon's visible unread stays 0.
    notifier.sendChatMessage(
      threadId: 'dm-darshana',
      body: 'Checking navbar unread bubble accuracy!',
    );
    expect(container.read(agencyStoreProvider).totalUnreadChatCount, 0);

    // Switching to Darshana shows dm-himon as visible unread = 1.
    notifier.loginAsFounder('emp-02');
    expect(container.read(agencyStoreProvider).totalUnreadChatCount, 1);
  });

  test(
      '9. Power-Ups: Biometric toggle, @Mentions, Edit/Delete CRUD, Profit/Loss & AI Drafts',
      () {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);

    // Biometric lock toggle
    notifier.toggleBiometricLock(true);
    expect(container.read(agencyStoreProvider).biometricLockEnabled, isTrue);

    // @Mention in Founders Board generates mention priority alert
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: '@Darshana Das please review the pitch deck!',
    );
    expect(
      container
          .read(agencyStoreProvider)
          .notifications
          .any((n) => n.title.contains('Mentioned')),
      isTrue,
    );

    // Create + Edit + Delete Lead, Client, Project, Task, Meeting, Proposal, Invoice, Expense
    notifier.createLead(
      companyName: 'Edit Test Co',
      contactPerson: 'Zoya',
      phone: '+91 98640 12345',
      email: 'zoya@edittest.in',
      source: 'Website',
      interestedService: 'UI/UX Design',
      budgetInr: 90000,
      priority: 'Medium',
      assignedEmployee: 'Himon Bhuyan',
      location: 'Guwahati',
      industry: 'SaaS',
      notes: 'Initial note',
    );
    final leadId = container.read(agencyStoreProvider).leads.first.id;
    notifier.updateLead(
      leadId: leadId,
      companyName: 'Edit Test Co Updated',
      contactPerson: 'Zoya',
      phone: '+91 98640 12345',
      email: 'zoya@edittest.in',
      priority: 'Hot',
      budgetInr: 120000,
      notes: 'Updated budget',
    );
    expect(
      container.read(agencyStoreProvider).leads.first.companyName,
      'Edit Test Co Updated',
    );

    notifier.createClient(
      companyName: 'Client CRUD Co',
      contactPerson: 'Kabir',
      email: 'kabir@clientcrud.in',
      phone: '+91 98640 55555',
      address: 'Guwahati',
      industry: 'Retail',
      service: 'E-commerce Development',
      accountManager: 'Darshana Das',
      contractValueInr: 200000,
    );
    final clientId = container.read(agencyStoreProvider).clients.first.id;
    notifier.updateClient(
      clientId: clientId,
      companyName: 'Client CRUD Updated',
      contactPerson: 'Kabir',
      email: 'kabir@clientcrud.in',
      phone: '+91 98640 55555',
      status: 'Retainer',
      notes: 'Monthly retainer',
    );
    expect(container.read(agencyStoreProvider).clients.first.status, 'Retainer');

    notifier.createProject(
      name: 'CRUD Project',
      clientName: 'Client CRUD Updated',
      category: 'Web Applications',
      description: 'Initial scope',
      projectManager: 'Himon Bhuyan',
      budgetInr: 200000,
      deadline: DateTime.now().add(const Duration(days: 20)),
    );
    final projectId = container.read(agencyStoreProvider).projects.first.id;
    notifier.updateProject(
      projectId: projectId,
      name: 'CRUD Project v2',
      clientName: 'Client CRUD Updated',
      description: 'Refined scope',
      projectManager: 'Drishant Das',
      budgetInr: 225000,
      deadline: DateTime.now().add(const Duration(days: 25)),
    );
    expect(
      container.read(agencyStoreProvider).projects.first.name,
      'CRUD Project v2',
    );

    notifier.createTask(
      title: 'Initial Task',
      description: 'Task notes',
      projectId: projectId,
      projectName: 'CRUD Project v2',
      assignedEmployee: 'Himon Bhuyan',
      priority: 'Medium',
      deadline: DateTime.now().add(const Duration(days: 4)),
    );
    final taskId = container.read(agencyStoreProvider).tasks.first.id;
    notifier.updateTask(
      taskId: taskId,
      title: 'Updated Task',
      description: 'Done specs',
      assignedEmployee: 'Darshana Das',
      priority: 'Critical',
      deadline: DateTime.now().add(const Duration(days: 3)),
    );
    expect(container.read(agencyStoreProvider).tasks.first.title, 'Updated Task');

    notifier.createInvoice(
      clientName: 'Client CRUD Updated',
      projectName: 'CRUD Project v2',
      serviceCategory: 'Web Applications',
      totalAmountInr: 100000,
      paidAmountInr: 100000,
    );
    notifier.createExpense(
      category: 'Cloud',
      vendorName: 'GCP',
      description: 'Hosting',
      amountInr: 15000,
    );
    expect(container.read(agencyStoreProvider).netProfitInr, 85000);

    // AI Profit & Drafts
    expect(
      notifier.generateAiAssistantResponse('What is our net profit & margin?'),
      contains('Net Studio Profit'),
    );
    expect(
      notifier.generateAiAssistantResponse('Draft a WhatsApp follow-up message.'),
      contains('WhatsApp Follow-Up Draft'),
    );

    // Delete CRUD checks
    notifier.deleteTask(taskId);
    notifier.deleteProject(projectId);
    notifier.deleteClient(clientId);
    notifier.deleteLead(leadId);
    expect(container.read(agencyStoreProvider).tasks, isEmpty);
    expect(container.read(agencyStoreProvider).projects, isEmpty);
    expect(container.read(agencyStoreProvider).clients, isEmpty);
    expect(container.read(agencyStoreProvider).leads, isEmpty);

    // Super Admin reset wipes all remaining invoices, expenses, notifications & chat messages
    notifier.resetWorkspaceToClean();
    final wiped = container.read(agencyStoreProvider);
    expect(wiped.invoices, isEmpty);
    expect(wiped.expenses, isEmpty);
    expect(wiped.notifications, isEmpty);
    expect(wiped.chatThreads.every((t) => t.messages.isEmpty), isTrue);
  });

  testWidgets(
      '10. Chat UI: WhatsApp-style inline voice chat & built-in PDF/file viewer',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: 'Shared contract PDF for review',
      messageType: 'document',
      attachmentName: 'Contract.pdf',
      attachmentSize: '420 KB',
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ChatRoomScreen(threadId: 'founders-hq'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify WhatsApp mic button appears when composer is empty & sends inline voice note
    expect(find.byTooltip('Hold or Tap to Record Voice Note'), findsOneWidget);
    await tester.tap(find.byTooltip('Hold or Tap to Record Voice Note'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Send Voice Note'), findsOneWidget);
    expect(find.byTooltip('Delete Voice Recording'), findsOneWidget);
    await tester.tap(find.byTooltip('Send Voice Note'));
    await tester.pumpAndSettle();

    // Waveform speed pill appears on voice message
    expect(find.text('1x'), findsOneWidget);

    // Tapping shared PDF opens built-in ChatAttachmentViewerScreen
    expect(find.textContaining('Tap to open viewer'), findsOneWidget);
    await tester.tap(find.text('Contract.pdf'));
    await tester.pumpAndSettle();

    expect(find.text('Contract.pdf'), findsWidgets);
  });

  testWidgets(
      '11. Chat Read Receipts: Blue double-tick & Seen by others across DM and Board',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);

    // Himon sends a DM to Darshana and a message in Founders Board
    notifier.sendChatMessage(
      threadId: 'dm-darshana',
      body: 'Hey Darshana, check the deck',
    );
    notifier.sendChatMessage(
      threadId: 'founders-hq',
      body: 'Team standup in 10 mins',
    );

    // 1. Before Darshana opens DM, Himon sees delivered state without 'Seen'
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ChatRoomScreen(threadId: 'dm-darshana'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Seen'), findsNothing);

    // 2. Darshana switches profile and opens her reciprocal DM with Himon
    notifier.switchActiveFounder('emp-02');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ChatRoomScreen(threadId: 'dm-himon'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Mark Founders Board read as Darshana and Drishant too
    notifier.markThreadRead('founders-hq');
    notifier.switchActiveFounder('emp-03');
    notifier.markThreadRead('founders-hq');

    // 3. Himon returns to dm-darshana and sees the Blue Tick + 'Seen'
    notifier.switchActiveFounder('emp-01');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ChatRoomScreen(threadId: 'dm-darshana'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seen'), findsOneWidget);
    final blueTickFinder = find.byWidgetPredicate(
      (w) =>
          w is Icon &&
          w.icon == Icons.done_all_rounded &&
          w.color == const Color(0xFF38BDF8),
    );
    expect(blueTickFinder, findsOneWidget);

    // 4. Himon checks Founders Board and sees 'Seen by Darshana, Drishant'
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const ChatRoomScreen(threadId: 'founders-hq'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seen by Darshana, Drishant'), findsOneWidget);

    // 5. Opening Notification Centre auto-clears unreadNotificationCount badge
    await notifier.triggerTestPushNotification();
    expect(container.read(agencyStoreProvider).unreadNotificationCount, greaterThan(0));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const NotificationCentreScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(container.read(agencyStoreProvider).unreadNotificationCount, 0);
  });

  testWidgets(
      '12. Meetings Calendar: Per-day date filtering & 10-minute pre-meeting alarm',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(agencyStoreProvider.notifier);
    final now = DateTime.now();
    final todayBase = DateTime(now.year, now.month, now.day, 17, 0);
    final tomorrow = todayBase.add(const Duration(days: 1));

    // Schedule 2 meetings on today and 1 on tomorrow
    notifier.scheduleMeeting(
      title: 'Today Design Review',
      clientOrCompany: 'Blue Hour Internal',
      meetingType: 'Internal Meeting',
      startTime: todayBase,
      endTime: todayBase.add(const Duration(hours: 1)),
      location: 'Google Meet',
      participants: const ['Himon Bhuyan', 'Darshana Das'],
      notes: 'Review UI screens',
    );
    notifier.scheduleMeeting(
      title: 'Today Client Call',
      clientOrCompany: 'NorthEast Tech',
      meetingType: 'Client Meeting',
      startTime: todayBase.add(const Duration(hours: 2)),
      endTime: todayBase.add(const Duration(hours: 3)),
      location: 'Zoom',
      participants: const ['Himon Bhuyan'],
      notes: 'Scope discussion',
    );

    final createdMtg = container.read(agencyStoreProvider).meetings.first;
    expect(createdMtg.reminders, contains('Alarm 10m before'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const MeetingCalendarScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Today shows Today's 2 meetings
    expect(find.text('Today Design Review'), findsOneWidget);
    expect(find.text('Today Client Call'), findsOneWidget);

    // Selecting tomorrow does NOT repeat today's meetings
    final tomorrowKey = ValueKey(
      'calendar_day_${tomorrow.year}_${tomorrow.month}_${tomorrow.day}',
    );
    await tester.tap(find.byKey(tomorrowKey));
    await tester.pumpAndSettle();

    expect(find.text('Today Design Review'), findsNothing);
    expect(find.text('Today Client Call'), findsNothing);
    expect(find.textContaining('No meetings on'), findsOneWidget);
  });
}
