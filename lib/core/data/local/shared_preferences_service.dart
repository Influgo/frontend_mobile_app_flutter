import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend_mobile_app_flutter/core/utils/platform_storage_helper.dart';

class SharedPreferencesService {
  Future<void> clearStoredValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('first_name_register');
    await prefs.remove('last_name_register');
    await prefs.remove('dni_register');
    await prefs.remove('passport_register');
    await prefs.remove('carnet_register');
    await prefs.remove('email_register');
    await prefs.remove('phone_register');
    await prefs.remove('password_register');
    await prefs.remove('confirm_password_register');
    await prefs.remove('document_type_register');
    await prefs.remove('acceptTermsAndConditions');
    await prefs.remove('business_name_register');
    await prefs.remove('business_nickname_register');
    await prefs.remove('ruc_register');
    await prefs.remove('instagram_register');
    await prefs.remove('tiktok_register');
    await prefs.remove('youtube_register');
    await prefs.remove('twitch_register');
    await prefs.remove('show_instagram_field_register');
    await prefs.remove('show_tiktok_field_register');
    await prefs.remove('show_youtube_field_register');
    await prefs.remove('show_twitch_field_register');
    await prefs.remove('saved_image_path_doc_front');
    await prefs.remove('saved_image_path_doc_back');

    try {
      final photoNames = [
        'document_front.jpg',
        'document_back.jpg',
        'selfie_register.jpg'
      ];

      for (final photoName in photoNames) {
        final success = await PlatformStorageHelper.deleteImage(photoName);
        if (success) {
          print('$photoName eliminada exitosamente');
        } else {
          print('$photoName no se encontró para eliminar');
        }
      }
    } catch (e) {
      print('Error al intentar eliminar las fotos: $e');
    }
  }
  // Guardar token
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
    // Guardar User ID
  Future<void> saveUserId(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);  
  }
  // Borrar todos los valores almacenados
  Future<void> clearStoredValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); 
    await prefs.remove('user_id');
  }


}
