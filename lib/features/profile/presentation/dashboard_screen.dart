
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'medical_form_display_screen.dart';
import 'emergency_contacts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _familyMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFamilyData();
  }

  Future<void> _fetchFamilyData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await Supabase.instance.client
        .from('dependents')
        .select()
        .eq('owner_id', user.id)
        .order('created_at', ascending: false);
    
    if (mounted) {
      setState(() {
        _familyMembers = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("ImpactPulse"),
        backgroundColor: const Color(0xFFFF8C00),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Profile'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              setState(() {
                                _profileImage = File(picked.path);
                              });
                              Navigator.of(context).pop();
                            }
                          },
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                            child: _profileImage == null ? const Icon(Icons.person, size: 40) : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Change Photo'),
                          onPressed: () async {
                            final picked = await _picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              setState(() {
                                _profileImage = File(picked.path);
                              });
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(user?.userMetadata?['username'] ?? user?.email ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null ? const Icon(Icons.person) : null,
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFFF8C00)),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.medical_information),
              title: const Text("Medical History"),
              onTap: () {
                Navigator.pop(context);
                if (_familyMembers.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicalFormDisplayScreen(formData: _familyMembers.first),
                    ),
                  ).then((_) => _fetchFamilyData());
                } else {
                  Navigator.pushNamed(context, '/medical_form').then((_) => _fetchFamilyData());
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.contacts),
              title: const Text("Emergency Contacts"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyContactsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text("Add Family Member"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/medical_form').then((_) => _fetchFamilyData());
              },
            ),
              ListTile(
                leading: const Icon(Icons.car_crash),
                title: const Text("Crash Detection"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/crash_detection');
                },
              ),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _familyMembers.isEmpty
              ? _buildEmptyState(context)
              : _buildMemberList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Builder(
        builder: (buttonContext) => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C00),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () => Scaffold.of(buttonContext).openDrawer(),
          child: const Text(
            "Get started", 
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _familyMembers.length,
      itemBuilder: (context, index) {
        final member = _familyMembers[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              "${member['first_name']} ${member['last_name']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: const Text("Tap to view details"),
            children: [
              // Removed 'const' here to prevent errors
              const Divider(), 
              _buildCategoryTile(
                context, 
                "Medical Information", 
                member, 
                '/medical_form',
              ),
              _buildCategoryTile(
                context, 
                "Emergency Contacts", 
                member, 
                '/emergency_contacts',
              ),
              const SizedBox(height: 8), 
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryTile(BuildContext context, String title, Map<String, dynamic> member, String route) {
    return ListTile(
      title: Text(
        title, 
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2B468B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () async {
          if (route == '/medical_form') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicalFormDisplayScreen(formData: member),
              ),
            ).then((_) => _fetchFamilyData());
          } else if (route == '/emergency_contacts') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmergencyContactsScreen(),
              ),
            );
          } else {
            Navigator.pushNamed(
              context,
              route,
              arguments: member,
            ).then((_) => _fetchFamilyData());
          }
        },
        child: const Text("View Now", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}