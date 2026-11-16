part of 'blue_hour_mobile.dart';

class ListFoundersVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListFoundersVariablesBuilder(this._dataConnect, );
  Deserializer<ListFoundersData> dataDeserializer = (dynamic json)  => ListFoundersData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListFoundersData, void>> execute() {
    return ref().execute();
  }

  QueryRef<ListFoundersData, void> ref() {
    
    return _dataConnect.query("ListFounders", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListFoundersFounders {
  final String id;
  final String employeeCode;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isSuperAdmin;
  final String department;
  final String designation;
  final bool isOnline;
  final bool twoFactorEnabled;
  final String briefingTime;
  ListFoundersFounders.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  employeeCode = nativeFromJson<String>(json['employeeCode']),
  name = nativeFromJson<String>(json['name']),
  email = nativeFromJson<String>(json['email']),
  phone = nativeFromJson<String>(json['phone']),
  role = nativeFromJson<String>(json['role']),
  isSuperAdmin = nativeFromJson<bool>(json['isSuperAdmin']),
  department = nativeFromJson<String>(json['department']),
  designation = nativeFromJson<String>(json['designation']),
  isOnline = nativeFromJson<bool>(json['isOnline']),
  twoFactorEnabled = nativeFromJson<bool>(json['twoFactorEnabled']),
  briefingTime = nativeFromJson<String>(json['briefingTime']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListFoundersFounders otherTyped = other as ListFoundersFounders;
    return id == otherTyped.id && 
    employeeCode == otherTyped.employeeCode && 
    name == otherTyped.name && 
    email == otherTyped.email && 
    phone == otherTyped.phone && 
    role == otherTyped.role && 
    isSuperAdmin == otherTyped.isSuperAdmin && 
    department == otherTyped.department && 
    designation == otherTyped.designation && 
    isOnline == otherTyped.isOnline && 
    twoFactorEnabled == otherTyped.twoFactorEnabled && 
    briefingTime == otherTyped.briefingTime;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, employeeCode.hashCode, name.hashCode, email.hashCode, phone.hashCode, role.hashCode, isSuperAdmin.hashCode, department.hashCode, designation.hashCode, isOnline.hashCode, twoFactorEnabled.hashCode, briefingTime.hashCode]);
  

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
    json['isOnline'] = nativeToJson<bool>(isOnline);
    json['twoFactorEnabled'] = nativeToJson<bool>(twoFactorEnabled);
    json['briefingTime'] = nativeToJson<String>(briefingTime);
    return json;
  }

  ListFoundersFounders({
    required this.id,
    required this.employeeCode,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isSuperAdmin,
    required this.department,
    required this.designation,
    required this.isOnline,
    required this.twoFactorEnabled,
    required this.briefingTime,
  });
}

@immutable
class ListFoundersData {
  final List<ListFoundersFounders> founders;
  ListFoundersData.fromJson(dynamic json):
  
  founders = (json['founders'] as List<dynamic>)
        .map((e) => ListFoundersFounders.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListFoundersData otherTyped = other as ListFoundersData;
    return founders == otherTyped.founders;
    
  }
  @override
  int get hashCode => founders.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['founders'] = founders.map((e) => e.toJson()).toList();
    return json;
  }

  ListFoundersData({
    required this.founders,
  });
}

