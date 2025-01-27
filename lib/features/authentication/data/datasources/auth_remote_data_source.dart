import 'package:frontend_mobile_app_flutter/core/constants/api_endpoints.dart';
import 'package:frontend_mobile_app_flutter/core/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_mobile_app_flutter/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestPasswordReset(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<void> requestPasswordReset(String email) async {
    final url =
        Uri.parse(APIHelper.buildUrl(forgotPasswordEndpoint).toString());
    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userIdentifier': email}),
    );

    if (response.statusCode != 200) {
      String errorMessage =
          'No se ha podido enviar la solicitud correctamente al servidor';
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('message')) {
          errorMessage = responseBody['message'] as String;
        }
      } catch (e) {}
      throw ServerException(message: errorMessage);
    }
  }
}
