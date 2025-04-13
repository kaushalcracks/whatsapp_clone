import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/status.dart';
import '../utils/date_formatter.dart';
import '../widgets/user_avatar.dart';
import '../providers/status_provider.dart';
import 'dart:async';
import '../widgets/status_image_viewer.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  void _showStatusUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement camera functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement gallery picker
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Text status'),
            onTap: () {
              Navigator.pop(context);
              _showTextStatusDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showTextStatusDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create text status'),
        content: TextField(
          controller: textController,
          maxLength: 140,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Type your status...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                final statusProvider = context.read<StatusProvider>();
                statusProvider.updateMyStatus(Status(
                  name: "My Status",
                  time: "Just now",
                  isSeen: false,
                  content: textController.text.trim(),
                  timestamp: DateTime.now(),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    ).then((_) => textController.dispose());
  }

  void _viewStatus(Status status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusViewer(status: status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatusProvider>(
      builder: (context, statusProvider, _) {
        final recentUpdates = statusProvider.getRecentUpdates();
        final myStatus = statusProvider.myStatus;

        return Scaffold(
          body: ListView(
            children: [
              ListTile(
                leading: Stack(
                  children: [
                    const UserAvatar(radius: 30),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                title: const Text('My Status'),
                subtitle: Text(
                  myStatus != null
                      ? 'Tap to update status'
                      : 'Tap to add status',
                ),
                onTap: _showStatusUploadOptions,
              ),
              if (recentUpdates.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Recent updates',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...recentUpdates.map((status) => ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: status.isSeen ? Colors.grey : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: UserAvatar(radius: 28),
                      ),
                      title: Text(status.name),
                      subtitle:
                          Text(DateFormatter.getVerboseDate(status.timestamp)),
                      onTap: () => _viewStatus(status),
                    )),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showStatusUploadOptions(),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.camera_alt),
          ),
        );
      },
    );
  }
}

class StatusViewer extends StatefulWidget {
  final Status status;

  const StatusViewer({super.key, required this.status});

  @override
  State<StatusViewer> createState() => _StatusViewerState();
}

class _StatusViewerState extends State<StatusViewer> {
  double _progress = 0.0;
  late Timer _timer;
  final Duration _statusDuration = const Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final interval = _statusDuration.inMilliseconds ~/ 100;
    _timer = Timer.periodic(
      Duration(milliseconds: interval),
      (timer) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _timer.cancel();
            Navigator.pop(context);
          }
        });
      },
    );
  }

  void _pauseTimer() {
    _timer.cancel();
  }

  void _resumeTimer() {
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (widget.status.imageUrl != null &&
              widget.status.imageUrl!.isNotEmpty)
            StatusImageViewer(
              imageUrl: widget.status.imageUrl!,
              progress: _progress,
              onTapDown: _pauseTimer,
              onTapUp: _resumeTimer,
            )
          else
            GestureDetector(
              onTapDown: (_) => _pauseTimer(),
              onTapUp: (_) => _resumeTimer(),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Colors.teal[700]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.status.content ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[800],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: 8,
            right: 8,
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: widget.status.imageUrl ?? '',
                  radius: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.status.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.status.time,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: Colors.white,
                  onPressed: () {
                    // TODO: Implement status options menu
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
