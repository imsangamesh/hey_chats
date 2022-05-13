class MessageModel {
  String? msgId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel({
    this.msgId,
    this.sender,
    this.text,
    this.seen,
    this.createdOn,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    msgId = map['msgId'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdOn = map['createdOn'];
  }

  Map<String, dynamic> toMap() {
    return {
      'msgId': msgId,
      'sender': sender,
      'text': text,
      'seen': seen,
      'createdOn': createdOn,
    };
  }
}
