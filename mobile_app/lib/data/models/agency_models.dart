import 'package:flutter/material.dart';

/// All 9 official Blue Hour HQ RBAC roles.
enum UserRole {
  founder('Founder', 'Full Executive Access'),
  superAdmin('Super Admin', 'System & Operations Governance'),
  administrator('Administrator', 'Operations & Team Administration'),
  salesExecutive('Sales Executive', 'CRM, Pipeline & Proposals'),
  projectManager('Project Manager', 'Delivery, Milestones & Sprints'),
  developer('Developer', 'Engineering & Technical Tasks'),
  designer('Designer', 'UI/UX & Brand Systems'),
  socialMediaManager('Social Media Manager', 'Campaigns & Content Calendar'),
  financeManager('Finance Manager', 'GST Invoicing, Payments & Expenses');

  final String label;
  final String subtitle;
  const UserRole(this.label, this.subtitle);

  bool get canAccessFinance =>
      this == UserRole.founder ||
      this == UserRole.superAdmin ||
      this == UserRole.financeManager;

  bool get canDeleteLeads =>
      this == UserRole.founder ||
      this == UserRole.superAdmin ||
      this == UserRole.administrator;
}

class AppUser {
  final String id;
  final String employeeCode;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String department;
  final String designation;
  final DateTime joiningDate;
  final bool isOnline;
  final bool twoFactorEnabled;
  final String briefingTime;
  final int assignedProjectsCount;
  final int activeTasksCount;
  final int convertedLeadsThisMonth;
  final double performanceScore;

  const AppUser({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.designation,
    required this.joiningDate,
    this.isOnline = true,
    this.twoFactorEnabled = true,
    this.briefingTime = '08:30 AM',
    this.assignedProjectsCount = 0,
    this.activeTasksCount = 0,
    this.convertedLeadsThisMonth = 0,
    this.performanceScore = 94.0,
  });

  /// Strictly Himon Bhuyan (`emp-01`) holds Super Admin privileges.
  bool get isSuperAdmin => id == 'emp-01';

  String get accessBadgeLabel {
    if (id == 'emp-01') return 'SUPER ADMIN';
    if (id == 'emp-02') return 'PARTNER';
    return 'CO-FOUNDER';
  }

  AppUser copyWith({
    String? name,
    String? phone,
    UserRole? role,
    bool? twoFactorEnabled,
    String? briefingTime,
    bool? isOnline,
  }) {
    return AppUser(
      id: id,
      employeeCode: employeeCode,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department,
      designation: designation,
      joiningDate: joiningDate,
      isOnline: isOnline ?? this.isOnline,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      briefingTime: briefingTime ?? this.briefingTime,
      assignedProjectsCount: assignedProjectsCount,
      activeTasksCount: activeTasksCount,
      convertedLeadsThisMonth: convertedLeadsThisMonth,
      performanceScore: performanceScore,
    );
  }
}

class LeadActivityItem {
  final String id;
  final String type; // 'call', 'whatsapp', 'email', 'status', 'note', 'proposal', 'meeting'
  final String title;
  final String description;
  final String actorName;
  final DateTime timestamp;

  const LeadActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.actorName,
    required this.timestamp,
  });
}

class LeadFollowupItem {
  final String id;
  final String leadId;
  final String companyName;
  final String assignedEmployee;
  final String followupType; // Phone Call, WhatsApp, Email, Client Meeting, General Follow-up
  final DateTime scheduledAt;
  final String notes;
  final List<String> reminderIntervals; // ['1d', '1h', '15m', '0m']
  final bool isCompleted;

  const LeadFollowupItem({
    required this.id,
    required this.leadId,
    required this.companyName,
    required this.assignedEmployee,
    required this.followupType,
    required this.scheduledAt,
    required this.notes,
    this.reminderIntervals = const ['1 day before', '1 hour before', '15m before'],
    this.isCompleted = false,
  });

