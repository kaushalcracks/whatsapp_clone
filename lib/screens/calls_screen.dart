import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/call.dart';
import '../widgets/user_avatar.dart';
import '../utils/date_formatter.dart';
import '../providers/call_provider.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  void _makeCall(BuildContext context, Call call, bool isVideo) {
    final callProvider = context.read<CallProvider>();
    callProvider.setActiveCall(call);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: CallDialog(call: call, isVideo: isVideo),
      ),
    );
  }

  void _showCallOptions(BuildContext context, Call call) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text('Voice call'),
            onTap: () {
              Navigator.pop(context);
              _makeCall(context, call, false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Video call'),
            onTap: () {
              Navigator.pop(context);
              _makeCall(context, call, true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('View info'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement contact info view
            },
          ),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Block contact'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement block functionality
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CallProvider>(
      builder: (context, callProvider, _) {
        final calls = callProvider.calls;

        return Scaffold(
          body: calls.isEmpty
              ? const Center(
                  child: Text(
                    'No calls yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: calls.length,
                  itemBuilder: (context, index) {
                    final call = calls[index];
                    return ListTile(
                      leading: UserAvatar(radius: 25),
                      title: Text(call.name),
                      subtitle: Row(
                        children: [
                          Icon(
                            call.isIncoming
                                ? Icons.call_received
                                : Icons.call_made,
                            size: 15,
                            color: call.isMissed ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(call.timeFormatted),
                          if (call.isVideo)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.videocam, size: 15),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          call.isVideo ? Icons.videocam : Icons.call,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () => _makeCall(context, call, call.isVideo),
                      ),
                      onTap: () => _showCallOptions(context, call),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.add_call),
            onPressed: () {
              // TODO: Implement new call contact picker
            },
          ),
        );
      },
    );
  }
}

class CallDialog extends StatefulWidget {
  final Call call;
  final bool isVideo;

  const CallDialog({
    super.key,
    required this.call,
    required this.isVideo,
  });

  @override
  State<CallDialog> createState() => _CallDialogState();
}

class _CallDialogState extends State<CallDialog> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoOff = false;
  Duration _callDuration = Duration.zero;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => setState(() => _callDuration += const Duration(seconds: 1)),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserAvatar(radius: 40),
          const SizedBox(height: 16),
          Text(
            widget.call.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDuration(_callDuration),
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (widget.isVideo)
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.black87,
              child: Center(
                child: _isVideoOff
                    ? const Icon(Icons.videocam_off,
                        color: Colors.white, size: 40)
                    : const Icon(Icons.person, color: Colors.white, size: 40),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : null,
                ),
                onPressed: () => setState(() => _isMuted = !_isMuted),
              ),
              IconButton(
                icon: const Icon(Icons.call_end),
                color: Colors.red,
                onPressed: () {
                  final callProvider = context.read<CallProvider>();
                  callProvider.setActiveCall(null);
                  Navigator.pop(context);
                  // Add call to history
                  callProvider.addCall(Call(
                    name: widget.call.name,
                    time: "Just now",
                    isIncoming: false,
                    isMissed: false,
                    isVideo: widget.isVideo,
                    timestamp: DateTime.now(),
                  ));
                },
              ),
              IconButton(
                icon: Icon(
                  _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  color: _isSpeakerOn ? Theme.of(context).primaryColor : null,
                ),
                onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
              ),
              if (widget.isVideo)
                IconButton(
                  icon: Icon(
                    _isVideoOff ? Icons.videocam_off : Icons.videocam,
                    color: _isVideoOff ? Colors.red : null,
                  ),
                  onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                ),
            ],
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
