import 'package:flutter/material.dart';

class WebSafeNetworkImage extends StatelessWidget {
  const WebSafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.network(imageUrl, fit: fit, errorBuilder: errorBuilder),
    );
  }
}
