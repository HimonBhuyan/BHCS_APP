# blue_hour_dataconnect SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
BlueHourMobileConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### ListFounders
#### Required Arguments
```dart
// No required arguments
BlueHourMobileConnector.instance.listFounders().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListFoundersData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await BlueHourMobileConnector.instance.listFounders();
ListFoundersData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = BlueHourMobileConnector.instance.listFounders().ref();
ref.execute();

ref.subscribe(...);
```


### ListWorkspaceSnapshot
#### Required Arguments
```dart
// No required arguments
BlueHourMobileConnector.instance.listWorkspaceSnapshot().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListWorkspaceSnapshotData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await BlueHourMobileConnector.instance.listWorkspaceSnapshot();
ListWorkspaceSnapshotData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = BlueHourMobileConnector.instance.listWorkspaceSnapshot().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### SendFounderChatMessage
#### Required Arguments
```dart
String id = ...;
String threadId = ...;
String senderId = ...;
String senderName = ...;
String senderRole = ...;
String body = ...;
String messageType = ...;
BlueHourMobileConnector.instance.sendFounderChatMessage(
  id: id,
  threadId: threadId,
  senderId: senderId,
  senderName: senderName,
  senderRole: senderRole,
  body: body,
  messageType: messageType,
).execute();
```

#### Optional Arguments
We return a builder for each query. For SendFounderChatMessage, we created `SendFounderChatMessageBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class SendFounderChatMessageVariablesBuilder {
  ...
   SendFounderChatMessageVariablesBuilder attachmentName(String? t) {
   _attachmentName.value = t;
   return this;
  }
  SendFounderChatMessageVariablesBuilder voiceDurationSec(int? t) {
   _voiceDurationSec.value = t;
   return this;
  }
  SendFounderChatMessageVariablesBuilder replyToSender(String? t) {
   _replyToSender.value = t;
   return this;
  }
  SendFounderChatMessageVariablesBuilder replyToPreview(String? t) {
   _replyToPreview.value = t;
   return this;
  }

  ...
}
BlueHourMobileConnector.instance.sendFounderChatMessage(
  id: id,
  threadId: threadId,
  senderId: senderId,
  senderName: senderName,
  senderRole: senderRole,
  body: body,
  messageType: messageType,
)
.attachmentName(attachmentName)
.voiceDurationSec(voiceDurationSec)
.replyToSender(replyToSender)
.replyToPreview(replyToPreview)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<SendFounderChatMessageData, SendFounderChatMessageVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await BlueHourMobileConnector.instance.sendFounderChatMessage(
  id: id,
  threadId: threadId,
  senderId: senderId,
  senderName: senderName,
  senderRole: senderRole,
  body: body,
  messageType: messageType,
);
SendFounderChatMessageData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String threadId = ...;
String senderId = ...;
String senderName = ...;
String senderRole = ...;
String body = ...;
String messageType = ...;

