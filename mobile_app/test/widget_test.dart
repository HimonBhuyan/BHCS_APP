import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue_hour_hq/main.dart';
import 'package:blue_hour_hq/core/theme/app_theme.dart';
import 'package:blue_hour_hq/data/models/agency_models.dart';
import 'package:blue_hour_hq/data/repositories/agency_store.dart';
import 'package:blue_hour_hq/features/chat/chat_screen.dart';

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
}
