import 'package:flutter/material.dart';
import 'login_pin_screen.dart';

class StartupPinGuard extends StatefulWidget {
  final Widget child;

  const StartupPinGuard({required this.child, super.key});

  @override
  State<StartupPinGuard> createState() => _StartupPinGuardState();
}

class _StartupPinGuardState extends State<StartupPinGuard> {
  bool _checking = true;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openLoginPin();
    });
  }

  Future<void> _openLoginPin() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const LoginPinScreen()),
    );

    if (!mounted) return;

    setState(() {
      _unlocked = ok ?? false;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_unlocked) {
      return const Scaffold(
        body: Center(child: Text("Locked")),
      );
    }

    return widget.child;
  }
}
