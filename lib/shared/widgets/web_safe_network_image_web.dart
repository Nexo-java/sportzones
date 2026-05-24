// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

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

  static final Set<String> _registeredViewTypes = <String>{};

  String _viewTypeFor(String url) => 'web-safe-network-image-${url.hashCode}';

  void _registerFactory(String viewType) {
    if (_registeredViewTypes.contains(viewType)) return;
    _registeredViewTypes.add(viewType);

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final image = html.ImageElement()
        ..src = imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = fit == BoxFit.contain ? 'contain' : 'cover'
        ..style.objectPosition = 'center'
        ..draggable = false;
      return image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewType = _viewTypeFor(imageUrl);
    _registerFactory(viewType);
    return SizedBox(
      width: width,
      height: height,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
