import 'dart:async';
import 'package:flutter/material.dart';

class CrashDetectionScreen extends StatefulWidget {
  const CrashDetectionScreen({super.key});

  @override
  State<CrashDetectionScreen> createState() => _CrashDetectionScreenState();
}

class _CrashDetectionScreenState extends State<CrashDetectionScreen> {
  Timer? _timer;
  int _secondsRemaining = 10;
  bool _isCountdownActive = false;

  /* ---------------- TIMER ---------------- */

  void _startTimer() {
    _timer?.cancel();

    setState(() {
      _isCountdownActive = true;
      _secondsRemaining = 10;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _triggerAutomatedSOS();
      }
    });
  }

  void _cancelAlert() {
    _timer?.cancel();

    setState(() {
      _isCountdownActive = false;
      _secondsRemaining = 10;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Alert Cancelled. Status: Safe."),
      ),
    );
  }

  /* ---------------- SOS (UI SAFE) ---------------- */

  void _triggerAutomatedSOS() {
    _timer?.cancel();

    if (!mounted) return;

    setState(() {
      _isCountdownActive = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🚨 SOS Sent"),
        content: const Text(
          "Emergency alert has been successfully sent to your emergency contacts via Email and SMS.\n\n",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /* ---------------- LIFECYCLE ---------------- */

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isCountdownActive ? const Color(0xFFFFF1F0) : Colors.white,
      appBar: AppBar(
        title: const Text("Emergency Detection"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isCountdownActive ? Icons.warning_rounded : Icons.security,
              size: 80,
              color: _isCountdownActive ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              "$_secondsRemaining",
              style: const TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _isCountdownActive
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(200, 200),
                      shape: const CircleBorder(),
                    ),
                    onPressed: _cancelAlert,
                    child: const Text(
                      "SAFE",
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Simulate Crash Trigger"),
                  ),
          ],
        ),
      ),
    );
  }
}
