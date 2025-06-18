import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';
import 'package:frontend_mobile_app_flutter/features/explore/domain/repositories/entrepreneur_repository.dart';

class GetEntrepreneurUsecase {

  final EntrepreneurRepository repository;

  GetEntrepreneurUsecase(this.repository);

  Future<List<Entrepreneurship>> call() async {
    return await repository.getEntrepreneurs();
  }

}
