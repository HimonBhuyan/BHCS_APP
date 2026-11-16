part of 'blue_hour_mobile.dart';

class ListWorkspaceSnapshotVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListWorkspaceSnapshotVariablesBuilder(this._dataConnect, );
  Deserializer<ListWorkspaceSnapshotData> dataDeserializer = (dynamic json)  => ListWorkspaceSnapshotData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListWorkspaceSnapshotData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListWorkspaceSnapshotData, void> ref() {
    
    return _dataConnect.query("ListWorkspaceSnapshot", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListWorkspaceSnapshotFounders {
  final String id;
  final String employeeCode;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isSuperAdmin;
  final String department;
  final String designation;
  ListWorkspaceSnapshotFounders.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  employeeCode = nativeFromJson<String>(json['employeeCode']),
  name = nativeFromJson<String>(json['name']),
  email = nativeFromJson<String>(json['email']),
  phone = nativeFromJson<String>(json['phone']),
  role = nativeFromJson<String>(json['role']),
  isSuperAdmin = nativeFromJson<bool>(json['isSuperAdmin']),
  department = nativeFromJson<String>(json['department']),
  designation = nativeFromJson<String>(json['designation']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotFounders otherTyped = other as ListWorkspaceSnapshotFounders;
    return id == otherTyped.id && 
    employeeCode == otherTyped.employeeCode && 
    name == otherTyped.name && 
    email == otherTyped.email && 
    phone == otherTyped.phone && 
    role == otherTyped.role && 
    isSuperAdmin == otherTyped.isSuperAdmin && 
    department == otherTyped.department && 
    designation == otherTyped.designation;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, employeeCode.hashCode, name.hashCode, email.hashCode, phone.hashCode, role.hashCode, isSuperAdmin.hashCode, department.hashCode, designation.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['employeeCode'] = nativeToJson<String>(employeeCode);
    json['name'] = nativeToJson<String>(name);
    json['email'] = nativeToJson<String>(email);
    json['phone'] = nativeToJson<String>(phone);
    json['role'] = nativeToJson<String>(role);
    json['isSuperAdmin'] = nativeToJson<bool>(isSuperAdmin);
    json['department'] = nativeToJson<String>(department);
    json['designation'] = nativeToJson<String>(designation);
    return json;
  }

  ListWorkspaceSnapshotFounders({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isSuperAdmin,
    required this.department,
    required this.designation,
  });
}

@immutable
class ListWorkspaceSnapshotLeads {
  final String id;
  final String leadCode;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String email;
  final String location;
  final String industry;
  final String source;
  final String interestedService;
  final double estimatedBudgetInr;
  final String assignedEmployeeName;
  final String priority;
  final String status;
  final Timestamp expectedClosingDate;
  final Timestamp createdDate;
  final Timestamp? nextFollowupAt;
  final String? notes;
  ListWorkspaceSnapshotLeads.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  leadCode = nativeFromJson<String>(json['leadCode']),
  companyName = nativeFromJson<String>(json['companyName']),
  contactPerson = nativeFromJson<String>(json['contactPerson']),
  phone = nativeFromJson<String>(json['phone']),
  email = nativeFromJson<String>(json['email']),
  location = nativeFromJson<String>(json['location']),
  industry = nativeFromJson<String>(json['industry']),
  source = nativeFromJson<String>(json['source']),
  interestedService = nativeFromJson<String>(json['interestedService']),
  estimatedBudgetInr = nativeFromJson<double>(json['estimatedBudgetInr']),
  assignedEmployeeName = nativeFromJson<String>(json['assignedEmployeeName']),
  priority = nativeFromJson<String>(json['priority']),
  status = nativeFromJson<String>(json['status']),
  expectedClosingDate = Timestamp.fromJson(json['expectedClosingDate']),
  createdDate = Timestamp.fromJson(json['createdDate']),
  nextFollowupAt = json['nextFollowupAt'] == null ? null : Timestamp.fromJson(json['nextFollowupAt']),
  notes = json['notes'] == null ? null : nativeFromJson<String>(json['notes']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotLeads otherTyped = other as ListWorkspaceSnapshotLeads;
    return id == otherTyped.id && 
    leadCode == otherTyped.leadCode && 
    companyName == otherTyped.companyName && 
    contactPerson == otherTyped.contactPerson && 
    phone == otherTyped.phone && 
    email == otherTyped.email && 
    location == otherTyped.location && 
    industry == otherTyped.industry && 
    source == otherTyped.source && 
    interestedService == otherTyped.interestedService && 
    estimatedBudgetInr == otherTyped.estimatedBudgetInr && 
    assignedEmployeeName == otherTyped.assignedEmployeeName && 
    priority == otherTyped.priority && 
    status == otherTyped.status && 
    expectedClosingDate == otherTyped.expectedClosingDate && 
    createdDate == otherTyped.createdDate && 
    nextFollowupAt == otherTyped.nextFollowupAt && 
    notes == otherTyped.notes;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, leadCode.hashCode, companyName.hashCode, contactPerson.hashCode, phone.hashCode, email.hashCode, location.hashCode, industry.hashCode, source.hashCode, interestedService.hashCode, estimatedBudgetInr.hashCode, assignedEmployeeName.hashCode, priority.hashCode, status.hashCode, expectedClosingDate.hashCode, createdDate.hashCode, nextFollowupAt.hashCode, notes.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['leadCode'] = nativeToJson<String>(leadCode);
    json['companyName'] = nativeToJson<String>(companyName);
    json['contactPerson'] = nativeToJson<String>(contactPerson);
    json['phone'] = nativeToJson<String>(phone);
    json['email'] = nativeToJson<String>(email);
    json['location'] = nativeToJson<String>(location);
    json['industry'] = nativeToJson<String>(industry);
    json['source'] = nativeToJson<String>(source);
    json['interestedService'] = nativeToJson<String>(interestedService);
    json['estimatedBudgetInr'] = nativeToJson<double>(estimatedBudgetInr);
    json['assignedEmployeeName'] = nativeToJson<String>(assignedEmployeeName);
    json['priority'] = nativeToJson<String>(priority);
    json['status'] = nativeToJson<String>(status);
    json['expectedClosingDate'] = expectedClosingDate.toJson();
    json['createdDate'] = createdDate.toJson();
    if (nextFollowupAt != null) {
      json['nextFollowupAt'] = nextFollowupAt!.toJson();
    }
    if (notes != null) {
      json['notes'] = nativeToJson<String?>(notes);
    }
    return json;
  }

  ListWorkspaceSnapshotLeads({
    required this.id,
    required this.leadCode,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.email,
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
    this.notes,
  });
}

@immutable
class ListWorkspaceSnapshotClients {
  final String id;
  final String clientCode;
  final String companyName;
  final String contactPerson;
  final String email;
  final String phone;
  final String accountManager;
  final String status;
  final double totalBilledInr;
  final double outstandingInr;
  final int activeProjectsCount;
  final Timestamp onboardedAt;
  ListWorkspaceSnapshotClients.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  clientCode = nativeFromJson<String>(json['clientCode']),
  companyName = nativeFromJson<String>(json['companyName']),
  contactPerson = nativeFromJson<String>(json['contactPerson']),
  email = nativeFromJson<String>(json['email']),
  phone = nativeFromJson<String>(json['phone']),
  accountManager = nativeFromJson<String>(json['accountManager']),
  status = nativeFromJson<String>(json['status']),
  totalBilledInr = nativeFromJson<double>(json['totalBilledInr']),
  outstandingInr = nativeFromJson<double>(json['outstandingInr']),
  activeProjectsCount = nativeFromJson<int>(json['activeProjectsCount']),
  onboardedAt = Timestamp.fromJson(json['onboardedAt']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotClients otherTyped = other as ListWorkspaceSnapshotClients;
    return id == otherTyped.id && 
    clientCode == otherTyped.clientCode && 
    companyName == otherTyped.companyName && 
    contactPerson == otherTyped.contactPerson && 
    email == otherTyped.email && 
    phone == otherTyped.phone && 
    accountManager == otherTyped.accountManager && 
    status == otherTyped.status && 
    totalBilledInr == otherTyped.totalBilledInr && 
    outstandingInr == otherTyped.outstandingInr && 
    activeProjectsCount == otherTyped.activeProjectsCount && 
    onboardedAt == otherTyped.onboardedAt;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, clientCode.hashCode, companyName.hashCode, contactPerson.hashCode, email.hashCode, phone.hashCode, accountManager.hashCode, status.hashCode, totalBilledInr.hashCode, outstandingInr.hashCode, activeProjectsCount.hashCode, onboardedAt.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['clientCode'] = nativeToJson<String>(clientCode);
    json['companyName'] = nativeToJson<String>(companyName);
    json['contactPerson'] = nativeToJson<String>(contactPerson);
    json['email'] = nativeToJson<String>(email);
    json['phone'] = nativeToJson<String>(phone);
    json['accountManager'] = nativeToJson<String>(accountManager);
    json['status'] = nativeToJson<String>(status);
    json['totalBilledInr'] = nativeToJson<double>(totalBilledInr);
    json['outstandingInr'] = nativeToJson<double>(outstandingInr);
    json['activeProjectsCount'] = nativeToJson<int>(activeProjectsCount);
    json['onboardedAt'] = onboardedAt.toJson();
    return json;
  }

  ListWorkspaceSnapshotClients({
    required this.id,
    required this.clientCode,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.accountManager,
    required this.status,
    required this.totalBilledInr,
    required this.outstandingInr,
    required this.activeProjectsCount,
    required this.onboardedAt,
  });
}

@immutable
class ListWorkspaceSnapshotProjects {
  final String id;
  final String projectCode;
  final String name;
  final String clientName;
  final String category;
  final String? description;
  final String projectManager;
  final Timestamp startDate;
  final Timestamp deadline;
  final double budgetInr;
  final String status;
  final int progressPercentage;
  ListWorkspaceSnapshotProjects.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  projectCode = nativeFromJson<String>(json['projectCode']),
  name = nativeFromJson<String>(json['name']),
  clientName = nativeFromJson<String>(json['clientName']),
  category = nativeFromJson<String>(json['category']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  projectManager = nativeFromJson<String>(json['projectManager']),
  startDate = Timestamp.fromJson(json['startDate']),
  deadline = Timestamp.fromJson(json['deadline']),
  budgetInr = nativeFromJson<double>(json['budgetInr']),
  status = nativeFromJson<String>(json['status']),
  progressPercentage = nativeFromJson<int>(json['progressPercentage']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotProjects otherTyped = other as ListWorkspaceSnapshotProjects;
    return id == otherTyped.id && 
    projectCode == otherTyped.projectCode && 
    name == otherTyped.name && 
    clientName == otherTyped.clientName && 
    category == otherTyped.category && 
    description == otherTyped.description && 
    projectManager == otherTyped.projectManager && 
    startDate == otherTyped.startDate && 
    deadline == otherTyped.deadline && 
    budgetInr == otherTyped.budgetInr && 
    status == otherTyped.status && 
    progressPercentage == otherTyped.progressPercentage;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, projectCode.hashCode, name.hashCode, clientName.hashCode, category.hashCode, description.hashCode, projectManager.hashCode, startDate.hashCode, deadline.hashCode, budgetInr.hashCode, status.hashCode, progressPercentage.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['projectCode'] = nativeToJson<String>(projectCode);
    json['name'] = nativeToJson<String>(name);
    json['clientName'] = nativeToJson<String>(clientName);
    json['category'] = nativeToJson<String>(category);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['projectManager'] = nativeToJson<String>(projectManager);
    json['startDate'] = startDate.toJson();
    json['deadline'] = deadline.toJson();
    json['budgetInr'] = nativeToJson<double>(budgetInr);
    json['status'] = nativeToJson<String>(status);
    json['progressPercentage'] = nativeToJson<int>(progressPercentage);
    return json;
  }

  ListWorkspaceSnapshotProjects({
    required this.id,
    required this.projectCode,
    required this.name,
    required this.clientName,
    required this.category,
    this.description,
    required this.projectManager,
    required this.startDate,
    required this.deadline,
    required this.budgetInr,
    required this.status,
    required this.progressPercentage,
  });
}

@immutable
class ListWorkspaceSnapshotTasks {
  final String id;
  final String taskCode;
  final String title;
  final String? description;
  final String projectId;
  final String projectName;
  final String assignedEmployee;
  final String priority;
  final String status;
  final Timestamp startDate;
  final Timestamp deadline;
  ListWorkspaceSnapshotTasks.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  taskCode = nativeFromJson<String>(json['taskCode']),
  title = nativeFromJson<String>(json['title']),
  description = json['description'] == null ? null : nativeFromJson<String>(json['description']),
  projectId = nativeFromJson<String>(json['projectId']),
  projectName = nativeFromJson<String>(json['projectName']),
  assignedEmployee = nativeFromJson<String>(json['assignedEmployee']),
  priority = nativeFromJson<String>(json['priority']),
  status = nativeFromJson<String>(json['status']),
  startDate = Timestamp.fromJson(json['startDate']),
  deadline = Timestamp.fromJson(json['deadline']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotTasks otherTyped = other as ListWorkspaceSnapshotTasks;
    return id == otherTyped.id && 
    taskCode == otherTyped.taskCode && 
    title == otherTyped.title && 
    description == otherTyped.description && 
    projectId == otherTyped.projectId && 
    projectName == otherTyped.projectName && 
    assignedEmployee == otherTyped.assignedEmployee && 
    priority == otherTyped.priority && 
    status == otherTyped.status && 
    startDate == otherTyped.startDate && 
    deadline == otherTyped.deadline;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, taskCode.hashCode, title.hashCode, description.hashCode, projectId.hashCode, projectName.hashCode, assignedEmployee.hashCode, priority.hashCode, status.hashCode, startDate.hashCode, deadline.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['taskCode'] = nativeToJson<String>(taskCode);
    json['title'] = nativeToJson<String>(title);
    if (description != null) {
      json['description'] = nativeToJson<String?>(description);
    }
    json['projectId'] = nativeToJson<String>(projectId);
    json['projectName'] = nativeToJson<String>(projectName);
    json['assignedEmployee'] = nativeToJson<String>(assignedEmployee);
    json['priority'] = nativeToJson<String>(priority);
    json['status'] = nativeToJson<String>(status);
    json['startDate'] = startDate.toJson();
    json['deadline'] = deadline.toJson();
    return json;
  }

  ListWorkspaceSnapshotTasks({
    required this.id,
    required this.taskCode,
    required this.title,
    this.description,
    required this.projectId,
    required this.projectName,
    required this.assignedEmployee,
    required this.priority,
    required this.status,
    required this.startDate,
    required this.deadline,
  });
}

@immutable
class ListWorkspaceSnapshotMeetings {
  final String id;
  final String meetingCode;
  final String title;
  final String clientOrCompany;
  final Timestamp startTime;
  final Timestamp endTime;
  final String meetingType;
  final String location;
  final String? onlineMeetingLink;
  final String assignedEmployee;
  final String? notes;
  ListWorkspaceSnapshotMeetings.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  meetingCode = nativeFromJson<String>(json['meetingCode']),
  title = nativeFromJson<String>(json['title']),
  clientOrCompany = nativeFromJson<String>(json['clientOrCompany']),
  startTime = Timestamp.fromJson(json['startTime']),
  endTime = Timestamp.fromJson(json['endTime']),
  meetingType = nativeFromJson<String>(json['meetingType']),
  location = nativeFromJson<String>(json['location']),
  onlineMeetingLink = json['onlineMeetingLink'] == null ? null : nativeFromJson<String>(json['onlineMeetingLink']),
  assignedEmployee = nativeFromJson<String>(json['assignedEmployee']),
  notes = json['notes'] == null ? null : nativeFromJson<String>(json['notes']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotMeetings otherTyped = other as ListWorkspaceSnapshotMeetings;
    return id == otherTyped.id && 
    meetingCode == otherTyped.meetingCode && 
    title == otherTyped.title && 
    clientOrCompany == otherTyped.clientOrCompany && 
    startTime == otherTyped.startTime && 
    endTime == otherTyped.endTime && 
    meetingType == otherTyped.meetingType && 
    location == otherTyped.location && 
    onlineMeetingLink == otherTyped.onlineMeetingLink && 
    assignedEmployee == otherTyped.assignedEmployee && 
    notes == otherTyped.notes;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, meetingCode.hashCode, title.hashCode, clientOrCompany.hashCode, startTime.hashCode, endTime.hashCode, meetingType.hashCode, location.hashCode, onlineMeetingLink.hashCode, assignedEmployee.hashCode, notes.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['meetingCode'] = nativeToJson<String>(meetingCode);
    json['title'] = nativeToJson<String>(title);
    json['clientOrCompany'] = nativeToJson<String>(clientOrCompany);
    json['startTime'] = startTime.toJson();
    json['endTime'] = endTime.toJson();
    json['meetingType'] = nativeToJson<String>(meetingType);
    json['location'] = nativeToJson<String>(location);
    if (onlineMeetingLink != null) {
      json['onlineMeetingLink'] = nativeToJson<String?>(onlineMeetingLink);
    }
    json['assignedEmployee'] = nativeToJson<String>(assignedEmployee);
    if (notes != null) {
      json['notes'] = nativeToJson<String?>(notes);
    }
    return json;
  }

  ListWorkspaceSnapshotMeetings({
    required this.id,
    required this.meetingCode,
    required this.title,
    required this.clientOrCompany,
    required this.startTime,
    required this.endTime,
    required this.meetingType,
    required this.location,
    this.onlineMeetingLink,
    required this.assignedEmployee,
    this.notes,
  });
}

@immutable
class ListWorkspaceSnapshotInvoices {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final String projectName;
  final String serviceCategory;
  final Timestamp issueDate;
  final Timestamp dueDate;
  final double totalAmountInr;
  final double paidAmountInr;
  final String status;
  ListWorkspaceSnapshotInvoices.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  invoiceNumber = nativeFromJson<String>(json['invoiceNumber']),
  clientName = nativeFromJson<String>(json['clientName']),
  projectName = nativeFromJson<String>(json['projectName']),
  serviceCategory = nativeFromJson<String>(json['serviceCategory']),
  issueDate = Timestamp.fromJson(json['issueDate']),
  dueDate = Timestamp.fromJson(json['dueDate']),
  totalAmountInr = nativeFromJson<double>(json['totalAmountInr']),
  paidAmountInr = nativeFromJson<double>(json['paidAmountInr']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotInvoices otherTyped = other as ListWorkspaceSnapshotInvoices;
    return id == otherTyped.id && 
    invoiceNumber == otherTyped.invoiceNumber && 
    clientName == otherTyped.clientName && 
    projectName == otherTyped.projectName && 
    serviceCategory == otherTyped.serviceCategory && 
    issueDate == otherTyped.issueDate && 
    dueDate == otherTyped.dueDate && 
    totalAmountInr == otherTyped.totalAmountInr && 
    paidAmountInr == otherTyped.paidAmountInr && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, invoiceNumber.hashCode, clientName.hashCode, projectName.hashCode, serviceCategory.hashCode, issueDate.hashCode, dueDate.hashCode, totalAmountInr.hashCode, paidAmountInr.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['invoiceNumber'] = nativeToJson<String>(invoiceNumber);
    json['clientName'] = nativeToJson<String>(clientName);
    json['projectName'] = nativeToJson<String>(projectName);
    json['serviceCategory'] = nativeToJson<String>(serviceCategory);
    json['issueDate'] = issueDate.toJson();
    json['dueDate'] = dueDate.toJson();
    json['totalAmountInr'] = nativeToJson<double>(totalAmountInr);
    json['paidAmountInr'] = nativeToJson<double>(paidAmountInr);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  ListWorkspaceSnapshotInvoices({
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
}

@immutable
class ListWorkspaceSnapshotChatThreads {
  final String id;
  final String name;
  final String subtitle;
  final bool isChannel;
  final bool isPrivate;
  final int unreadCount;
  final int membersCount;
  final String lastMessagePreview;
  final Timestamp lastActivity;
  ListWorkspaceSnapshotChatThreads.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  name = nativeFromJson<String>(json['name']),
  subtitle = nativeFromJson<String>(json['subtitle']),
  isChannel = nativeFromJson<bool>(json['isChannel']),
  isPrivate = nativeFromJson<bool>(json['isPrivate']),
  unreadCount = nativeFromJson<int>(json['unreadCount']),
  membersCount = nativeFromJson<int>(json['membersCount']),
  lastMessagePreview = nativeFromJson<String>(json['lastMessagePreview']),
  lastActivity = Timestamp.fromJson(json['lastActivity']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotChatThreads otherTyped = other as ListWorkspaceSnapshotChatThreads;
    return id == otherTyped.id && 
    name == otherTyped.name && 
    subtitle == otherTyped.subtitle && 
    isChannel == otherTyped.isChannel && 
    isPrivate == otherTyped.isPrivate && 
    unreadCount == otherTyped.unreadCount && 
    membersCount == otherTyped.membersCount && 
    lastMessagePreview == otherTyped.lastMessagePreview && 
    lastActivity == otherTyped.lastActivity;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, name.hashCode, subtitle.hashCode, isChannel.hashCode, isPrivate.hashCode, unreadCount.hashCode, membersCount.hashCode, lastMessagePreview.hashCode, lastActivity.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['name'] = nativeToJson<String>(name);
    json['subtitle'] = nativeToJson<String>(subtitle);
    json['isChannel'] = nativeToJson<bool>(isChannel);
    json['isPrivate'] = nativeToJson<bool>(isPrivate);
    json['unreadCount'] = nativeToJson<int>(unreadCount);
    json['membersCount'] = nativeToJson<int>(membersCount);
    json['lastMessagePreview'] = nativeToJson<String>(lastMessagePreview);
    json['lastActivity'] = lastActivity.toJson();
    return json;
  }

  ListWorkspaceSnapshotChatThreads({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.isChannel,
    required this.isPrivate,
    required this.unreadCount,
    required this.membersCount,
    required this.lastMessagePreview,
    required this.lastActivity,
  });
}

@immutable
class ListWorkspaceSnapshotChatMessages {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String body;
  final Timestamp timestamp;
  final String messageType;
  final String? attachmentName;
  final int? voiceDurationSec;
  final String? replyToSender;
  final String? replyToPreview;
  final bool isPinned;
  ListWorkspaceSnapshotChatMessages.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  threadId = nativeFromJson<String>(json['threadId']),
  senderId = nativeFromJson<String>(json['senderId']),
  senderName = nativeFromJson<String>(json['senderName']),
  senderRole = nativeFromJson<String>(json['senderRole']),
  body = nativeFromJson<String>(json['body']),
  timestamp = Timestamp.fromJson(json['timestamp']),
  messageType = nativeFromJson<String>(json['messageType']),
  attachmentName = json['attachmentName'] == null ? null : nativeFromJson<String>(json['attachmentName']),
  voiceDurationSec = json['voiceDurationSec'] == null ? null : nativeFromJson<int>(json['voiceDurationSec']),
  replyToSender = json['replyToSender'] == null ? null : nativeFromJson<String>(json['replyToSender']),
  replyToPreview = json['replyToPreview'] == null ? null : nativeFromJson<String>(json['replyToPreview']),
  isPinned = nativeFromJson<bool>(json['isPinned']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotChatMessages otherTyped = other as ListWorkspaceSnapshotChatMessages;
    return id == otherTyped.id && 
    threadId == otherTyped.threadId && 
    senderId == otherTyped.senderId && 
    senderName == otherTyped.senderName && 
    senderRole == otherTyped.senderRole && 
    body == otherTyped.body && 
    timestamp == otherTyped.timestamp && 
    messageType == otherTyped.messageType && 
    attachmentName == otherTyped.attachmentName && 
    voiceDurationSec == otherTyped.voiceDurationSec && 
    replyToSender == otherTyped.replyToSender && 
    replyToPreview == otherTyped.replyToPreview && 
    isPinned == otherTyped.isPinned;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, threadId.hashCode, senderId.hashCode, senderName.hashCode, senderRole.hashCode, body.hashCode, timestamp.hashCode, messageType.hashCode, attachmentName.hashCode, voiceDurationSec.hashCode, replyToSender.hashCode, replyToPreview.hashCode, isPinned.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['threadId'] = nativeToJson<String>(threadId);
    json['senderId'] = nativeToJson<String>(senderId);
    json['senderName'] = nativeToJson<String>(senderName);
    json['senderRole'] = nativeToJson<String>(senderRole);
    json['body'] = nativeToJson<String>(body);
    json['timestamp'] = timestamp.toJson();
    json['messageType'] = nativeToJson<String>(messageType);
    if (attachmentName != null) {
      json['attachmentName'] = nativeToJson<String?>(attachmentName);
    }
    if (voiceDurationSec != null) {
      json['voiceDurationSec'] = nativeToJson<int?>(voiceDurationSec);
    }
    if (replyToSender != null) {
      json['replyToSender'] = nativeToJson<String?>(replyToSender);
    }
    if (replyToPreview != null) {
      json['replyToPreview'] = nativeToJson<String?>(replyToPreview);
    }
    json['isPinned'] = nativeToJson<bool>(isPinned);
    return json;
  }

  ListWorkspaceSnapshotChatMessages({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.body,
    required this.timestamp,
    required this.messageType,
    this.attachmentName,
    this.voiceDurationSec,
    this.replyToSender,
    this.replyToPreview,
    required this.isPinned,
  });
}

@immutable
class ListWorkspaceSnapshotData {
  final List<ListWorkspaceSnapshotFounders> founders;
  final List<ListWorkspaceSnapshotLeads> leads;
  final List<ListWorkspaceSnapshotClients> clients;
  final List<ListWorkspaceSnapshotProjects> projects;
  final List<ListWorkspaceSnapshotTasks> tasks;
  final List<ListWorkspaceSnapshotMeetings> meetings;
  final List<ListWorkspaceSnapshotInvoices> invoices;
  final List<ListWorkspaceSnapshotChatThreads> chatThreads;
  final List<ListWorkspaceSnapshotChatMessages> chatMessages;
  ListWorkspaceSnapshotData.fromJson(dynamic json):
  
  founders = (json['founders'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotFounders.fromJson(e))
        .toList(),
  leads = (json['leads'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotLeads.fromJson(e))
        .toList(),
  clients = (json['clients'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotClients.fromJson(e))
        .toList(),
  projects = (json['projects'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotProjects.fromJson(e))
        .toList(),
  tasks = (json['tasks'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotTasks.fromJson(e))
        .toList(),
  meetings = (json['meetings'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotMeetings.fromJson(e))
        .toList(),
  invoices = (json['invoices'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotInvoices.fromJson(e))
        .toList(),
  chatThreads = (json['chatThreads'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotChatThreads.fromJson(e))
        .toList(),
  chatMessages = (json['chatMessages'] as List<dynamic>)
        .map((e) => ListWorkspaceSnapshotChatMessages.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListWorkspaceSnapshotData otherTyped = other as ListWorkspaceSnapshotData;
    return founders == otherTyped.founders && 
    leads == otherTyped.leads && 
    clients == otherTyped.clients && 
    projects == otherTyped.projects && 
    tasks == otherTyped.tasks && 
    meetings == otherTyped.meetings && 
    invoices == otherTyped.invoices && 
    chatThreads == otherTyped.chatThreads && 
    chatMessages == otherTyped.chatMessages;
    
  }
  @override
  int get hashCode => Object.hashAll([founders.hashCode, leads.hashCode, clients.hashCode, projects.hashCode, tasks.hashCode, meetings.hashCode, invoices.hashCode, chatThreads.hashCode, chatMessages.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['founders'] = founders.map((e) => e.toJson()).toList();
    json['leads'] = leads.map((e) => e.toJson()).toList();
    json['clients'] = clients.map((e) => e.toJson()).toList();
    json['projects'] = projects.map((e) => e.toJson()).toList();
    json['tasks'] = tasks.map((e) => e.toJson()).toList();
    json['meetings'] = meetings.map((e) => e.toJson()).toList();
    json['invoices'] = invoices.map((e) => e.toJson()).toList();
    json['chatThreads'] = chatThreads.map((e) => e.toJson()).toList();
    json['chatMessages'] = chatMessages.map((e) => e.toJson()).toList();
    return json;
  }

  ListWorkspaceSnapshotData({
    required this.founders,
    required this.leads,
    required this.clients,
    required this.projects,
    required this.tasks,
    required this.meetings,
    required this.invoices,
    required this.chatThreads,
    required this.chatMessages,
  });
}

