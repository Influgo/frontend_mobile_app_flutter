import 'dart:typed_data';
import 'package:frontend_mobile_app_flutter/core/constants/api_endpoints.dart';
import 'package:frontend_mobile_app_flutter/core/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend_mobile_app_flutter/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestPasswordReset(String email);
  Future<http.Response> requestCheckToken(String token);
  Future<http.Response> registerInfluencer(Map<String, dynamic> influencerData);
  Future<http.Response> registerEntrepreneur(
      Map<String, dynamic> entrepreneurData);
  Future<http.Response> validateImages({
    required String userIdentifier,
    required Uint8List documentFrontImage,
    required Uint8List documentBackImage,
    required Uint8List profileImage,
  });
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

  Future<http.Response> requestCheckToken(String token) async {
    final url = Uri.parse('${APIHelper.buildUrl(checkTokenEndpoint)}/$token');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    return response;
  }

  @override
  Future<http.Response> registerInfluencer(
      Map<String, dynamic> influencerData) async {
    final url =
        Uri.parse(APIHelper.buildUrl(registerInfluencerEndpoint).toString());
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(influencerData),
    );
    return response;
  }

  @override
  Future<http.Response> registerEntrepreneur(
      Map<String, dynamic> entrepreneurData) async {
    final url =
        Uri.parse(APIHelper.buildUrl(registerEntrepreneurEndpoint).toString());
    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(entrepreneurData),
    );
    return response;
  }

  @override
  Future<http.Response> validateImages({
    required String userIdentifier,
    required Uint8List documentFrontImage,
    required Uint8List documentBackImage,
    required Uint8List profileImage,
  }) async {
    final url =
        Uri.parse(APIHelper.buildUrl(validateImagesEndpoint).toString());
    final request = http.MultipartRequest('POST', url)
      ..fields['userIdentifier'] = userIdentifier
      ..files.add(http.MultipartFile.fromBytes(
        'documentFrontImage',
        documentFrontImage,
        filename: 'documentFrontImage.jpg',
      ))
      ..files.add(http.MultipartFile.fromBytes(
        'documentBackImage',
        documentBackImage,
        filename: 'documentBackImage.jpg',
      ))
      ..files.add(http.MultipartFile.fromBytes(
        'profileImage',
        profileImage,
        filename: 'profileImage.jpg',
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw ServerException(message: 'Error validating images');
    }

    return response;
  }
}
