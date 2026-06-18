import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color safetyOrange = Color(0xFFFF8C00);
    const Color ochre = Color(0xFFB8860B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Ensure your logo is in assets/images/logo.png
              Image.asset(
                'assets/images/logo.png',
                height: 150,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.bolt, size: 100, color: safetyOrange
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'ImpactPulse',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'Precision Emergency Response',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: ochre,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              // Primary Login Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
              
              const SizedBox(height: 15),

              // Secondary Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Sign Up', 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}