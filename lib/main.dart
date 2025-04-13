import 'package:flutter/material.dart';

void main() {
  runApp(const WhatsAppClone());
}

class WhatsAppClone extends StatelessWidget {
  const WhatsAppClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WhatsApp Clone',
      theme: ThemeData(
        primaryColor: const Color(0xFF075E54),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF075E54),
          primary: const Color(0xFF075E54),
        ),
      ),
      home: const WhatsAppHome(),
    );
  }
}

class Message {
  final String text;
  final bool isSent;
  final String time;

  Message({required this.text, required this.isSent, required this.time});
}

class Call {
  final String name;
  final String time;
  final bool isIncoming;
  final bool isMissed;

  const Call({
    required this.name,
    required this.time,
    required this.isIncoming,
    required this.isMissed,
  });
}

class Status {
  final String name;
  final String time;
  final bool isSeen;

  const Status({required this.name, required this.time, required this.isSeen});
}

class WhatsAppHome extends StatefulWidget {
  const WhatsAppHome({super.key});

  @override
  State<WhatsAppHome> createState() => _WhatsAppHomeState();
}

class _WhatsAppHomeState extends State<WhatsAppHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.7,
        title: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt, color: Colors.white)),
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
          labelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const CameraScreen(),
          const ChatScreen(),
          const StatusScreen(),
          const CallScreen(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: const Color(0xFF25D366),
      child: Icon(
        _tabController.index == 1
            ? Icons.message
            : _tabController.index == 2
            ? Icons.camera_alt
            : Icons.add_call,
        color: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Camera'));
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dummyData.length,
      itemBuilder:
          (context, i) => ChatTile(
            chat: dummyData[i],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ChatDetailScreen(name: dummyData[i]['name']!),
                ),
              );
            },
          ),
    );
  }
}

class ChatDetailScreen extends StatefulWidget {
  final String name;

  const ChatDetailScreen({super.key, required this.name});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    // Add some dummy messages
    messages.addAll([
      Message(text: "Hi!", isSent: false, time: "10:00"),
      Message(text: "Hello!", isSent: true, time: "10:01"),
      Message(text: "How are you?", isSent: false, time: "10:02"),
    ]);
  }

  void _handleSendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add(
          Message(
            text: _messageController.text,
            isSent: true,
            time: "${DateTime.now().hour}:${DateTime.now().minute}",
          ),
        );
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(widget.name, style: const TextStyle(color: Colors.white)),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment:
                      message.isSent
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          message.isSent
                              ? const Color(0xFFDCF8C6)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(message.text),
                        Text(
                          message.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4),
              ],
            ),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSendMessage,
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
    _messageController.dispose();
    super.dispose();
  }
}

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  final List<Status> recentUpdates = const [
    Status(name: "John Doe", time: "Today, 10:30 AM", isSeen: false),
    Status(name: "Alice Smith", time: "Today, 9:15 AM", isSeen: true),
    Status(name: "Bob Johnson", time: "Today, 8:45 AM", isSeen: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Stack(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 35, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, size: 15, color: Colors.white),
                ),
              ),
            ],
          ),
          title: const Text('My Status'),
          subtitle: const Text('Tap to add status update'),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Recent updates',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        ...recentUpdates
            .map(
              (status) => ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: status.isSeen ? Colors.grey : Colors.green,
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
                title: Text(status.name),
                subtitle: Text(status.time),
                onTap: () {},
              ),
            )
            .toList(),
      ],
    );
  }
}

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  final List<Call> callHistory = const [
    Call(
      name: "John Doe",
      time: "Today, 10:30 AM",
      isIncoming: true,
      isMissed: false,
    ),
    Call(
      name: "Alice Smith",
      time: "Today, 9:15 AM",
      isIncoming: false,
      isMissed: true,
    ),
    Call(
      name: "Bob Johnson",
      time: "Yesterday, 8:45 PM",
      isIncoming: true,
      isMissed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: callHistory.length,
        itemBuilder: (context, index) {
          final call = callHistory[index];
          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(call.name),
            subtitle: Row(
              children: [
                Icon(
                  call.isIncoming ? Icons.call_received : Icons.call_made,
                  size: 15,
                  color: call.isMissed ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(call.time),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.call),
              color: Theme.of(context).primaryColor,
              onPressed: () {},
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final Map<String, String> chat;
  final VoidCallback onTap;

  const ChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 35, color: Colors.white),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            chat['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            chat['time']!,
            style: const TextStyle(color: Colors.grey, fontSize: 14.0),
          ),
        ],
      ),
      subtitle: Text(
        chat['message']!,
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}

// Dummy data for chat list
final List<Map<String, String>> dummyData = [
  {"name": "John Doe", "message": "Hey! How are you?", "time": "15:30"},
  {
    "name": "Family Group",
    "message": "Mom: Don't forget dinner tonight!",
    "time": "14:20",
  },
  {
    "name": "Alice Smith",
    "message": "Meeting tomorrow at 10 AM",
    "time": "13:45",
  },
  {"name": "Bob Johnson", "message": "Did you see the news?", "time": "12:30"},
  {
    "name": "Work Group",
    "message": "Project deadline extended",
    "time": "11:00",
  },
];
