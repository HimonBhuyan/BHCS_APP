part of 'blue_hour_mobile.dart';

class SendFounderChatMessageVariablesBuilder {
  String id;
  String threadId;
  String senderId;
  String senderName;
  String senderRole;
  String body;
  String messageType;
  Optional<String> _attachmentName = Optional.optional(nativeFromJson, nativeToJson);
  Optional<int> _voiceDurationSec = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _replyToSender = Optional.optional(nativeFromJson, nativeToJson);
  Optional<String> _replyToPreview = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  SendFounderChatMessageVariablesBuilder attachmentName(String? t) {
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

  SendFounderChatMessageVariablesBuilder(this._dataConnect, {required  this.id,required  this.threadId,required  this.senderId,required  this.senderName,required  this.senderRole,required  this.body,required  this.messageType,});
  Deserializer<SendFounderChatMessageData> dataDeserializer = (dynamic json)  => SendFounderChatMessageData.fromJson(jsonDecode(json));
  Serializer<SendFounderChatMessageVariables> varsSerializer = (SendFounderChatMessageVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<SendFounderChatMessageData, SendFounderChatMessageVariables>> execute() {
    return ref().execute();
  }

  MutationRef<SendFounderChatMessageData, SendFounderChatMessageVariables> ref() {
    SendFounderChatMessageVariables vars= SendFounderChatMessageVariables(id: id,threadId: threadId,senderId: senderId,senderName: senderName,senderRole: senderRole,body: body,messageType: messageType,attachmentName: _attachmentName,voiceDurationSec: _voiceDurationSec,replyToSender: _replyToSender,replyToPreview: _replyToPreview,);
    return _dataConnect.mutation("SendFounderChatMessage", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class SendFounderChatMessageChatMessageUpsert {
  final String id;
  final String threadId;
  SendFounderChatMessageChatMessageUpsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']),
  threadId = nativeFromJson<String>(json['threadId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendFounderChatMessageChatMessageUpsert otherTyped = other as SendFounderChatMessageChatMessageUpsert;
    return id == otherTyped.id && 
    threadId == otherTyped.threadId;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, threadId.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['threadId'] = nativeToJson<String>(threadId);
    return json;
  }

  SendFounderChatMessageChatMessageUpsert({
    required this.id,
    required this.threadId,
  });
}

@immutable
class SendFounderChatMessageData {
  final SendFounderChatMessageChatMessageUpsert chatMessage_upsert;
  SendFounderChatMessageData.fromJson(dynamic json):
  
  chatMessage_upsert = SendFounderChatMessageChatMessageUpsert.fromJson(json['chatMessage_upsert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendFounderChatMessageData otherTyped = other as SendFounderChatMessageData;
    return chatMessage_upsert == otherTyped.chatMessage_upsert;
    
  }
  @override
  int get hashCode => chatMessage_upsert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['chatMessage_upsert'] = chatMessage_upsert.toJson();
    return json;
  }

  SendFounderChatMessageData({
    required this.chatMessage_upsert,
  });
}

@immutable
class SendFounderChatMessageVariables {
  final String id;
  final String threadId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String body;
  final String messageType;
  late final Optional<String>attachmentName;
  late final Optional<int>voiceDurationSec;
  late final Optional<String>replyToSender;
  late final Optional<String>replyToPreview;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  SendFounderChatMessageVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  threadId = nativeFromJson<String>(json['threadId']),
  senderId = nativeFromJson<String>(json['senderId']),
  senderName = nativeFromJson<String>(json['senderName']),
  senderRole = nativeFromJson<String>(json['senderRole']),
  body = nativeFromJson<String>(json['body']),
  messageType = nativeFromJson<String>(json['messageType']) {
  
  
  
  
  
  
  
  
  
    attachmentName = Optional.optional(nativeFromJson, nativeToJson);
    attachmentName.value = json['attachmentName'] == null ? null : nativeFromJson<String>(json['attachmentName']);
  
  
    voiceDurationSec = Optional.optional(nativeFromJson, nativeToJson);
    voiceDurationSec.value = json['voiceDurationSec'] == null ? null : nativeFromJson<int>(json['voiceDurationSec']);
  
  
    replyToSender = Optional.optional(nativeFromJson, nativeToJson);
    replyToSender.value = json['replyToSender'] == null ? null : nativeFromJson<String>(json['replyToSender']);
  
  
    replyToPreview = Optional.optional(nativeFromJson, nativeToJson);
    replyToPreview.value = json['replyToPreview'] == null ? null : nativeFromJson<String>(json['replyToPreview']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final SendFounderChatMessageVariables otherTyped = other as SendFounderChatMessageVariables;
    return id == otherTyped.id && 
    threadId == otherTyped.threadId && 
    senderId == otherTyped.senderId && 
    senderName == otherTyped.senderName && 
    senderRole == otherTyped.senderRole && 
    body == otherTyped.body && 
    messageType == otherTyped.messageType && 
    attachmentName == otherTyped.attachmentName && 
    voiceDurationSec == otherTyped.voiceDurationSec && 
    replyToSender == otherTyped.replyToSender && 
    replyToPreview == otherTyped.replyToPreview;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, threadId.hashCode, senderId.hashCode, senderName.hashCode, senderRole.hashCode, body.hashCode, messageType.hashCode, attachmentName.hashCode, voiceDurationSec.hashCode, replyToSender.hashCode, replyToPreview.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['threadId'] = nativeToJson<String>(threadId);
    json['senderId'] = nativeToJson<String>(senderId);
    json['senderName'] = nativeToJson<String>(senderName);
    json['senderRole'] = nativeToJson<String>(senderRole);
    json['body'] = nativeToJson<String>(body);
    json['messageType'] = nativeToJson<String>(messageType);
    if(attachmentName.state == OptionalState.set) {
      json['attachmentName'] = attachmentName.toJson();
    }
    if(voiceDurationSec.state == OptionalState.set) {
      json['voiceDurationSec'] = voiceDurationSec.toJson();
    }
    if(replyToSender.state == OptionalState.set) {
      json['replyToSender'] = replyToSender.toJson();
    }
    if(replyToPreview.state == OptionalState.set) {
      json['replyToPreview'] = replyToPreview.toJson();
    }
    return json;
  }

  SendFounderChatMessageVariables({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.body,
    required this.messageType,
    required this.attachmentName,
    required this.voiceDurationSec,
    required this.replyToSender,
    required this.replyToPreview,
  });
}

