import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';


class MasterCodeScreen extends StatefulWidget {
  final String masterCode;

  const MasterCodeScreen({super.key, required this.masterCode});

  @override
  State<MasterCodeScreen> createState() => _MasterCodeScreenState();
}

class _MasterCodeScreenState extends State<MasterCodeScreen>
    with SingleTickerProviderStateMixin {
  String _pin = "";
  bool _showPin = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 20)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyTap(String value) {
    if (_pin.length >= 6) return;

    setState(() => _pin += value);

    if (_pin.length == 6) {
      Future.delayed(const Duration(milliseconds: 150), _validate);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _validate() {
    final t = AppLocalizations.of(context)!;

    if (_pin == widget.masterCode) {
      Navigator.pop(context, true);
    } else {
      _shakeController.forward(from: 0);
      setState(() => _pin = "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.incorrectMasterCode)),
      );
    }
  }

  Widget _buildDots() {
    final theme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value - 10, 0),
          child: child,
        );
      },
      child: Column(
        children: [
          if (_showPin)
            Text(
              _pin,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.onBackground,
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              final filled = i < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: filled ? theme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: filled ? theme.primary : theme.onBackground,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          IconButton(
            icon: Icon(
              _showPin ? Icons.visibility_off : Icons.visibility,
              color: theme.onBackground.withOpacity(0.7),
            ),
            onPressed: () => setState(() => _showPin = !_showPin),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String number) {
    final theme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _onKeyTap(number),
      child: Container(
        alignment: Alignment.center,
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.surface.withOpacity(0.2),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["1", "2", "3"].map(_buildKey).toList(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["4", "5", "6"].map(_buildKey).toList(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ["7", "8", "9"].map(_buildKey).toList(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildKey("0")],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _onBackspace,
          child: Icon(
            Icons.backspace,
            color: Theme.of(context).colorScheme.onBackground,
            size: 32,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Text(
              t.enterMasterCode,
              style: TextStyle(
                color: theme.onBackground,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildDots(),
            const Spacer(),
            _buildKeypad(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
