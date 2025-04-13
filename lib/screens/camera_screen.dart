import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/status_provider.dart';
import '../models/status.dart';
import '../models/message.dart';
import '../utils/date_formatter.dart';

class CameraScreen extends StatefulWidget {
  final bool forStatus;
  final String? chatId;
  final String? recipientName;

  const CameraScreen({
    super.key,
    this.forStatus = false,
    this.chatId,
    this.recipientName,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _showImagePicker();
  }

  Future<void> _showImagePicker() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null && mounted) {
        if (widget.forStatus) {
          final statusProvider = context.read<StatusProvider>();
          statusProvider.addStatus(Status(
            name: "My Status",
            time: "Just now",
            isSeen: false,
            imageUrl: image.path,
            timestamp: DateTime.now(),
          ));
        } else if (widget.chatId != null) {
          final chatProvider = context.read<ChatProvider>();
          chatProvider.addMessage(
            widget.chatId!,
            Message(
              text: "📷 Photo",
              isSent: true,
              time: DateFormatter.getMessageTime(DateTime.now()),
              senderId: "me",
              timestamp: DateTime.now(),
            ),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