  LeadFollowupItem copyWith({bool? isCompleted, DateTime? scheduledAt}) {
    return LeadFollowupItem(
      id: id,
      leadId: leadId,
      companyName: companyName,
      assignedEmployee: assignedEmployee,
      followupType: followupType,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notes: notes,
      reminderIntervals: reminderIntervals,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class LeadRecord {
  static const List<String> pipelineStatuses = [
    'New Lead',
    'Contacted',
    'Meeting Scheduled',
    'Requirement Gathering',
    'Proposal Sent',
    'Negotiation',
    'Converted',
    'Lost',
  ];

  static const List<String> leadSources = [
    'Instagram',
    'Facebook',
    'LinkedIn',
    'WhatsApp',
    'Website',
    'Google',
    'Referral',
    'Cold Calling',
    'Email',
    'Other',
  ];

  static const List<String> agencyServices = [
    'Website Development',
    'Web Application Development',
    'E-commerce Development',
    'UI/UX Design',
    'Social Media Management',
    'Digital Marketing',
    'Custom Software Development',
    'Hardware & IoT Systems',
    'Branding and Creative Services',
  ];

  final String id;
  final String leadCode;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String email;
  final String website;
  final String location;
  final String industry;
  final String source;
  final String interestedService;
  final double estimatedBudgetInr;
  final String assignedEmployeeName;
  final String priority; // Low, Medium, High, Urgent
  final String status;
  final DateTime expectedClosingDate;
  final DateTime createdDate;
  final DateTime? nextFollowupAt;
  final String notes;
  final String? lostReason;
  final List<String> attachments;
  final List<LeadActivityItem> timeline;

  const LeadRecord({
    required this.id,
    required this.leadCode,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.website,
    required this.location,
    required this.industry,
    required this.source,
    required this.interestedService,
    required this.estimatedBudgetInr,
    required this.assignedEmployeeName,
    required this.priority,
    required this.status,
    required this.expectedClosingDate,
    required this.createdDate,
    this.nextFollowupAt,
    required this.notes,
    this.lostReason,
    this.attachments = const [],
    this.timeline = const [],
  });

  LeadRecord copyWith({
    String? companyName,
    String? contactPerson,
    String? phone,
    String? email,
    String? status,
    String? priority,
    String? assignedEmployeeName,
    double? estimatedBudgetInr,
    DateTime? nextFollowupAt,
    String? notes,
    String? lostReason,
    List<String>? attachments,
    List<LeadActivityItem>? timeline,
  }) {
    return LeadRecord(
      id: id,
      leadCode: leadCode,
      companyName: companyName ?? this.companyName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website,
      location: location,
      industry: industry,
      source: source,
      interestedService: interestedService,
      estimatedBudgetInr: estimatedBudgetInr ?? this.estimatedBudgetInr,
      assignedEmployeeName: assignedEmployeeName ?? this.assignedEmployeeName,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      expectedClosingDate: expectedClosingDate,
      createdDate: createdDate,
      nextFollowupAt: nextFollowupAt ?? this.nextFollowupAt,
      notes: notes ?? this.notes,
      lostReason: lostReason ?? this.lostReason,
      attachments: attachments ?? this.attachments,
      timeline: timeline ?? this.timeline,
    );
  }
}

class ClientRecord {
  final String id;
  final String clientCode;
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String industry;
  final List<String> servicesPurchased;
  final String accountManager;
  final String status; // Active, Retainer, On Hold
  final double totalBilledInr;
  final double outstandingInr;
  final int activeProjectsCount;
  final DateTime onboardedAt;
  final String notes;

  const ClientRecord({
    required this.id,
    required this.clientCode,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.industry,
    required this.servicesPurchased,
    required this.accountManager,
    required this.status,
    required this.totalBilledInr,
    required this.outstandingInr,
    required this.activeProjectsCount,
    required this.onboardedAt,
    required this.notes,
  });
}

class ChatMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String body;
  final DateTime timestamp;
  final bool isMe;
  final String messageType; // 'text', 'voice', 'document', 'image', 'announcement'
  final String? attachmentName;
  final String? attachmentSize;
  final int? voiceDurationSec;
  final String? replyToSender;
  final String? replyToPreview;
  final Map<String, int> reactions;
  final bool isPinned;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.body,
    required this.timestamp,
    this.isMe = false,
    this.messageType = 'text',
    this.attachmentName,
    this.attachmentSize,
    this.voiceDurationSec,
    this.replyToSender,
    this.replyToPreview,
    this.reactions = const {},
    this.isPinned = false,
    this.isRead = true,
  });

