library blue_hour_dataconnect;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'send_founder_chat_message.dart';

part 'upsert_lead.dart';

part 'upsert_project.dart';

part 'upsert_invoice.dart';

part 'list_founders.dart';

part 'list_workspace_snapshot.dart';







class BlueHourMobileConnector {
  
  
  SendFounderChatMessageVariablesBuilder sendFounderChatMessage ({required String id, required String threadId, required String senderId, required String senderName, required String senderRole, required String body, required String messageType, }) {
    return SendFounderChatMessageVariablesBuilder(dataConnect, id: id,threadId: threadId,senderId: senderId,senderName: senderName,senderRole: senderRole,body: body,messageType: messageType,);
  }
  
  
  UpsertLeadVariablesBuilder upsertLead ({required String id, required String leadCode, required String companyName, required String contactPerson, required String phone, required String email, required String location, required String industry, required String source, required String interestedService, required double estimatedBudgetInr, required String assignedEmployeeName, required String priority, required String status, required Timestamp expectedClosingDate, }) {
    return UpsertLeadVariablesBuilder(dataConnect, id: id,leadCode: leadCode,companyName: companyName,contactPerson: contactPerson,phone: phone,email: email,location: location,industry: industry,source: source,interestedService: interestedService,estimatedBudgetInr: estimatedBudgetInr,assignedEmployeeName: assignedEmployeeName,priority: priority,status: status,expectedClosingDate: expectedClosingDate,);
  }
  
  
  UpsertProjectVariablesBuilder upsertProject ({required String id, required String projectCode, required String name, required String clientName, required String category, required String projectManager, required Timestamp deadline, required double budgetInr, required String status, required int progressPercentage, }) {
    return UpsertProjectVariablesBuilder(dataConnect, id: id,projectCode: projectCode,name: name,clientName: clientName,category: category,projectManager: projectManager,deadline: deadline,budgetInr: budgetInr,status: status,progressPercentage: progressPercentage,);
  }
  
  
  UpsertInvoiceVariablesBuilder upsertInvoice ({required String id, required String invoiceNumber, required String clientName, required String projectName, required String serviceCategory, required Timestamp dueDate, required double totalAmountInr, required double paidAmountInr, required String status, }) {
    return UpsertInvoiceVariablesBuilder(dataConnect, id: id,invoiceNumber: invoiceNumber,clientName: clientName,projectName: projectName,serviceCategory: serviceCategory,dueDate: dueDate,totalAmountInr: totalAmountInr,paidAmountInr: paidAmountInr,status: status,);
  }
  
  
  ListFoundersVariablesBuilder listFounders () {
    return ListFoundersVariablesBuilder(dataConnect, );
  }
  
  
  ListWorkspaceSnapshotVariablesBuilder listWorkspaceSnapshot () {
    return ListWorkspaceSnapshotVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'asia-south1',
    'blue-hour-mobile',
    'blue-hour-hq-sql',
  );

  BlueHourMobileConnector({required this.dataConnect});
  static BlueHourMobileConnector get instance {
    
    return BlueHourMobileConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
