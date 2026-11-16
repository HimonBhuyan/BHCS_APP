part of 'blue_hour_mobile.dart';

class UpsertProjectVariablesBuilder {
  String id;
  String projectCode;
  String name;
  String clientName;
  String category;
  Optional<String> _description = Optional.optional(nativeFromJson, nativeToJson);
  String projectManager;
  Timestamp deadline;
  double budgetInr;
  String status;
  int progressPercentage;

  final FirebaseDataConnect _dataConnect;  UpsertProjectVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  UpsertProjectVariablesBuilder(this._dataConnect, {required  this.id,required  this.projectCode,required  this.name,required  this.clientName,required  this.category,required  this.projectManager,required  this.deadline,required  this.budgetInr,required  this.status,required  this.progressPercentage,});
  Deserializer<UpsertProjectData> dataDeserializer = (dynamic json)  => UpsertProjectData.fromJson(jsonDecode(json));
  Serializer<UpsertProjectVariables> varsSerializer = (UpsertProjectVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertProjectData, UpsertProjectVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertProjectData, UpsertProjectVariables> ref() {
    UpsertProjectVariables vars= UpsertProjectVariables(id: id,projectCode: projectCode,name: name,clientName: clientName,category: category,description: _description,projectManager: projectManager,deadline: deadline,budgetInr: budgetInr,status: status,progressPercentage: progressPercentage,);
    return _dataConnect.mutation("UpsertProject", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertProjectProjectUpsert {
  final String id;
  UpsertProjectProjectUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertProjectProjectUpsert otherTyped = other as UpsertProjectProjectUpsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpsertProjectProjectUpsert({
    required this.id,
  });
}

@immutable
class UpsertProjectData {
  final UpsertProjectProjectUpsert project_upsert;
  UpsertProjectData.fromJson(dynamic json):
  
  project_upsert = UpsertProjectProjectUpsert.fromJson(json['project_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertProjectData otherTyped = other as UpsertProjectData;
    return project_upsert == otherTyped.project_upsert;
    
  }
  @override
  int get hashCode => project_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['project_upsert'] = project_upsert.toJson();
    return json;
  }

  UpsertProjectData({
    required this.project_upsert,
  });
}

@immutable
class UpsertProjectVariables {
  final String id;
  final String projectCode;
  final String name;
  final String clientName;
  final String category;
  late final Optional<String>description;
  final String projectManager;
  final Timestamp deadline;
  final double budgetInr;
  final String status;
  final int progressPercentage;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertProjectVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  projectCode = nativeFromJson<String>(json['projectCode']),
  name = nativeFromJson<String>(json['name']),
  clientName = nativeFromJson<String>(json['clientName']),
  category = nativeFromJson<String>(json['category']),
  projectManager = nativeFromJson<String>(json['projectManager']),
  deadline = Timestamp.fromJson(json['deadline']),
  budgetInr = nativeFromJson<double>(json['budgetInr']),
  status = nativeFromJson<String>(json['status']),
  progressPercentage = nativeFromJson<int>(json['progressPercentage']) {
  
  
  
  
  
  
  
    description = Optional.optional(nativeFromJson, nativeToJson);
    description.value = json['description'] == null ? null : nativeFromJson<String>(json['description']);
  
  
  
  
  
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertProjectVariables otherTyped = other as UpsertProjectVariables;
    return id == otherTyped.id && 
    projectCode == otherTyped.projectCode && 
    name == otherTyped.name && 
    clientName == otherTyped.clientName && 
    category == otherTyped.category && 
    description == otherTyped.description && 
    projectManager == otherTyped.projectManager && 
    deadline == otherTyped.deadline && 
    budgetInr == otherTyped.budgetInr && 
    status == otherTyped.status && 
    progressPercentage == otherTyped.progressPercentage;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, projectCode.hashCode, name.hashCode, clientName.hashCode, category.hashCode, description.hashCode, projectManager.hashCode, deadline.hashCode, budgetInr.hashCode, status.hashCode, progressPercentage.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['projectCode'] = nativeToJson<String>(projectCode);
    json['name'] = nativeToJson<String>(name);
    json['clientName'] = nativeToJson<String>(clientName);
    json['category'] = nativeToJson<String>(category);
    if(description.state == OptionalState.set) {
      json['description'] = description.toJson();
    }
    json['projectManager'] = nativeToJson<String>(projectManager);
    json['deadline'] = deadline.toJson();
    json['budgetInr'] = nativeToJson<double>(budgetInr);
    json['status'] = nativeToJson<String>(status);
    json['progressPercentage'] = nativeToJson<int>(progressPercentage);
    return json;
  }

  UpsertProjectVariables({
    required this.id,
    required this.projectCode,
    required this.name,
    required this.clientName,
    required this.category,
    required this.description,
    required this.projectManager,
    required this.deadline,
    required this.budgetInr,
    required this.status,
    required this.progressPercentage,
  });
}

