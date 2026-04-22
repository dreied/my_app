import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../database/manager_dao.dart';
import '../generated/app_localizations.dart';
import '../screens/master_code_screen.dart';

class LoginPinScreen extends StatefulWidget {
  const LoginPinScreen({super.key});

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = "";
  bool _hasPin = false;
  bool _isCreating = false;
  bool _showPin = false;

  static const String masterCode = "919822";

  final LocalAuthentication auth = LocalAuthentication();

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

    _loadPinState();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadPinState() async {
    final exists = await ManagerDao.hasPin();
    if (!mounted) return;

    setState(() {
      _hasPin = exists;
      _isCreating = !exists;
    });

    if (exists) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryFingerprint();
      });
    }
  }

  Future<void> _tryFingerprint() async {
    try {
      final supported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      final available = await auth.getAvailableBiometrics();

      if (!supported || !canCheck || !available.contains(BiometricType.fingerprint)) {
        return;
      }

      final success = await auth.authenticate(
        localizedReason: AppLocalizations.of(context)!.authenticateToUnlock,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Fingerprint error: $e");
    }
  }

  void _onKeyTap(String value) {
    if (_pin.length >= 4) return;

    setState(() => _pin += value);

    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 150), _validatePin);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _validatePin() async {
    final t = AppLocalizations.of(context)!;

    if (_isCreating) {
      await ManagerDao.savePin(_pin);
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    final ok = await ManagerDao.verifyPin(_pin);

    if (ok) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else {
      _shakeController.forward(from: 0);
      setState(() => _pin = "");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.incorrectPin)),
      );
    }
  }

  void _resetWithMasterCode() {
    setState(() {
      _isCreating = true;
      _pin = "";
    });
  }

  Widget _buildPinDots() {
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
        mainAxisSize: MainAxisSize.min,
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
            children: List.generate(4, (i) {
              final filled = i < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 18,
                height: 18,
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
          const SizedBox(height: 8),
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
    return Directionality(
      textDirection: TextDirection.ltr, // force LTR layout even in Arabic
      child: Column(
        children: [
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildKey("1"), _buildKey("2"), _buildKey("3")],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildKey("4"), _buildKey("5"), _buildKey("6")],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildKey("7"), _buildKey("8"), _buildKey("9")],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey("0"),
              GestureDetector(
                onTap: _onBackspace,
                child: Icon(
                  Icons.backspace,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 32,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.vertical -
                    64,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    _isCreating ? t.setManagerPin : t.enterManagerPin,
                    style: TextStyle(
                      color: theme.onBackground,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (_hasPin)
                    TextButton(
                      onPressed: () async {
                        final ok = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MasterCodeScreen(masterCode: masterCode),
                          ),
                        );

                        if (ok == true) {
                          _resetWithMasterCode();
                        }
                      },
                      child: Text(
                        t.forgotPin,
                        style: TextStyle(
                          color: theme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ),

                  const SizedBox(height: 40),
                  _buildPinDots(),

                  const SizedBox(height: 20),

                  if (_hasPin)
                    IconButton(
                      icon: Icon(
                        Icons.fingerprint,
                        color: theme.primary,
                        size: 40,
                      ),
                      onPressed: _tryFingerprint,
                    ),

                  const SizedBox(height: 20),
                  _buildKeypad(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
