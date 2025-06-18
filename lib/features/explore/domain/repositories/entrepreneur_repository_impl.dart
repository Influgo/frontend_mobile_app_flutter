import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/data/services/entrepreneurship_service.dart';
import 'package:frontend_mobile_app_flutter/features/explore/domain/repositories/entrepreneur_repository.dart';

class EntrepreneurRepositoryImpl implements EntrepreneurRepository {
  final EntrepreneurshipService service;

  EntrepreneurRepositoryImpl(this.service);

  @override
  Future<List<Entrepreneurship>> getEntrepreneurs() async{
    final response = await service.getEntrepreneurships();
    return response.content;
  }
}
