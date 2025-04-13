import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/status_provider.dart';
import '../providers/call_provider.dart';
import '../providers/contact_provider.dart';
import '../utils/search_helper.dart';
import '../widgets/user_avatar.dart';
import '../screens/chat_screen.dart';

class WhatsAppSearch extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: theme.primaryColor,
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults(context);
  }

  Widget buildSearchResults(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'CHATS'),
              Tab(text: 'MESSAGES'),
              Tab(text: 'STATUS'),
              Tab(text: 'CALLS'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildChatResults(context),
                _buildMessageResults(context),
                _buildStatusResults(context),
                _buildCallResults(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatResults(BuildContext context) {
    final contacts = context.watch<ContactProvider>().searchContacts(query);
    
    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: UserAvatar(
            imageUrl: contact.imageUrl ?? '',
            isOnline: contact.isOnline,
          ),
          title: Text(
            SearchHelper.highlightMatch(contact.name, query),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(contact.status ?? ''),
          onTap: () {
            close(context, '');
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
  }

  Widget _buildMessageResults(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final contactProvider = context.watch<ContactProvider>();
    
    final contactNames = {
      for (var contact in contactProvider.contacts)
        contact.phoneNumber: contact.name
    };
    
    final results = chatProvider.searchMessages(query, contactNames);

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              query.isEmpty 
                ? 'Search messages' 
                : 'No messages found',
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
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          leading: UserAvatar(radius: 25),
          title: Text(
            result.contactName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            SearchHelper.highlightMatch(result.message.text, query),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            result.message.time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          onTap: () {
            close(context, '');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  name: result.contactName,
                  chatId: result.chatId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusResults(BuildContext context) {
    final statuses = context.watch<StatusProvider>().getRecentUpdates()
      .where((status) => SearchHelper.matchesQuery(status.name, query))
      .toList();

    return ListView.builder(
      itemCount: statuses.length,
      itemBuilder: (context, index) {
        final status = statuses[index];
        return ListTile(
          leading: UserAvatar(
            imageUrl: status.imageUrl ?? '',
          ),
          title: Text(
            SearchHelper.highlightMatch(status.name, query),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(status.time),
          onTap: () {
            // TODO: View status
            close(context, '');
          },
        );
      },
    );
  }

  Widget _buildCallResults(BuildContext context) {
    final calls = context.watch<CallProvider>().searchCalls(query);

    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return ListTile(
          leading: UserAvatar(radius: 25),
          title: Text(
            SearchHelper.highlightMatch(call.name, query),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Icon(
                call.isIncoming ? Icons.call_received : Icons.call_made,
                size: 15,
                color: call.isMissed ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(call.time),
              if (call.isVideo)
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.videocam, size: 15),
                ),
            ],
          ),
          onTap: () {
            // TODO: Show call details or initiate new call
            close(context, '');
          },
        );
      },
    );
  }
}