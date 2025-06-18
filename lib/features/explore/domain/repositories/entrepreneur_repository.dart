import 'package:frontend_mobile_app_flutter/features/explore/data/models/entrepreneurship_model.dart';

abstract class EntrepreneurRepository {
  Future<List<Entrepreneurship>> getEntrepreneurs();
}
