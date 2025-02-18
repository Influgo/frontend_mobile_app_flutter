import 'package:shared_preferences/shared_preferences.dart';

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
  }
}
