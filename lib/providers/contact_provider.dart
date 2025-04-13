import 'package:flutter/foundation.dart';
import '../models/contact.dart';

class ContactProvider with ChangeNotifier {
  final List<Contact> _contacts = [
    Contact(
      name: "John Doe",
      phoneNumber: "+1234567890",
      status: "Hey there! I'm using WhatsApp",
      isOnline: true,
    ),
    Contact(
      name: "Alice Smith",
      phoneNumber: "+1987654321",
      status: "Available",
      lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    // Add more dummy contacts
  ];

  List<Contact> get contacts => _contacts;

  List<Contact> searchContacts(String query) {
    if (query.isEmpty) return _contacts;
    return _contacts.where((contact) => 
      contact.name.toLowerCase().contains(query.toLowerCase()) ||
      contact.phoneNumber.contains(query)
    ).toList();
  }

  void addContact(Contact contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void updateContactStatus(String phoneNumber, bool isOnline) {
    final index = _contacts.indexWhere((c) => c.phoneNumber == phoneNumber);
    if (index != -1) {
      final contact = _contacts[index];
      _contacts[index] = Contact(
        name: contact.name,
        phoneNumber: contact.phoneNumber,
        status: contact.status,
        imageUrl: contact.imageUrl,
        isOnline: isOnline,
        lastSeen: isOnline ? null : DateTime.now(),
      );
      notifyListeners();
    }
  }
}