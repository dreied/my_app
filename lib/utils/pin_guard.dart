import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../generated/app_localizations.dart';
import '../database/manager_dao.dart';

Future<bool> requireManagerPin(BuildContext context) async {
  final t = AppLocalizations.of(context)!;

  final pinController = TextEditingController();
  bool obscure = true;

  // Check if PIN exists in SQLite
  final hasPin = await ManagerDao.hasPin();

  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );

      return Transform.translate(
        offset: Offset(0, 50 * (1 - curved.value)),
        child: Opacity(
          opacity: animation.value,
          child: Stack(
            children: [
              // 🌫️ Blur background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black26),
              ),

              Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Material(
                      color: Colors.transparent,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🎞️ Lottie animation
                            SizedBox(
                              height: 120,
                              child: Lottie.asset(
                                hasPin
                                    ? "assets/lottie/Warning.json"
                                    : "assets/lottie/Check Mark.json",
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              hasPin ? t.enterManagerPin : t.setManagerPin,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 20),

                            // PIN FIELD
                            TextField(
                              controller: pinController,
                              obscureText: obscure,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                labelText: hasPin ? t.pin : t.createPin,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() => obscure = !obscure);
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // CONFIRM BUTTON
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                    icon: const Icon(Icons.lock_open,
                                        color: Colors.white),
                                    label: Text(
                                      t.confirm,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      final entered =
                                          pinController.text.trim();

                                      if (entered.length != 4) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text(t.pinMustBe4Digits)),
                                        );
                                        return;
                                      }

                                      // First‑time PIN creation
                                      if (!hasPin) {
                                        await ManagerDao.savePin(entered);
                                        Navigator.pop(context, true);
                                        return;
                                      }

                                      // PIN verification
                                      final ok =
                                          await ManagerDao.verifyPin(entered);
                                      if (ok) {
                                        Navigator.pop(context, true);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text(t.incorrectPin)),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // CANCEL BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey.shade300,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text(
                                  t.cancel,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}
