import 'package:medicare_app/data/repositories/auth_repository.dart';
import '../../entities/user_entity.dart';

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<UserEntity> execute() async {
    return await repository.getProfile();
  }
}
