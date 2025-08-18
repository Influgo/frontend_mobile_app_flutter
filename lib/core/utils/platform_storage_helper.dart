import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlatformStorageHelper {
  /// Guarda imagen localmente, compatible con web y móvil
  static Future<bool> saveImageBytes(String fileName, Uint8List imageBytes) async {
    try {
      if (kIsWeb) {
        // En web, usar SharedPreferences para guardar como base64
        final prefs = await SharedPreferences.getInstance();
        final base64String = base64Encode(imageBytes);
        return await prefs.setString('image_$fileName', base64String);
      } else {
        // En móvil, usar el sistema de archivos normal
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$fileName';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(imageBytes);
        return true;
      }
    } catch (e) {
      print('Error saving image: $e');
      return false;
    }
  }

  /// Carga imagen desde almacenamiento local
  static Future<Uint8List?> loadImageBytes(String fileName) async {
    try {
      if (kIsWeb) {
        // En web, cargar desde SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final base64String = prefs.getString('image_$fileName');
        if (base64String != null) {
          return base64Decode(base64String);
        }
        return null;
      } else {
        // En móvil, cargar desde sistema de archivos
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$fileName';
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          return await imageFile.readAsBytes();
        }
        return null;
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  /// Elimina imagen del almacenamiento local
  static Future<bool> deleteImage(String fileName) async {
    try {
      if (kIsWeb) {
        // En web, eliminar de SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        return await prefs.remove('image_$fileName');
      } else {
        // En móvil, eliminar archivo
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$fileName';
        final imageFile = File(imagePath);
        if (await imageFile.exists()) {
          await imageFile.delete();
          return true;
        }
        return false;
      }
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Verifica si una imagen existe en el almacenamiento
  static Future<bool> imageExists(String fileName) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.containsKey('image_$fileName');
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$fileName';
        final imageFile = File(imagePath);
        return await imageFile.exists();
      }
    } catch (e) {
      print('Error checking image existence: $e');
      return false;
    }
  }
}