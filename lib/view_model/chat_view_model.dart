import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/app_constants.dart';
import '../model/conversation_model.dart';

class InboxViewModel
{
  getConversation()
  {
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('userIDs', arrayContains: AppConstants.currentUser.id)
        .snapshots();
  }

  getMessages(ConversationModel? conversation)
  {
    return FirebaseFirestore.instance
        .collection('conversations/${conversation!.id}/messages')
        .orderBy('dateTime', descending: true)
        .snapshots();

  }
}