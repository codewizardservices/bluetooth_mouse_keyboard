import 'package:flutter/material.dart';

class SubscriptionFaqDialog extends StatelessWidget {
  const SubscriptionFaqDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Subscription Policies & Plan Info",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _faqItem(
                  theme,
                  "Is there a trial version?",
                  "No. The app does not offer a trial version.",
                ),
                const SizedBox(height: 16),
                _faqItem(
                  theme,
                  "Does the app renew automatically at the end of the subscription?",
                  "Yes. Your subscription renews automatically at the end of each billing period unless you cancel beforehand.",
                ),
                const SizedBox(height: 16),
                _faqItem(
                  theme,
                  "Can I cancel my subscription at any time?",
                  "Yes. You can cancel at any time by pressing the “Cancel Subscription” button.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(ThemeData theme, String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.4,
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}

// Usage:
// showDialog(
//   context: context,
//   builder: (_) => const SubscriptionFaqDialog(),
// );
