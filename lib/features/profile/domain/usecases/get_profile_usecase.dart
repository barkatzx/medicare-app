import 'package:medicare_app/features/auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/entities/user_entity.dart';

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<UserEntity> execute() async {
    return await repository.getProfile();
  }
}
