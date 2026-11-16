part of 'blue_hour_mobile.dart';

class UpsertInvoiceVariablesBuilder {
  String id;
  String invoiceNumber;
  String clientName;
  String projectName;
  String serviceCategory;
  Timestamp dueDate;
  double totalAmountInr;
  double paidAmountInr;
  String status;

  final FirebaseDataConnect _dataConnect;
  UpsertInvoiceVariablesBuilder(this._dataConnect, {required  this.id,required  this.invoiceNumber,required  this.clientName,required  this.projectName,required  this.serviceCategory,required  this.dueDate,required  this.totalAmountInr,required  this.paidAmountInr,required  this.status,});
  Deserializer<UpsertInvoiceData> dataDeserializer = (dynamic json)  => UpsertInvoiceData.fromJson(jsonDecode(json));
  Serializer<UpsertInvoiceVariables> varsSerializer = (UpsertInvoiceVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpsertInvoiceData, UpsertInvoiceVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpsertInvoiceData, UpsertInvoiceVariables> ref() {
    UpsertInvoiceVariables vars= UpsertInvoiceVariables(id: id,invoiceNumber: invoiceNumber,clientName: clientName,projectName: projectName,serviceCategory: serviceCategory,dueDate: dueDate,totalAmountInr: totalAmountInr,paidAmountInr: paidAmountInr,status: status,);
    return _dataConnect.mutation("UpsertInvoice", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpsertInvoiceInvoiceUpsert {
  final String id;
  UpsertInvoiceInvoiceUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertInvoiceInvoiceUpsert otherTyped = other as UpsertInvoiceInvoiceUpsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  UpsertInvoiceInvoiceUpsert({
    required this.id,
  });
}

@immutable
class UpsertInvoiceData {
  final UpsertInvoiceInvoiceUpsert invoice_upsert;
  UpsertInvoiceData.fromJson(dynamic json):
  
  invoice_upsert = UpsertInvoiceInvoiceUpsert.fromJson(json['invoice_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpsertInvoiceData otherTyped = other as UpsertInvoiceData;
    return invoice_upsert == otherTyped.invoice_upsert;
    
  }
  @override
  int get hashCode => invoice_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['invoice_upsert'] = invoice_upsert.toJson();
    return json;
  }

  UpsertInvoiceData({
    required this.invoice_upsert,
  });
}

@immutable
class UpsertInvoiceVariables {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final String projectName;
  final String serviceCategory;
  final Timestamp dueDate;
  final double totalAmountInr;
  final double paidAmountInr;
  final String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpsertInvoiceVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  invoiceNumber = nativeFromJson<String>(json['invoiceNumber']),
  clientName = nativeFromJson<String>(json['clientName']),
  projectName = nativeFromJson<String>(json['projectName']),
  serviceCategory = nativeFromJson<String>(json['serviceCategory']),
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

    final UpsertInvoiceVariables otherTyped = other as UpsertInvoiceVariables;
    return id == otherTyped.id && 
    invoiceNumber == otherTyped.invoiceNumber && 
    clientName == otherTyped.clientName && 
    projectName == otherTyped.projectName && 
    serviceCategory == otherTyped.serviceCategory && 
    dueDate == otherTyped.dueDate && 
    totalAmountInr == otherTyped.totalAmountInr && 
    paidAmountInr == otherTyped.paidAmountInr && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, invoiceNumber.hashCode, clientName.hashCode, projectName.hashCode, serviceCategory.hashCode, dueDate.hashCode, totalAmountInr.hashCode, paidAmountInr.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['invoiceNumber'] = nativeToJson<String>(invoiceNumber);
    json['clientName'] = nativeToJson<String>(clientName);
    json['projectName'] = nativeToJson<String>(projectName);
    json['serviceCategory'] = nativeToJson<String>(serviceCategory);
    json['dueDate'] = dueDate.toJson();
    json['totalAmountInr'] = nativeToJson<double>(totalAmountInr);
    json['paidAmountInr'] = nativeToJson<double>(paidAmountInr);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  UpsertInvoiceVariables({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.projectName,
    required this.serviceCategory,
    required this.dueDate,
    required this.totalAmountInr,
    required this.paidAmountInr,
    required this.status,
  });
}

