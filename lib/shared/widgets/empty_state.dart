import 'package:flutter/material.dart';

/// Empty state widget for when there's no data
class EmptyState extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final buttonText = actionText;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            if (buttonText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow.shade700,
                ),
                child: Text(buttonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
