import 'package:flutter/material.dart';
import '../services/activation_service.dart';
import '../generated/app_localizations.dart';

Future<bool> requireActivation(BuildContext context) async {
  final t = AppLocalizations.of(context)!;

  final ok = await ActivationService.isActivated();
  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t.requiresActivation)),
    );
  }
  return ok;
}
