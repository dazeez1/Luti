import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/contact_model.dart';
import 'package:luti/model/message_model.dart';

class ConversationModel {
  String? id;
  ContactModel? otherContact;
  List<MessageModel>? messages;
  MessageModel? lastMessage;

  ConversationModel() {
    messages = [];
  }

  Future<void> addConversationToFirestore(ContactModel otherContact) async {
    List<String> userNames = [
      AppConstants.currentUser.getFullNameOfUser(),
      otherContact.getFullNameOfUser(),
    ];

    List<String> userIDs = [
      AppConstants.currentUser.id!,
      otherContact.id!,
    ];

    Map<String, dynamic> conversationDataMap = {
      'lastMessageDateTime': FieldValue.serverTimestamp(),
      'lastMessageText': "",
      'userNames': userNames,
      'userIDs': userIDs,
      'createdAt': FieldValue.serverTimestamp(),
    };

    DocumentReference reference = await FirebaseFirestore.instance
        .collection("conversations")
        .add(conversationDataMap);
    id = reference.id;
  }

  Future<void> addMessageToFirestore(String messageText) async {
  if (id == null || id!.isEmpty) {
    throw Exception("Conversation ID is required");
  }

  try {
    final messageData = {
      'senderID': AppConstants.currentUser.id,
      'text': messageText,
      'dateTime': FieldValue.serverTimestamp(),
      'read': false,
    };

    // Add message to subcollection
    await FirebaseFirestore.instance
        .collection('conversations/$id/messages')
        .add(messageData);

    // Update conversation last message
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(id)
        .update({
          'lastMessageDateTime': FieldValue.serverTimestamp(),
          'lastMessageText': messageText,
        });
  } catch (e) {
    print('Error sending message: $e');
    rethrow;
  }
}
  Future<void> getConversationInfoFromFirestore(DocumentSnapshot snapshot) async {
    id = snapshot.id;

    String lastMessageText = snapshot["lastMessageText"] ?? "";
    Timestamp lastMessageDateTimestamp = snapshot["lastMessageDateTime"] ?? Timestamp.now();
    DateTime lastMessageDateTime = lastMessageDateTimestamp.toDate();

    lastMessage = MessageModel()
      ..dateTime = lastMessageDateTime
      ..text = lastMessageText;

    List<String> userIDs = List<String>.from(snapshot["userIDs"] ?? []);
    List<String> userNames = List<String>.from(snapshot["userNames"] ?? []);
    otherContact = ContactModel();

    for (String userID in userIDs) {
      if (userID != AppConstants.currentUser.id) {
        otherContact!.id = userID;
        break;
      }
    }

    for (String name in userNames) {
      if (name != AppConstants.currentUser.getFullNameOfUser()) {
        otherContact!.firstName = name.split(" ")[0];
        otherContact!.lastName = name.split(" ")[1];
        break;
      }
    }
  }
}