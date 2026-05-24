import 'package:flutter/material.dart';

/// Loading indicator widget
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double? size;

  const LoadingIndicator({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          color: color ?? Colors.yellow.shade700,
          strokeWidth: 3,
        ),
      ),
    );
  }
}
