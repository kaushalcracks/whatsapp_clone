import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/date_formatter.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showTail;

  const MessageBubble({
    super.key,
    required this.message,
    this.showTail = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isSent ? 64 : 8,
          right: message.isSent ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: message.isSent 
              ? const Color(0xFFDCF8C6)  // Light green for sent messages
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: message.isSent ? 15 : 8,
              ),
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if (message.isSent)
              Positioned(
                right: 8,
                bottom: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      color: message.isRead ? Colors.blue : Colors.grey[600],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}