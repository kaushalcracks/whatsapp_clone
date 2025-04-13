import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/contact.dart';
import '../providers/contact_provider.dart';
import '../widgets/user_avatar.dart';
import '../utils/date_formatter.dart';
import 'chat_screen.dart';

class ContactListScreen extends StatefulWidget {
  final bool forCall;
  final bool videoCall;

  const ContactListScreen({
    super.key,
    this.forCall = false,
    this.videoCall = false,
  });

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: _searchQuery.isEmpty
            ? Text(
                widget.forCall
                    ? 'Select contact to call'
                    : 'Select contact to message',
                style: const TextStyle(color: Colors.white),
              )
            : TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                autofocus: true,
              ),
        actions: [
          if (_searchQuery.isEmpty)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => _searchQuery = ' '),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, _) {
          final contacts = contactProvider.searchContacts(_searchQuery);
          return ListView.builder(
            itemCount: contacts.length + 1, // +1 for new contact option
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.person_add, color: Colors.white),
                  ),
                  title: const Text('New contact'),
                  onTap: () {
                    // TODO: Implement new contact creation
                  },
                );
              }

              final contact = contacts[index - 1];
              return ListTile(
                leading: UserAvatar(
                  imageUrl: contact.imageUrl ?? '',
                  isOnline: contact.isOnline,
                ),
                title: Text(contact.name),
                subtitle: Text(
                  contact.status ??
                      (contact.isOnline
                          ? 'online'
                          : contact.lastSeen != null
                              ? 'last seen ${DateFormatter.getLastSeen(contact.lastSeen!)}'
                              : 'offline'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (widget.forCall) {
                    // TODO: Handle call initiation
                  } else {
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
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: widget.forCall
          ? null
          : FloatingActionButton(
              onPressed: () {
                // TODO: Implement QR code scanning
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.qr_code_scanner),
            ),
    );
  }
}
