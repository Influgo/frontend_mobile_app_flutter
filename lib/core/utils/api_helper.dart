import '../constants/api_constants.dart';

class APIHelper {
  static Uri buildUrl(String endpoint) {
    return Uri.parse('$baseUrl$endpoint');
  }
}
