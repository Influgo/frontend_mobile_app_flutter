import 'dart:typed_data';
import 'package:frontend_mobile_app_flutter/core/constants/api_endpoints.dart';
import 'package:frontend_mobile_app_flutter/core/utils/api_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:frontend_mobile_app_flutter/core/errors/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> requestPasswordReset(String email);
  Future<http.Response> requestCheckToken(String token);
  Future<http.Response> registerInfluencer(Map<String, dynamic> influencerData);
  Future<http.Response> registerEntrepreneur(
      Map<String, dynamic> entrepreneurData);
  Future<Map<String, dynamic>> validateImages({
    required String dni,
    required Uint8List documentFrontImage,
    required Uint8List profileImage,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;
  final Logger logger = Logger();

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

  @override
  Future<http.Response> requestCheckToken(String token) async {
    final url = Uri.parse('${APIHelper.buildUrl(checkTokenEndpoint)}/$token');

    final response = await client.get(
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
  Future<Map<String, dynamic>> validateImages({
    required String dni,
    required Uint8List documentFrontImage,
    required Uint8List profileImage,
  }) async {
    const String awsLambdaUrl = 'https://zwea5hhty3bfr66h2tyyi4k56u0eoohw.lambda-url.us-east-2.on.aws/';
    const String apiKey = 'Wb3qcG8dtSGan2TPC6A5PEZEPFuMu5ow';
    
    logger.i('Enviando imágenes al nuevo endpoint AWS Lambda...');
    logger.i('DNI: $dni');
    
    final url = Uri.parse(awsLambdaUrl);
    final request = http.MultipartRequest('POST', url)
      ..headers['x-app-secret'] = apiKey
      ..fields['dni'] = dni
      ..files.add(http.MultipartFile.fromBytes(
        'photo', // selfie
        profileImage,
        filename: 'photo.jpg',
      ))
      ..files.add(http.MultipartFile.fromBytes(
        'document', // documento frontal únicamente
        documentFrontImage,
        filename: 'document.jpg',
      ));

    logger.i('Enviando request a: $awsLambdaUrl');
    logger.i('Headers: ${request.headers}');
    logger.i('Fields: ${request.fields}');
    logger.i('Archivos: ${request.files.map((f) => f.field).toList()}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    logger.i('Respuesta recibida - Status: ${response.statusCode}');
    logger.i('Respuesta body: ${response.body}');

    if (response.statusCode != 200) {
      logger.e('Error en validación de imágenes - Status: ${response.statusCode}');
      logger.e('Error body: ${response.body}');
      throw ServerException(message: 'Error validating images: ${response.statusCode}');
    }

    try {
      final Map<String, dynamic> responseData = json.decode(response.body);
      logger.i('Response data parseada: $responseData');
      return responseData;
    } catch (e) {
      logger.e('Error parseando respuesta JSON: $e');
      throw ServerException(message: 'Error parsing response: $e');
    }
  }
}
