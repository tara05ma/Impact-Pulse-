import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'medical_form_display_screen.dart';


class MedicalFormScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final bool editable;
  const MedicalFormScreen({super.key, this.initialData, this.editable = true});

  @override
  State<MedicalFormScreen> createState() => _MedicalFormScreenState();
}

class _MedicalFormScreenState extends State<MedicalFormScreen> {
  bool get _isEditable => widget.editable;
  final _formKey = GlobalKey<FormState>();
  
  // FIX 1: Define the missing variable
  String? _editingId;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _otherFamilyController = TextEditingController();
  final _otherSymptomController = TextEditingController();
  final _tobaccoDetailsController = TextEditingController();
  final _medsListController = TextEditingController();
  final _allergiesListController = TextEditingController();

  // Selections
  String? _gender;
  String _takingMeds = 'No';
  String _hasAllergies = 'No';
  String _tobaccoUse = 'No';
  String _illegalDrugs = 'No';
  String _alcoholFreq = 'Never';

  // Checkbox Maps
  final Map<String, bool> _familyHistory = {
    'Asthma': false, 'Cancer': false, 'Cardiac disease': false, 
    'Diabetes': false, 'Hypertension': false, 'Psychiatric disorder': false, 
    'Epilepsy': false, 'Other': false,
  };

  final Map<String, bool> _currentSymptoms = {
    'Chest pain': false, 'Respiratory': false, 'Cardiac disease': false, 
    'Cardiovascular': false, 'Hematological': false, 'Lymphatic': false, 
    'Neurological': false, 'Psychiatric': false, 'Gastrointestinal': false, 
    'Genitourinary': false, 'Weight gain': false, 'Weight loss': false, 
    'Musculoskeletal': false, 'Other': false,
  };

