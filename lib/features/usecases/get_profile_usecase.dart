import 'package:medicare_app/features/repository/auth_repository.dart';
import '../entity/user_entity.dart';

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<UserEntity> execute() async {
    return await repository.getProfile();
  }
}
