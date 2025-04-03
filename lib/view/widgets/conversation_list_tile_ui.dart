import 'package:flutter/material.dart';
import 'package:luti/model/conversation_model.dart';

class ConversationListTileUi extends StatefulWidget {
  final ConversationModel? conversation; // Marked as final

  const ConversationListTileUi({super.key, this.conversation});

  @override
  State<ConversationListTileUi> createState() => _ConversationListTileUiState();
}

class _ConversationListTileUiState extends State<ConversationListTileUi> {
  ConversationModel? conversation;

  @override
  void initState() {
    super.initState();
    conversation = widget.conversation; // Initialize the local variable
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {},
      ),
      title: Text(
        conversation!.otherContact!.getFullNameOfUser(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.5,
        ),
      ),
      subtitle: Text(
        widget.conversation!.lastMessage!.text!,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        widget.conversation!.lastMessage!.getMessageDateTime(),
        style: const TextStyle(
          fontSize: 12,
        ),
      ),
    );
  }
}
