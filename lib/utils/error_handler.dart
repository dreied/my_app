import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

void showActivationError(BuildContext context, Object e) {
  final t = AppLocalizations.of(context)!;
  String message;

  switch (e.toString()) {
    case "Exception: activationRequiredProducts":
      message = t.activationRequiredProducts;
      break;
    case "Exception: activationRequiredSales":
      message = t.activationRequiredSales;
      break;
    case "Exception: activationRequiredCustomers":
      message = t.activationRequiredCustomers;
      break;
    default:
      message = e.toString();
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
