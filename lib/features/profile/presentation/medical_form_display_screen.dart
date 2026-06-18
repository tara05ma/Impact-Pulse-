

import 'package:flutter/material.dart';
import 'medical_form_screen.dart';

class MedicalFormDisplayScreen extends StatelessWidget {
  final Map<String, dynamic> formData;
  final VoidCallback? onEdit;

  const MedicalFormDisplayScreen({
    super.key,
    required this.formData,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Form Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicalFormScreen(
                    initialData: formData,
                    editable: true,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            _buildDetailRow('First Name', _displayText(formData['first_name'])),
            _buildDetailRow('Last Name', _displayText(formData['last_name'])),
            _buildDetailRow('Age', _displayText(formData['age']?.toString())),
            _buildDetailRow('Gender', _displayText(formData['gender'])),
            _buildDetailRow('Contact Number', _displayText(formData['contact'] ?? formData['phone_number'] ?? formData['contact_number'] ?? formData['phone_controller'])),
            _buildDetailRow('Email', _displayText(formData['email'] ?? formData['email_controller'])),
            _buildBulletListRow('Family History', formData['family_history']),
            _buildBulletListRow('Current Symptoms', formData['current_symptoms']),
            _buildDetailRow('Medications', _displayText(formData['medications_list'])),
            _buildDetailRow('Allergies', _displayText(formData['allergies_list'])),
            _buildDetailRow('Tobacco Use', _displayText(formData['tobacco_use'])),
            _buildDetailRow('Tobacco Details', _displayText(formData['tobacco_details'])),
            _buildDetailRow('Alcohol Consumption', _displayText(formData['alcohol_consumption'])),
          ],
        ),
      ),
    );
  }

  String _displayText(dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return 'N/A';
    }
    return value.toString();
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletListRow(String label, dynamic map) {
    List<String> checked = [];
    if (map is Map) {
      map.forEach((key, value) {
        if (value == true && key != 'Other') checked.add(key);
        if (key == 'Other' && value == true && map['other_text'] != null && map['other_text'].toString().trim().isNotEmpty) {
          checked.add(map['other_text']);
        }
      });
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: checked.isEmpty
                ? const Text('N/A', style: TextStyle(fontSize: 16))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: checked.map((e) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(child: Text(e, style: const TextStyle(fontSize: 16))),
                      ],
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
