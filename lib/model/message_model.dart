import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luti/model/contact_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageModel {
  ContactModel? sender;
  String? text;
  DateTime? dateTime;
  bool? read;

  MessageModel();

  String getMessageDateTime() {
    if (dateTime == null) return "";
    return timeago.format(dateTime!);
  }

  Future<void> getMessageInfoFromFirestore(DocumentSnapshot snapshot) async {
    Timestamp messageTimestamp = snapshot['dateTime'] ?? Timestamp.now();
    dateTime = messageTimestamp.toDate();

    String senderID = snapshot['senderID'] ?? "";
    sender = ContactModel(id: senderID);

    text = snapshot['text'] ?? "";
    read = snapshot['read'] ?? false;
  }
}
