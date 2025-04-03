import 'package:flutter/material.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/message_model.dart';

class MessageListTileUi extends StatelessWidget {
  final MessageModel? message;

  const MessageListTileUi({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message?.sender?.id == AppConstants.currentUser.id;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 36, 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Sender avatar could go here
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF2C3E50) : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMe) ...[
                    Text(
                      message?.sender?.getFullNameOfUser() ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message?.text ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      message?.getMessageDateTime() ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: isMe ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