  ChatMessage copyWith({
    String? threadId,
    String? body,
    bool? isMe,
    Map<String, int>? reactions,
    bool? isPinned,
  }) {
    return ChatMessage(
      id: id,
      threadId: threadId ?? this.threadId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      body: body ?? this.body,
      timestamp: timestamp,
      isMe: isMe ?? this.isMe,
      messageType: messageType,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
      voiceDurationSec: voiceDurationSec,
      replyToSender: replyToSender,
      replyToPreview: replyToPreview,
      reactions: reactions ?? this.reactions,
      isPinned: isPinned ?? this.isPinned,
      isRead: isRead,
    );
  }
}

class ChatThread {
  final String id;
  final String name;
  final String subtitle;
  final bool isChannel;
  final bool isAnnouncement;
  final bool isPrivate;
  final bool isOnline;
  final bool isMuted;
  final int unreadCount;
  final int membersCount;
  final String lastMessagePreview;
  final DateTime lastActivity;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.isChannel,
    this.isAnnouncement = false,
    this.isPrivate = false,
    this.isOnline = true,
    this.isMuted = false,
    this.unreadCount = 0,
    this.membersCount = 2,
    required this.lastMessagePreview,
    required this.lastActivity,
    required this.messages,
  });

  ChatThread copyWith({
    int? unreadCount,
    bool? isMuted,
    String? lastMessagePreview,
    DateTime? lastActivity,
    List<ChatMessage>? messages,
  }) {
    return ChatThread(
      id: id,
      name: name,
      subtitle: subtitle,
      isChannel: isChannel,
      isAnnouncement: isAnnouncement,
      isPrivate: isPrivate,
      isOnline: isOnline,
      isMuted: isMuted ?? this.isMuted,
      unreadCount: unreadCount ?? this.unreadCount,
      membersCount: membersCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastActivity: lastActivity ?? this.lastActivity,
      messages: messages ?? this.messages,
    );
  }
}

class SubtaskItem {
  final String id;
  final String title;
  final bool isCompleted;

  const SubtaskItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubtaskItem copyWith({bool? isCompleted}) =>
      SubtaskItem(id: id, title: title, isCompleted: isCompleted ?? this.isCompleted);
}

class TaskItem {
  static const List<String> statuses = [
    'To Do',
    'In Progress',
    'Review',
    'Completed',
    'Blocked',
  ];

  final String id;
  final String taskCode;
  final String title;
  final String description;
  final String projectId;
  final String projectName;
  final String assignedEmployee;
  final String priority; // Low, Medium, High, Critical
  final String status;
  final DateTime startDate;
  final DateTime deadline;
  final double loggedHours;
  final double estimatedHours;
  final List<SubtaskItem> subtasks;

  const TaskItem({
    required this.id,
    required this.taskCode,
    required this.title,
    required this.description,
    required this.projectId,
    required this.projectName,
    required this.assignedEmployee,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.deadline,
    this.loggedHours = 0,
    this.estimatedHours = 8,
    this.subtasks = const [],
  });

  bool get isOverdue =>
      status != 'Completed' && deadline.isBefore(DateTime.now());

