import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../providers/chat_provider.dart';
import '../providers/contact_provider.dart';
import '../widgets/user_avatar.dart';
import '../screens/chat_screen.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, ContactProvider>(
      builder: (context, chatProvider, contactProvider, _) {
        final chats = chatProvider.chats.entries.toList()
          ..sort((a, b) {
            final aLastMessage = a.value.last;
            final bLastMessage = b.value.last;
            return bLastMessage.timestamp.compareTo(aLastMessage.timestamp);
          });

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No chats yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chatEntry = chats[index];
            final contact = contactProvider.contacts
                .firstWhere((c) => c.phoneNumber == chatEntry.key);
            final lastMessage = chatEntry.value.last;
            final unreadCount =
                chatEntry.value.where((m) => !m.isSent && !m.isRead).length;

            return ListTile(
              leading: UserAvatar(
                imageUrl: contact.imageUrl ?? '',
                isOnline: contact.isOnline,
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    lastMessage.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: unreadCount > 0
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              subtitle: Row(
                children: [
                  if (lastMessage.isSent)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        lastMessage.isRead ? Icons.done_all : Icons.done,
                        size: 16,
                        color: lastMessage.isRead ? Colors.blue : Colors.grey,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      lastMessage.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            unreadCount > 0 ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      name: contact.name,
                      imageUrl: contact.imageUrl ?? '',
                      chatId: contact.phoneNumber,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
