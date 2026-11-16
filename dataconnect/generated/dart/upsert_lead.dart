part of 'blue_hour_mobile.dart';

class UpsertLeadVariablesBuilder {
  String id;
  String leadCode;
  String companyName;
  String contactPerson;
  String phone;
  String email;
  String location;
  String industry;
  String source;
  String interestedService;
  double estimatedBudgetInr;
  String assignedEmployeeName;
  String priority;
  String status;
  Timestamp expectedClosingDate;
  Optional<String> _notes = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  UpsertLeadVariablesBuilder notes(String? t) {
   _notes.value = t;
   return this;
  }

  UpsertLeadVariablesBuilder(this._dataConnect, {required  this.id,required  this.leadCode,required  this.companyName,required  this.contactPerson,required  this.phone,required  this.email,required  this.location,required  this.industry,required  this.source,required  this.interestedService,required  this.estimatedBudgetInr,required  this.assignedEmployeeName,required  this.priority,required  this.status,required  this.expectedClosingDate,});
  Deserializer<UpsertLeadData> dataDeserializer = (dynamic json)  => UpsertLeadData.fromJson(jsonDecode(json));
  Serializer<UpsertLeadVariables> varsSerializer = (UpsertLeadVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertLeadData, UpsertLeadVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertLeadData, UpsertLeadVariables> ref() {
    UpsertLeadVariables vars= UpsertLeadVariables(id: id,leadCode: leadCode,companyName: companyName,contactPerson: contactPerson,phone: phone,email: email,location: location,industry: industry,source: source,interestedService: interestedService,estimatedBudgetInr: estimatedBudgetInr,assignedEmployeeName: assignedEmployeeName,priority: priority,status: status,expectedClosingDate: expectedClosingDate,notes: _notes,);
    return _dataConnect.mutation("UpsertLead", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertLeadLeadUpsert {
  final String id;
  UpsertLeadLeadUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertLeadLeadUpsert otherTyped = other as UpsertLeadLeadUpsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpsertLeadLeadUpsert({
    required this.id,
  });
}

@immutable
class UpsertLeadData {
  final UpsertLeadLeadUpsert lead_upsert;
  UpsertLeadData.fromJson(dynamic json):
  
  lead_upsert = UpsertLeadLeadUpsert.fromJson(json['lead_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertLeadData otherTyped = other as UpsertLeadData;
    return lead_upsert == otherTyped.lead_upsert;
    
  }
  @override
  int get hashCode => lead_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['lead_upsert'] = lead_upsert.toJson();
    return json;
  }

  UpsertLeadData({
    required this.lead_upsert,
  });
}

@immutable
class UpsertLeadVariables {
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
  late final Optional<String>notes;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertLeadVariables.fromJson(Map<String, dynamic> json):
  
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
  expectedClosingDate = Timestamp.fromJson(json['expectedClosingDate']) {
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
    notes = Optional.optional(nativeFromJson, nativeToJson);
    notes.value = json['notes'] == null ? null : nativeFromJson<String>(json['notes']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertLeadVariables otherTyped = other as UpsertLeadVariables;
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
    notes == otherTyped.notes;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, leadCode.hashCode, companyName.hashCode, contactPerson.hashCode, phone.hashCode, email.hashCode, location.hashCode, industry.hashCode, source.hashCode, interestedService.hashCode, estimatedBudgetInr.hashCode, assignedEmployeeName.hashCode, priority.hashCode, status.hashCode, expectedClosingDate.hashCode, notes.hashCode]);
  

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
    if(notes.state == OptionalState.set) {
      json['notes'] = notes.toJson();
    }
    return json;
  }

  UpsertLeadVariables({
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
    required this.notes,
  });
}

