import 'package:medicare_app/features/repository/auth_repository.dart';
import '../entity/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);
  Future<UserEntity> execute({
    required String phoneNumber,
    required String password,
  }) async {
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }

    if (password.isEmpty) {
      throw Exception('Password is required');
    }

    return await repository.login(phoneNumber: phoneNumber, password: password);
  }
}
