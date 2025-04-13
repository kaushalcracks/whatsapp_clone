import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/chat_screen.dart';
import 'screens/status_screen.dart';
import 'screens/calls_screen.dart';
import 'screens/contact_list_screen.dart';
import 'screens/camera_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/status_provider.dart';
import 'providers/call_provider.dart';
import 'providers/contact_provider.dart';
import 'models/status.dart';
import 'widgets/whatsapp_search.dart';
import 'widgets/chat_list.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ],
      child: const WhatsAppClone(),
    ),
  );
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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 1);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _searchController.clear();
      });
    }
  }

  Future<void> _handleStatusImagePick() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;

        final statusProvider = context.read<StatusProvider>();
        statusProvider.addStatus(Status(
          name: "My Status",
          time: "Just now",
          isSeen: false,
          imageUrl: image.path,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showStatusUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a photo'),
            onTap: () async {
              Navigator.pop(context);
              final XFile? photo =
                  await _imagePicker.pickImage(source: ImageSource.camera);
              if (photo != null && mounted) {
                final statusProvider = context.read<StatusProvider>();
                statusProvider.addStatus(Status(
                  name: "My Status",
                  time: "Just now",
                  isSeen: false,
                  imageUrl: photo.path,
                  timestamp: DateTime.now(),
                ));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from gallery'),
            onTap: () {
              Navigator.pop(context);
              _handleStatusImagePick();
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
                statusProvider.addStatus(Status(
                  name: "My Status",
                  time: "Just now",
                  isSeen: false,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.7,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text(
          'WhatsApp',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              showSearch(
                context: context,
                delegate: WhatsAppSearch(),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'newGroup':
                  // TODO: Implement new group
                  break;
                case 'newBroadcast':
                  // TODO: Implement new broadcast
                  break;
                case 'linkedDevices':
                  // TODO: Implement linked devices
                  break;
                case 'starredMessages':
                  // TODO: Implement starred messages
                  break;
                case 'settings':
                  // TODO: Implement settings
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newGroup',
                child: Text('New group'),
              ),
              const PopupMenuItem(
                value: 'newBroadcast',
                child: Text('New broadcast'),
              ),
              const PopupMenuItem(
                value: 'linkedDevices',
                child: Text('Linked devices'),
              ),
              const PopupMenuItem(
                value: 'starredMessages',
                child: Text('Starred messages'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
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
          const Center(
            child: Text(
              'Swipe right to open camera\nor tap the camera button below',
              textAlign: TextAlign.center,
            ),
          ),
          const ChatList(),
          const StatusScreen(),
          const CallsScreen(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScreen(),
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.camera_alt),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactListScreen(),
              ),
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.message),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScreen(forStatus: true),
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.camera_alt),
        );
      case 3:
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactListScreen(forCall: true),
              ),
            );
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add_call),
        );
      default:
        return Container();
    }
  }

  void _handleSearch(String value) {
    // Implement search based on current tab
    switch (_tabController.index) {
      case 1: // Chats
        // TODO: Filter chats
        break;
      case 2: // Status
        // TODO: Filter status updates
        break;
      case 3: // Calls
        // TODO: Filter call history
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
