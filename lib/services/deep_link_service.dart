// lib/services/deep_link_service.dart
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  static final _appLinks = AppLinks();
  static late BuildContext _context;

  static void initialize(BuildContext context) {
    _context = context;
    _handleIncomingLinks();
  }

  static void _handleIncomingLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  static void _handleDeepLink(Uri uri) {
    // Ejemplo: https://tuapp.com/entrepreneurship/123
    if (uri.pathSegments.length >= 2 &&
        uri.pathSegments[0] == 'entrepreneurship') {
      final entrepreneurshipId = uri.pathSegments[1];
      _navigateToEntrepreneurship(entrepreneurshipId);
    }
  }

  static void _navigateToEntrepreneurship(String id) {
    // Aquí necesitarías buscar el emprendimiento por ID
    // y navegar a la página de detalle
    Navigator.pushNamed(_context, '/entrepreneurship/$id');
  }

  static String generateEntrepreneurshipLink(String entrepreneurshipId) {
    return 'https://tuapp.com/entrepreneurship/$entrepreneurshipId';
  }
}
