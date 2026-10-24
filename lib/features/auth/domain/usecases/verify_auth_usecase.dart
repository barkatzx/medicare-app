import 'package:medicare_app/features/auth/domain/repositories/auth_repository.dart';

import '../entities/user_entity.dart';

class VerifyAuthUseCase {
  final AuthRepository repository;

  VerifyAuthUseCase(this.repository);

  Future<UserEntity> execute() async {
    return await repository.verifyAuth();
  }
}
