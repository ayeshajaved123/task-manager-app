import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_community_safety/models/contact_model.dart';
import 'package:smart_community_safety/services/hive_service.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  late List<ContactModel> _contacts;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    _contacts = HiveService.contactBox.values.toList();

    // Add default emergency contacts if empty
    if (_contacts.isEmpty) {
      _addDefaultContacts();
    }
    setState(() {});
  }

  void _addDefaultContacts() {
    final defaults = [
      ContactModel(id: 'police', name: 'Police', phoneNumber: '100', isEmergency: true),
      ContactModel(id: 'fire', name: 'Fire Brigade', phoneNumber: '101', isEmergency: true),
      ContactModel(id: 'ambulance', name: 'Ambulance', phoneNumber: '102', isEmergency: true),
    ];
    for (final contact in defaults) {
      HiveService.contactBox.put(contact.id, contact);
    }
    _contacts = HiveService.contactBox.values.toList();
  }

  Future<void> _call(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call $number')),
      );
    }
  }

  Future<void> _addNewContact() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty || phone.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and phone are required')),
                );
                return;
              }

              final contact = ContactModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                phoneNumber: phone,
                isEmergency: false,
              );

              HiveService.contactBox.put(contact.id, contact);
              _loadContacts(); // Refresh list
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('Loading contacts...'))
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Icon(
                contact.isEmergency ? Icons.local_hospital : Icons.person,
                color: contact.isEmergency ? Colors.red : null,
              ),
              title: Text(contact.name),
              subtitle: Text(contact.phoneNumber),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () => _call(contact.phoneNumber),
                    color: Colors.green,
                  ),
                  if (!contact.isEmergency)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        HiveService.contactBox.delete(contact.id);
                        _loadContacts();
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewContact,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}