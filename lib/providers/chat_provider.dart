import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../utils/search_helper.dart';

class ChatMessageSearch {
  final String chatId;
  final Message message;
  final String contactName;

  ChatMessageSearch({
    required this.chatId,
    required this.message,
    required this.contactName,
  });
}

class ChatProvider with ChangeNotifier {
  final Map<String, List<Message>> _chats = {};
  bool _isTyping = false;

  Map<String, List<Message>> get chats => _chats;
  bool get isTyping => _isTyping;

  void addMessage(String chatId, Message message) {
    if (!_chats.containsKey(chatId)) {
      _chats[chatId] = [];
    }
    _chats[chatId]!.add(message);
    notifyListeners();
  }

  void setTypingStatus(bool isTyping) {
    _isTyping = isTyping;
    notifyListeners();
  }

  void markMessageAsRead(String chatId, String messageId) {
    final messages = _chats[chatId];
    if (messages != null) {
      for (var i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (message.senderId == messageId && !message.isRead) {
          messages[i] = Message(
            text: message.text,
            isSent: message.isSent,
            time: message.time,
            senderId: message.senderId,
            isRead: true,
            timestamp: message.timestamp,
          );
          notifyListeners();
          break;
        }
      }
    }
  }

  List<Message> getChatMessages(String chatId) {
    return _chats[chatId] ?? [];
  }

  List<ChatMessageSearch> searchMessages(String query, Map<String, String> contactNames) {
    if (query.isEmpty) return [];

    final results = <ChatMessageSearch>[];
    
    _chats.forEach((chatId, messages) {
      for (final message in messages) {
        if (SearchHelper.matchesQuery(message.text, query)) {
          results.add(ChatMessageSearch(
            chatId: chatId,
            message: message,
            contactName: contactNames[chatId] ?? 'Unknown',
          ));
        }
      }
    });

    results.sort((a, b) => b.message.timestamp.compareTo(a.message.timestamp));
    return results;
  }

  void deleteMessage(String chatId, Message message) {
    final messages = _chats[chatId];
    if (messages != null) {
      messages.remove(message);
      if (messages.isEmpty) {
        _chats.remove(chatId);
      }
      notifyListeners();
    }
  }

  void clearChat(String chatId) {
    _chats.remove(chatId);
    notifyListeners();
  }
}
