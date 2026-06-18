import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSignUp() async {
  setState(() => _isLoading = true);
  try {
    final authResponse = await Supabase.instance.client.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (authResponse.user != null) {
      // Detailed insert to see where it fails
      await Supabase.instance.client.from('profiles').insert({
        'id': authResponse.user!.id,
        'full_name': _nameController.text.trim(),
      });

      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    }
  } on AuthException catch (e) {
    _showError("Auth Error: ${e.message}"); // Error like 'User already exists'
  } on PostgrestException catch (e) {
    _showError("Database Error: ${e.message}"); // Error like 'Permission Denied'
  } catch (e) {
    _showError("System Error: $e"); // Any other error
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account',
              style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Sign up to start protecting your family.', 
              style: GoogleFonts.poppins(color: Colors.grey[600])),
            const SizedBox(height: 30),
            _buildField(_nameController, "Full Name", Icons.person_outline),
            _buildField(_emailController, "Email", Icons.email_outlined),
            _buildField(_passwordController, "Password", Icons.lock_outline, obscure: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("Next Step", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}