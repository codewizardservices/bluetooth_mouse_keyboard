import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ================= COLORS =================
const Color lgRed = Color(0xFFFF5A1F);
const Color surfaceColor = Color(0xFF1A1A1A); // Deep Charcoal
const Color cardColor = Color(0xFF242424); // Dialog background
const Color titleColor = Color(0xFFFFFFFF); // Pure White
const Color bodyColor = Color(0xFFB0B0B0); // Light Grey
const Color shadowLight = Color(0xFF323232); // Subtle highlight

// ================= DIALOG =================
class DialogMessage extends StatefulWidget {
  final String title;
  final String message;
  final bool showProgress;
  final String? buttonText;

  const DialogMessage({
    super.key,
    required this.title,
    required this.message,
    this.showProgress = false,
    this.buttonText,
  });

  @override
  State<DialogMessage> createState() => _DialogMessageState();
}

class _DialogMessageState extends State<DialogMessage> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: cardColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TITLE
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 16),

              // MESSAGE
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: bodyColor,
                ),
              ),

              // PROGRESS
              if (widget.showProgress) ...[
                const SizedBox(height: 20),
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(lgRed),
                  ),
                ),
              ],

              // BUTTON
              if (widget.buttonText != null) ...[
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    child: _buildDialogButton(
                      label: widget.buttonText!,
                      onPressed: () {
                        // Navigator.pop(context);
                      SystemNavigator.pop();
                      }
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _buildDialogButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: lgRed,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


Future<void> showDialogMessage({
  required BuildContext context,
  required String title,
  required String message,
  bool showProgress = false,
  String? buttonText,
  bool barrierDismissible = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => DialogMessage(
      title: title,
      message: message,
      showProgress: showProgress,
      buttonText: buttonText,
    ),
  );
}