final ref = BlueHourMobileConnector.instance.sendFounderChatMessage(
  id: id,
  threadId: threadId,
  senderId: senderId,
  senderName: senderName,
  senderRole: senderRole,
  body: body,
  messageType: messageType,
).ref();
ref.execute();
```


### UpsertLead
#### Required Arguments
```dart
String id = ...;
String leadCode = ...;
String companyName = ...;
String contactPerson = ...;
String phone = ...;
String email = ...;
String location = ...;
String industry = ...;
String source = ...;
String interestedService = ...;
double estimatedBudgetInr = ...;
String assignedEmployeeName = ...;
String priority = ...;
String status = ...;
Timestamp expectedClosingDate = ...;
BlueHourMobileConnector.instance.upsertLead(
  id: id,
  leadCode: leadCode,
  companyName: companyName,
  contactPerson: contactPerson,
  phone: phone,
  email: email,
  location: location,
  industry: industry,
  source: source,
  interestedService: interestedService,
  estimatedBudgetInr: estimatedBudgetInr,
  assignedEmployeeName: assignedEmployeeName,
  priority: priority,
  status: status,
  expectedClosingDate: expectedClosingDate,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpsertLead, we created `UpsertLeadBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpsertLeadVariablesBuilder {
  ...
   UpsertLeadVariablesBuilder notes(String? t) {
   _notes.value = t;
   return this;
  }

  ...
}
BlueHourMobileConnector.instance.upsertLead(
  id: id,
  leadCode: leadCode,
  companyName: companyName,
  contactPerson: contactPerson,
  phone: phone,
  email: email,
  location: location,
  industry: industry,
  source: source,
  interestedService: interestedService,
  estimatedBudgetInr: estimatedBudgetInr,
  assignedEmployeeName: assignedEmployeeName,
  priority: priority,
  status: status,
  expectedClosingDate: expectedClosingDate,
)
.notes(notes)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpsertLeadData, UpsertLeadVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await BlueHourMobileConnector.instance.upsertLead(
  id: id,
  leadCode: leadCode,
  companyName: companyName,
  contactPerson: contactPerson,
  phone: phone,
  email: email,
  location: location,
  industry: industry,
  source: source,
  interestedService: interestedService,
  estimatedBudgetInr: estimatedBudgetInr,
  assignedEmployeeName: assignedEmployeeName,
  priority: priority,
  status: status,
  expectedClosingDate: expectedClosingDate,
);
UpsertLeadData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String leadCode = ...;
String companyName = ...;
String contactPerson = ...;
String phone = ...;
String email = ...;
String location = ...;
String industry = ...;
String source = ...;
String interestedService = ...;
double estimatedBudgetInr = ...;
String assignedEmployeeName = ...;
String priority = ...;
String status = ...;
Timestamp expectedClosingDate = ...;

final ref = BlueHourMobileConnector.instance.upsertLead(
  id: id,
  leadCode: leadCode,
  companyName: companyName,
  contactPerson: contactPerson,
  phone: phone,
  email: email,
  location: location,
  industry: industry,
  source: source,
  interestedService: interestedService,
  estimatedBudgetInr: estimatedBudgetInr,
  assignedEmployeeName: assignedEmployeeName,
  priority: priority,
  status: status,
  expectedClosingDate: expectedClosingDate,
).ref();
ref.execute();
```


### UpsertProject
#### Required Arguments
```dart
String id = ...;
String projectCode = ...;
String name = ...;
String clientName = ...;
String category = ...;
String projectManager = ...;
Timestamp deadline = ...;
double budgetInr = ...;
String status = ...;
int progressPercentage = ...;
BlueHourMobileConnector.instance.upsertProject(
  id: id,
  projectCode: projectCode,
  name: name,
  clientName: clientName,
  category: category,
  projectManager: projectManager,
  deadline: deadline,
  budgetInr: budgetInr,
  status: status,
  progressPercentage: progressPercentage,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpsertProject, we created `UpsertProjectBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpsertProjectVariablesBuilder {
  ...
   UpsertProjectVariablesBuilder description(String? t) {
   _description.value = t;
   return this;
  }

  ...
}
BlueHourMobileConnector.instance.upsertProject(
  id: id,
  projectCode: projectCode,
  name: name,
  clientName: clientName,
  category: category,
  projectManager: projectManager,
  deadline: deadline,
  budgetInr: budgetInr,
  status: status,
  progressPercentage: progressPercentage,
)
.description(description)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpsertProjectData, UpsertProjectVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await BlueHourMobileConnector.instance.upsertProject(
  id: id,
  projectCode: projectCode,
  name: name,
  clientName: clientName,
  category: category,
  projectManager: projectManager,
  deadline: deadline,
  budgetInr: budgetInr,
  status: status,
  progressPercentage: progressPercentage,
);
UpsertProjectData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String projectCode = ...;
String name = ...;
String clientName = ...;
String category = ...;
String projectManager = ...;
Timestamp deadline = ...;
double budgetInr = ...;
String status = ...;
int progressPercentage = ...;

final ref = BlueHourMobileConnector.instance.upsertProject(
  id: id,
  projectCode: projectCode,
  name: name,
  clientName: clientName,
  category: category,
  projectManager: projectManager,
  deadline: deadline,
  budgetInr: budgetInr,
  status: status,
  progressPercentage: progressPercentage,
).ref();
ref.execute();
```


### UpsertInvoice
#### Required Arguments
```dart
String id = ...;
String invoiceNumber = ...;
String clientName = ...;
String projectName = ...;
String serviceCategory = ...;
Timestamp dueDate = ...;
double totalAmountInr = ...;
double paidAmountInr = ...;
String status = ...;
BlueHourMobileConnector.instance.upsertInvoice(
  id: id,
  invoiceNumber: invoiceNumber,
  clientName: clientName,
  projectName: projectName,
  serviceCategory: serviceCategory,
  dueDate: dueDate,
  totalAmountInr: totalAmountInr,
  paidAmountInr: paidAmountInr,
  status: status,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpsertInvoiceData, UpsertInvoiceVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await BlueHourMobileConnector.instance.upsertInvoice(
  id: id,
  invoiceNumber: invoiceNumber,
  clientName: clientName,
  projectName: projectName,
  serviceCategory: serviceCategory,
  dueDate: dueDate,
  totalAmountInr: totalAmountInr,
  paidAmountInr: paidAmountInr,
  status: status,
);
UpsertInvoiceData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String invoiceNumber = ...;
String clientName = ...;
String projectName = ...;
String serviceCategory = ...;
Timestamp dueDate = ...;
double totalAmountInr = ...;
double paidAmountInr = ...;
String status = ...;

final ref = BlueHourMobileConnector.instance.upsertInvoice(
  id: id,
  invoiceNumber: invoiceNumber,
  clientName: clientName,
  projectName: projectName,
  serviceCategory: serviceCategory,
  dueDate: dueDate,
  totalAmountInr: totalAmountInr,
  paidAmountInr: paidAmountInr,
  status: status,
).ref();
ref.execute();
```

