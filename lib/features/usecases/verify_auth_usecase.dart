import 'package:medicare_app/features/repository/auth_repository.dart';

import '../entity/user_entity.dart';

class VerifyAuthUseCase {
  final AuthRepository repository;

  VerifyAuthUseCase(this.repository);

  Future<UserEntity> execute() async {
    return await repository.verifyAuth();
  }
}