  TaskItem copyWith({
    String? status,
    String? assignedEmployee,
    double? loggedHours,
    List<SubtaskItem>? subtasks,
  }) {
    return TaskItem(
      id: id,
      taskCode: taskCode,
      title: title,
      description: description,
      projectId: projectId,
      projectName: projectName,
      assignedEmployee: assignedEmployee ?? this.assignedEmployee,
      priority: priority,
      status: status ?? this.status,
      startDate: startDate,
      deadline: deadline,
      loggedHours: loggedHours ?? this.loggedHours,
      estimatedHours: estimatedHours,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

class MilestoneItem {
  final String id;
  final String title;
  final DateTime dueDate;
  final double amountInr;
  final bool isCompleted;

  const MilestoneItem({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.amountInr,
    required this.isCompleted,
  });
}

class ProjectRecord {
  static const List<String> categories = [
    'Website Development',
    'E-commerce Development',
    'Web Applications',
    'UI/UX Design',
    'Social Media Management',
    'Digital Marketing',
    'Custom Software Development',
    'Hardware & IoT Systems',
  ];

  final String id;
  final String projectCode;
  final String name;
  final String clientName;
  final String category;
  final String description;
  final String projectManager;
  final List<String> assignedTeam;
  final DateTime startDate;
  final DateTime deadline;
  final double budgetInr;
  final String status; // Planning, In Progress, In Review, Completed, Delayed
  final int progressPercentage;
  final List<MilestoneItem> milestones;

  const ProjectRecord({
    required this.id,
    required this.projectCode,
    required this.name,
    required this.clientName,
    required this.category,
    required this.description,
    required this.projectManager,
    required this.assignedTeam,
    required this.startDate,
    required this.deadline,
    required this.budgetInr,
    required this.status,
    required this.progressPercentage,
    this.milestones = const [],
  });

  ProjectRecord copyWith({
    String? status,
    int? progressPercentage,
    List<String>? assignedTeam,
  }) {
    return ProjectRecord(
      id: id,
      projectCode: projectCode,
      name: name,
      clientName: clientName,
      category: category,
      description: description,
      projectManager: projectManager,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      startDate: startDate,
      deadline: deadline,
      budgetInr: budgetInr,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      milestones: milestones,
    );
  }
}

class MeetingRecord {
  static const List<String> meetingTypes = [
    'Client Meeting',
    'Sales Meeting',
    'Internal Meeting',
    'Project Discussion',
    'Review Meeting',
    'Founder Meeting',
  ];

  final String id;
  final String meetingCode;
  final String title;
  final String clientOrCompany;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String meetingType;
  final String location;
  final String? onlineMeetingLink;
  final List<String> participants;
  final String assignedEmployee;
  final String status; // Scheduled, Completed, Rescheduled, Cancelled
  final String notes;
  final List<String> reminders;

  const MeetingRecord({
    required this.id,
    required this.meetingCode,
    required this.title,
    required this.clientOrCompany,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.meetingType,
    required this.location,
    this.onlineMeetingLink,
    required this.participants,
    required this.assignedEmployee,
    this.status = 'Scheduled',
    this.notes = '',
    this.reminders = const ['1 day before', '1 hour before', '15m before', 'At start'],
  });

  bool get hasOnlineLink =>
      onlineMeetingLink != null && onlineMeetingLink!.trim().isNotEmpty;

  MeetingRecord copyWith({
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  }) {
    return MeetingRecord(
      id: id,
      meetingCode: meetingCode,
      title: title,
      clientOrCompany: clientOrCompany,
      description: description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      meetingType: meetingType,
      location: location,
      onlineMeetingLink: onlineMeetingLink,
      participants: participants,
      assignedEmployee: assignedEmployee,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      reminders: reminders,
    );
  }
}

class AppNotification {
  static const List<String> categories = [
    'All',
    'Leads',
    'Meetings',
    'Tasks',
    'Projects',
    'Messages',
    'Payments',
    'Announcements',
  ];

  final String id;
  final String category;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? targetRoute;
  final String? entityId;
  final List<String> actions;

  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.targetRoute,
    this.entityId,
    this.actions = const [],
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      category: category,
      title: title,
      body: body,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute,
      entityId: entityId,
      actions: actions,
    );
  }
}

class ProposalRecord {
  final String id;
  final String proposalCode;
  final String clientOrLeadName;
  final String title;
  final String serviceCategory;
  final double subtotalInr;
  final double discountInr;
  final double gstAmountInr;
  final double totalAmountInr;
  final DateTime validUntil;
  final String status; // Draft, Sent, Accepted, Rejected
  final String preparedBy;

