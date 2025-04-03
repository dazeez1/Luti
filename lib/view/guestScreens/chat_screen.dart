import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luti/global.dart';
import 'package:luti/model/conversation_model.dart';
import 'package:luti/view/conversation_screen.dart';
import 'package:luti/view/widgets/conversation_list_tile_ui.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: inboxViewModel.getConversation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final conversations = snapshot.data!.docs.map((doc) {
          final conversation = ConversationModel();
          conversation.getConversationInfoFromFirestore(doc);
          return conversation;
        }).toList();

        return ListView.builder(
          itemCount: conversations.length,
          itemExtent: MediaQuery.of(context).size.height / 9,
          itemBuilder: (context, index) {
            return InkResponse(
              onTap: () {
                Get.to(() => ConversationScreen(conversation: conversations[index]));
              },
              child: ConversationListTileUi(
                conversation: conversations[index],
              ),
            );
          },
        );
      },
    );
  }
}