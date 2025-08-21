import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class MediaValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? fileSizeInMB;
  final Duration? videoDuration;

  MediaValidationResult({
    required this.isValid,
    this.errorMessage,
    this.fileSizeInMB,
    this.videoDuration,
  });
}

class MediaValidationHelper {
  // Constantes de validación
  static const double maxImageSizeInMB = 3.0; // 3MB por imagen (6MB total / 2 imágenes)
  static const Duration maxVideoDuration = Duration(minutes: 1);
  static const int maxTotalFiles = 3;

  /// Valida una imagen basándose en el tamaño del archivo
  static Future<MediaValidationResult> validateImage(File imageFile) async {
    try {
      // Obtener el tamaño del archivo
      final int fileSizeInBytes = await imageFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > maxImageSizeInMB) {
        return MediaValidationResult(
          isValid: false,
          errorMessage: 'La imagen debe pesar máximo ${maxImageSizeInMB.toInt()}MB. Tu imagen pesa ${fileSizeInMB.toStringAsFixed(1)}MB.',
          fileSizeInMB: fileSizeInMB,
        );
      }

      return MediaValidationResult(
        isValid: true,
        fileSizeInMB: fileSizeInMB,
      );
    } catch (e) {
      return MediaValidationResult(
        isValid: false,
        errorMessage: 'Error al validar la imagen: $e',
      );
    }
  }

  /// Valida un video basándose en la duración
  static Future<MediaValidationResult> validateVideo(File videoFile) async {
    VideoPlayerController? controller;
    
    try {
      // Crear el controlador del video
      controller = VideoPlayerController.file(videoFile);
      await controller.initialize();

      final Duration? duration = controller.value.duration;
      
      if (duration == null) {
        return MediaValidationResult(
          isValid: false,
          errorMessage: 'No se pudo determinar la duración del video.',
        );
      }

      if (duration > maxVideoDuration) {
        final int durationInSeconds = duration.inSeconds;
        final int maxDurationInSeconds = maxVideoDuration.inSeconds;
        
        String formatDuration(Duration duration) {
          final minutes = duration.inMinutes;
          final seconds = duration.inSeconds % 60;
          return '${minutes}m ${seconds}s';
        }

        return MediaValidationResult(
          isValid: false,
          errorMessage: 'El video debe durar máximo ${formatDuration(maxVideoDuration)}. Tu video dura ${formatDuration(duration)}.',
          videoDuration: duration,
        );
      }

      // Validar también el tamaño del archivo
      final int fileSizeInBytes = await videoFile.length();
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      return MediaValidationResult(
        isValid: true,
        videoDuration: duration,
        fileSizeInMB: fileSizeInMB,
      );
    } catch (e) {
      return MediaValidationResult(
        isValid: false,
        errorMessage: 'Error al validar el video: $e',
      );
    } finally {
      // Limpiar el controlador
      await controller?.dispose();
    }
  }

  /// Valida múltiples archivos y filtra solo los válidos
  static Future<Map<String, dynamic>> validateMultipleFiles(
    List<File> files, 
    String fileType
  ) async {
    List<File> validFiles = [];
    List<String> errorMessages = [];
    int invalidCount = 0;

    for (File file in files) {
      MediaValidationResult result;
      
      if (fileType == 'IMAGE') {
        result = await validateImage(file);
      } else if (fileType == 'VIDEO') {
        result = await validateVideo(file);
      } else {
        continue;
      }

      if (result.isValid) {
        validFiles.add(file);
      } else {
        invalidCount++;
        if (result.errorMessage != null) {
          errorMessages.add(result.errorMessage!);
        }
      }
    }

    return {
      'validFiles': validFiles,
      'errorMessages': errorMessages,
      'invalidCount': invalidCount,
      'totalCount': files.length,
    };
  }

  /// Obtiene un mensaje de resumen para múltiples archivos validados
  static String getValidationSummaryMessage(Map<String, dynamic> validationResult) {
    final int validCount = (validationResult['validFiles'] as List).length;
    final int invalidCount = validationResult['invalidCount'] as int;
    final int totalCount = validationResult['totalCount'] as int;

    if (invalidCount == 0) {
      return '$validCount ${validCount == 1 ? 'archivo agregado' : 'archivos agregados'} exitosamente.';
    } else if (validCount == 0) {
      return 'Ningún archivo fue agregado. $invalidCount ${invalidCount == 1 ? 'archivo no cumple' : 'archivos no cumplen'} los requisitos.';
    } else {
      return '$validCount de $totalCount archivos agregados. $invalidCount no cumplieron los requisitos.';
    }
  }

  /// Formatea el tamaño de archivo en MB
  static String formatFileSize(double sizeInMB) {
    if (sizeInMB < 1) {
      return '${(sizeInMB * 1024).toStringAsFixed(0)}KB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)}MB';
    }
  }

  /// Formatea la duración del video
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}