  const ProposalRecord({
    required this.id,
    required this.proposalCode,
    required this.clientOrLeadName,
    required this.title,
    required this.serviceCategory,
    required this.subtotalInr,
    required this.discountInr,
    required this.gstAmountInr,
    required this.totalAmountInr,
    required this.validUntil,
    required this.status,
    required this.preparedBy,
  });

  ProposalRecord copyWith({String? status}) {
    return ProposalRecord(
      id: id,
      proposalCode: proposalCode,
      clientOrLeadName: clientOrLeadName,
      title: title,
      serviceCategory: serviceCategory,
      subtotalInr: subtotalInr,
      discountInr: discountInr,
      gstAmountInr: gstAmountInr,
      totalAmountInr: totalAmountInr,
      validUntil: validUntil,
      status: status ?? this.status,
      preparedBy: preparedBy,
    );
  }
}

class InvoiceRecord {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final String projectName;
  final String serviceCategory;
  final DateTime issueDate;
  final DateTime dueDate;
  final double totalAmountInr;
  final double paidAmountInr;
  final String status; // Paid, Partially Paid, Overdue, Sent

  const InvoiceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.projectName,
    required this.serviceCategory,
    required this.issueDate,
    required this.dueDate,
    required this.totalAmountInr,
    required this.paidAmountInr,
    required this.status,
  });

  double get balanceDueInr =>
      (totalAmountInr - paidAmountInr).clamp(0, double.infinity);

  InvoiceRecord copyWith({double? paidAmountInr, String? status}) {
    return InvoiceRecord(
      id: id,
      invoiceNumber: invoiceNumber,
      clientName: clientName,
      projectName: projectName,
      serviceCategory: serviceCategory,
      issueDate: issueDate,
      dueDate: dueDate,
      totalAmountInr: totalAmountInr,
      paidAmountInr: paidAmountInr ?? this.paidAmountInr,
      status: status ?? this.status,
    );
  }
}

class ExpenseRecord {
  final String id;
  final String expenseCode;
  final String category;
  final String vendorName;
  final String description;
  final double amountInr;
  final DateTime date;
  final String status;

  const ExpenseRecord({
    required this.id,
    required this.expenseCode,
    required this.category,
    required this.vendorName,
    required this.description,
    required this.amountInr,
    required this.date,
    this.status = 'Approved',
  });
}

@immutable
class NotificationPreferencesState {
  final bool leadReminders;
  final bool meetingReminders;
  final bool taskReminders;
  final bool projectNotifications;
  final bool chatNotifications;
  final bool paymentNotifications;
  final bool dailyFounderBriefing;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  const NotificationPreferencesState({
    this.leadReminders = true,
    this.meetingReminders = true,
    this.taskReminders = true,
    this.projectNotifications = true,
    this.chatNotifications = true,
    this.paymentNotifications = true,
    this.dailyFounderBriefing = true,
    this.quietHoursEnabled = true,
    this.quietHoursStart = '10:30 PM',
    this.quietHoursEnd = '07:30 AM',
  });

  NotificationPreferencesState copyWith({
    bool? leadReminders,
    bool? meetingReminders,
    bool? taskReminders,
    bool? projectNotifications,
    bool? chatNotifications,
    bool? paymentNotifications,
    bool? dailyFounderBriefing,
    bool? quietHoursEnabled,
  }) {
    return NotificationPreferencesState(
      leadReminders: leadReminders ?? this.leadReminders,
      meetingReminders: meetingReminders ?? this.meetingReminders,
      taskReminders: taskReminders ?? this.taskReminders,
      projectNotifications: projectNotifications ?? this.projectNotifications,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      dailyFounderBriefing: dailyFounderBriefing ?? this.dailyFounderBriefing,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );
  }
}

