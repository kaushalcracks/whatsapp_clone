import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';
import '../widgets/user_avatar.dart';
import '../utils/date_formatter.dart';
import '../providers/chat_provider.dart';
import 'camera_screen.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String imageUrl;
  final String chatId;

  ChatScreen({
    super.key,
    required this.name,
    this.imageUrl = '',
    String? chatId,
  }) : chatId = chatId ?? name.toLowerCase().replaceAll(' ', '_');

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _showAttachments = false;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isComposing = _messageController.text.isNotEmpty;
      });
    });

    // Initialize chat if empty
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.getChatMessages(widget.chatId).isEmpty) {
      chatProvider.addMessage(
        widget.chatId,
        Message(
          text: "Hey! How are you?",
          isSent: false,
          time: DateFormatter.getMessageTime(
              DateTime.now().subtract(const Duration(minutes: 5))),
          senderId: "other",
        ),
      );
    }
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    final chatProvider = context.read<ChatProvider>();
    chatProvider.addMessage(
      widget.chatId,
      Message(
        text: text,
        isSent: true,
        time: DateFormatter.getMessageTime(DateTime.now()),
        senderId: "me",
      ),
    );
  }

  Future<void> _handleImageSelection() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;

        final chatProvider = context.read<ChatProvider>();
        chatProvider.addMessage(
          widget.chatId,
          Message(
            text: "📷 Photo: ${image.path}",
            isSent: true,
            time: DateFormatter.getMessageTime(DateTime.now()),
            senderId: "me",
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Widget _buildMessage(Message message) {
    final isImage = message.text.startsWith("📷 Photo:");
    final align =
        message.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color =
        message.isSent ? Theme.of(context).primaryColor : Colors.white;
    final textColor = message.isSent ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 280),
            padding: EdgeInsets.all(isImage ? 4 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(message.text.substring(8)),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  )
                else
                  Text(
                    message.text,
                    style: TextStyle(color: textColor),
                  ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.time,
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            message.isSent ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    if (message.isSent) ...[
                      const SizedBox(width: 3),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 16,
                        color: message.isRead ? Colors.blue : Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leadingWidth: 25,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            UserAvatar(
              imageUrl: widget.imageUrl,
              radius: 20,
              isOnline: true,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) => Text(
                      chatProvider.isTyping ? 'typing...' : 'online',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.getChatMessages(widget.chatId);
                return ListView.builder(
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final reversedIndex = messages.length - 1 - index;
                    return _buildMessage(messages[reversedIndex]);
                  },
                );
              },
            ),
          ),
          if (_showAttachments)
            Container(
              height: 200,
              color: Colors.grey[100],
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAttachmentButton(Icons.insert_drive_file, 'Document'),
                  _buildAttachmentButton(Icons.camera_alt, 'Camera'),
                  _buildAttachmentButton(Icons.photo, 'Gallery'),
                  _buildAttachmentButton(Icons.headphones, 'Audio'),
                  _buildAttachmentButton(Icons.location_on, 'Location'),
                  _buildAttachmentButton(Icons.person, 'Contact'),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _showAttachments ? Icons.close : Icons.attach_file,
                  ),
                  onPressed: () {
                    setState(() => _showAttachments = !_showAttachments);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          chatId: widget.chatId,
                          recipientName: widget.name,
                        ),
                      ),
                    );
                  },
                ),
                if (!_isComposing)
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // TODO: Implement voice recording
                    },
                  ),
                if (_isComposing)
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_messageController.text),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
