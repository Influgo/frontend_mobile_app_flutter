import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';

class ImageCompressionHelper {
  static final Logger _logger = Logger();
  
  // 3MB por imagen para dejar margen de seguridad (6MB total / 2 imágenes)
  static const int maxSizeInBytes = 3000000; // 3MB
  static const int targetWidth = 1024;
  static const int targetHeight = 1024;
  static const int initialQuality = 85;
  static const int minQuality = 30;

  /// Comprime una imagen si excede el tamaño máximo permitido
  static Future<Uint8List> compressImage(Uint8List imageBytes, {String? fileName}) async {
    final double originalSizeMB = imageBytes.length / (1024 * 1024);
    _logger.i('Imagen original: ${originalSizeMB.toStringAsFixed(2)}MB${fileName != null ? ' ($fileName)' : ''}');

    // Si ya está dentro del límite, no comprimir
    if (imageBytes.length <= maxSizeInBytes) {
      _logger.i('Imagen dentro del límite, no se requiere compresión');
      return imageBytes;
    }

    try {
      Uint8List compressedBytes = imageBytes;
      int currentQuality = initialQuality;

      // Comprimir progresivamente hasta alcanzar el tamaño objetivo
      while (compressedBytes.length > maxSizeInBytes && currentQuality >= minQuality) {
        _logger.i('Comprimiendo con calidad: $currentQuality%');
        
        compressedBytes = await FlutterImageCompress.compressWithList(
          imageBytes,
          quality: currentQuality,
          minWidth: targetWidth,
          minHeight: targetHeight,
          format: CompressFormat.jpeg,
        );

        final double compressedSizeMB = compressedBytes.length / (1024 * 1024);
        _logger.i('Resultado: ${compressedSizeMB.toStringAsFixed(2)}MB');

        // Si alcanzamos el tamaño objetivo, salir del bucle
        if (compressedBytes.length <= maxSizeInBytes) {
          break;
        }

        // Reducir calidad para la siguiente iteración
        currentQuality -= 15;
      }

      final double finalSizeMB = compressedBytes.length / (1024 * 1024);
      final double compressionRatio = (1 - (compressedBytes.length / imageBytes.length)) * 100;
      
      _logger.i('Compresión completada:');
      _logger.i('- Tamaño final: ${finalSizeMB.toStringAsFixed(2)}MB');
      _logger.i('- Reducción: ${compressionRatio.toStringAsFixed(1)}%');
      _logger.i('- Calidad final: $currentQuality%');

      // Verificar si la compresión fue exitosa
      if (compressedBytes.length > maxSizeInBytes) {
        _logger.w('⚠️ Imagen aún excede el límite después de compresión máxima');
      }

      return compressedBytes;
    } catch (e) {
      _logger.e('Error al comprimir imagen: $e');
      // En caso de error, retornar imagen original
      return imageBytes;
    }
  }

  /// Valida si una imagen cumple con los requisitos de tamaño
  static bool validateImageSize(Uint8List imageBytes) {
    return imageBytes.length <= maxSizeInBytes;
  }

  /// Obtiene información del tamaño de la imagen
  static Map<String, dynamic> getImageInfo(Uint8List imageBytes) {
    final double sizeMB = imageBytes.length / (1024 * 1024);
    final bool isValid = imageBytes.length <= maxSizeInBytes;
    
    return {
      'sizeInBytes': imageBytes.length,
      'sizeInMB': double.parse(sizeMB.toStringAsFixed(2)),
      'isValid': isValid,
      'maxSizeInMB': maxSizeInBytes / (1024 * 1024),
    };
  }

  /// Formatea el tamaño en MB o KB según corresponda
  static String formatFileSize(int sizeInBytes) {
    if (sizeInBytes >= 1024 * 1024) {
      final double sizeMB = sizeInBytes / (1024 * 1024);
      return '${sizeMB.toStringAsFixed(1)}MB';
    } else {
      final double sizeKB = sizeInBytes / 1024;
      return '${sizeKB.toStringAsFixed(0)}KB';
    }
  }
}