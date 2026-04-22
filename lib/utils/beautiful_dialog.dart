import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
ButtonStyle dialogButton(Color color) {
  return ElevatedButton.styleFrom(
    backgroundColor: color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 12),
  );
}

Future<T?> showBeautifulDialog<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  required List<Widget> actions,

  // NEW: Lottie animation type
  String? lottie, // "success", "warning", "delete"

  // NEW: Custom icon fallback
  IconData? icon,
  Color iconColor = Colors.blue,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) {
      return Container();
    },
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

              // Dialog card
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
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
                        // 🎞️ Lottie animation OR icon
                        if (lottie != null)
                          SizedBox(
                            height: 120,
                            child: Lottie.asset(
                              "assets/lottie/$lottie.json",
                              fit: BoxFit.contain,
                            ),
                          )
                        else if (icon != null)
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: iconColor.withOpacity(0.15),
                            child: Icon(icon, size: 36, color: iconColor),
                          ),

                        const SizedBox(height: 16),

                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),
                        content,
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
