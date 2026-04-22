import '../generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

String stockUnit(BuildContext context, int n) {
  final t = AppLocalizations.of(context)!;

  if (n == 1) return t.piece;        // 1 قطعة
  if (n == 2) return t.piece;        // 2 قطعة (حسب طلبك)
  if (n >= 3 && n <= 10) return t.pieces; // 3-10 قطع
  return t.piece;                    // 11+ قطعة
}

String stockLabel(BuildContext context, int n) {
  final t = AppLocalizations.of(context)!;
  return "${t.availableStock}: $n ${stockUnit(context, n)}";
}