  // FIX 2: Add logic to fill the form when editing
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = widget.initialData ?? ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _editingId == null) {
      setState(() {
        _editingId = args['id'];
        _firstNameController.text = args['first_name'] ?? '';
        _lastNameController.text = args['last_name'] ?? '';
        _ageController.text = args['age']?.toString() ?? '';
        _gender = args['gender'];
        _phoneController.text = args['phone_number'] ?? '';
        _emailController.text = args['email'] ?? '';
        _medsListController.text = args['medications_list'] ?? '';
        _allergiesListController.text = args['allergies_list'] ?? '';
        _tobaccoUse = args['tobacco_use'] ?? 'No';
        _tobaccoDetailsController.text = args['tobacco_details'] ?? '';
        _alcoholFreq = args['alcohol_consumption'] ?? 'Never';
        final history = args['family_history'] as Map<String, dynamic>?;
        if (history != null) {
          history.forEach((key, value) {
            if (_familyHistory.containsKey(key)) _familyHistory[key] = value == true;
          });
        }
        final symptoms = args['current_symptoms'] as Map<String, dynamic>?;
        if (symptoms != null) {
          symptoms.forEach((key, value) {
            if (_currentSymptoms.containsKey(key)) _currentSymptoms[key] = value == true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Medical History Form", style: TextStyle(color: Color(0xFF1A3B8B), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: AbsorbPointer(
        absorbing: !_isEditable,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNameSection(),
                const SizedBox(height: 20),
                _buildAgeGenderSection(),
                const SizedBox(height: 20),
                _buildContactSection(),
                const Divider(height: 40),
                _buildCheckboxSection("Check the conditions that apply to you or your relatives:", _familyHistory, _otherFamilyController),
                const SizedBox(height: 30),
                _buildCheckboxSection("Check the symptoms you are currently experiencing:", _currentSymptoms, _otherSymptomController),
                const Divider(height: 40),
                _buildRadioSection("Are you currently taking any medication?", ['Yes', 'No'], _takingMeds, (v) => setState(() => _takingMeds = v!)),
                if (_takingMeds == 'Yes') _buildParagraphInput("Please list them.", _medsListController),
                const SizedBox(height: 20),
                _buildRadioSection("Do you have any medication allergies?", ['Yes', 'No', 'Not Sure'], _hasAllergies, (v) => setState(() => _hasAllergies = v!)),
                if (_hasAllergies == 'Yes') _buildParagraphInput("Please list them.", _allergiesListController),
                const Divider(height: 40),
                _buildRadioSection("Do you use any kind of tobacco?", ['Yes', 'No'], _tobaccoUse, (v) => setState(() => _tobaccoUse = v!)),
                if (_tobaccoUse == 'Yes') _buildParagraphInput("What kind of tobacco products? How long?", _tobaccoDetailsController),
                const SizedBox(height: 20),
                _buildRadioSection("Do you use any kind of illegal drugs?", ['Yes', 'No'], _illegalDrugs, (v) => setState(() => _illegalDrugs = v!)),
                const SizedBox(height: 20),
                _buildRadioSection("How often do you consume alcohol?", ['Daily', 'Weekly', 'Monthly', 'Occasionally', 'Never'], _alcoholFreq, (v) => setState(() => _alcoholFreq = v!)),
                const SizedBox(height: 40),
                if (_isEditable) _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildNameSection() {
    return Row(
      children: [
        Expanded(child: _buildTextField(_firstNameController, "First Name")),
        const SizedBox(width: 15),
        Expanded(child: _buildTextField(_lastNameController, "Last Name")),
      ],
    );
  }

  Widget _buildAgeGenderSection() {
    return Row(
      children: [
        Expanded(child: _buildTextField(_ageController, "What is your age?", hint: "ex: 23")),
        const SizedBox(width: 15),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _gender, // Ensure dropdown reflects saved value
            decoration: const InputDecoration(labelText: "What is your gender?", border: OutlineInputBorder()),
            items: ["Male", "Female", "Other"].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (val) => setState(() => _gender = val),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      children: [
        _buildTextField(_phoneController, "Contact Number", hint: "(000) 000-0000"),
        const SizedBox(height: 15),
        _buildTextField(_emailController, "Email Address", hint: "example@example.com"),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
        ),
      ],
    );
  }

  Widget _buildCheckboxSection(String title, Map<String, bool> map, TextEditingController otherController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          children: map.keys.map((key) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: CheckboxListTile(
                title: Text(key, style: const TextStyle(fontSize: 13)),
                value: map[key],
                onChanged: (val) => setState(() => map[key] = val!),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            );
          }).toList(),
        ),
        if (map['Other'] == true)
          TextField(controller: otherController, decoration: const InputDecoration(hintText: "Please specify other...")),
      ],
    );
  }

  Widget _buildRadioSection(String title, List<String> options, String currentVal, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Wrap(
          children: options.map((opt) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(value: opt, groupValue: currentVal, onChanged: onChanged),
              Text(opt),
            ],
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildParagraphInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: "Type here...", border: OutlineInputBorder())),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2B468B), padding: const EdgeInsets.symmetric(vertical: 18)),
        onPressed: _submitForm,
        child: const Text("Submit", style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }

  Future<void> _submitForm() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = {
      'owner_id': user.id,
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()),
      'gender': _gender,
      'contact': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'family_history': _familyHistory,
      'current_symptoms': _currentSymptoms,
      'medications_list': _medsListController.text,
      'allergies_list': _allergiesListController.text,
      'tobacco_use': _tobaccoUse,
      'tobacco_details': _tobaccoDetailsController.text,
      'alcohol_consumption': _alcoholFreq,
    };

    // Prevent empty form submissions (all main fields empty)
    bool isEmpty =
      (data['first_name'] as String).isEmpty &&
      (data['last_name'] as String).isEmpty &&
      (data['age'] == null) &&
      (data['gender'] == null || (data['gender'] as String).isEmpty) &&
      (data['medications_list'] as String).isEmpty &&
      (data['allergies_list'] as String).isEmpty &&
      (data['tobacco_use'] == null || (data['tobacco_use'] as String).isEmpty) &&
      (data['tobacco_details'] as String).isEmpty &&
      (data['alcohol_consumption'] == null || (data['alcohol_consumption'] as String).isEmpty);

    if (isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in at least one field before submitting."), backgroundColor: Colors.red),
        );
      }
      return;
    }

    try {
      dynamic result;
      if (_editingId == null) {
        result = await Supabase.instance.client.from('dependents').insert(data).select().single();
      } else {
        await Supabase.instance.client.from('dependents').update(data).eq('id', _editingId!);
        // Fetch updated data for display
        result = data;
        result['id'] = _editingId;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Success! Data saved.")),
        );
        // After submit, always show display-only unless edit is triggered
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalFormDisplayScreen(
              formData: result,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}