import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final bool editable;
  const EmergencyContactsScreen({super.key, this.editable = true});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, String>> _contacts = [];
  bool _isLoading = true;
  bool get _isEditable => widget.editable;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final data = await Supabase.instance.client
        .from('emergency_contacts')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: true);
    
    setState(() {
      _contacts = List<Map<String, String>>.from(
        (data as List).map((e) => {
          'id': e['id']?.toString() ?? '',
          'name': e['name']?.toString() ?? '',
          'phone': e['phone']?.toString() ?? '',
          'email': e['email']?.toString() ?? '', // Added Email
        })
      );
      if (_contacts.isEmpty) {
        _contacts = [
          {'name': '', 'phone': '', 'email': ''},
          {'name': '', 'phone': '', 'email': ''},
        ];
      }
      _isLoading = false;
    });
  }

  void _addContact() {
    setState(() {
      _contacts.add({'name': '', 'phone': '', 'email': ''});
    });
  }

  Future<void> _saveContacts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final nonEmptyContacts = _contacts.where((contact) =>
      (contact['name']?.trim().isNotEmpty ?? false) && 
      (contact['phone']?.trim().isNotEmpty ?? false)
    ).toList();

    if (nonEmptyContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill at least one contact."), backgroundColor: Colors.red),
      );
      return;
    }

    await Supabase.instance.client.from('emergency_contacts').delete().eq('user_id', user.id);

    for (final contact in nonEmptyContacts) {
      await Supabase.instance.client.from('emergency_contacts').insert({
        'user_id': user.id,
        'name': contact['name'],
        'phone': contact['phone'],
        'email': contact['email'], // Added Email
      });
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                children: [
                  ..._contacts.asMap().entries.map((entry) {
                    final i = entry.key;
                    final contact = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              enabled: _isEditable,
                              decoration: const InputDecoration(labelText: 'Name'),
                              controller: TextEditingController(text: contact['name']),
                              onChanged: (val) => _contacts[i]['name'] = val,
                            ),
                            TextField(
                              enabled: _isEditable,
                              decoration: const InputDecoration(labelText: 'Phone'),
                              controller: TextEditingController(text: contact['phone']),
                              keyboardType: TextInputType.phone,
                              onChanged: (val) => _contacts[i]['phone'] = val,
                            ),
                            TextField( // Added Email Field
                              enabled: _isEditable,
                              decoration: const InputDecoration(labelText: 'Email'),
                              controller: TextEditingController(text: contact['email']),
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) => _contacts[i]['email'] = val,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (_isEditable) ...[
                    TextButton.icon(icon: const Icon(Icons.add), label: const Text('Add Contact'), onPressed: _addContact),
                    ElevatedButton(onPressed: _saveContacts, child: const Text('Save')),
                  ]
                ],
              ),
            ),
    );
  }
}