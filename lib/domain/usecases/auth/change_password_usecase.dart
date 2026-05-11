import 'package:medicare_app/data/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase({required this.repository});

  Future<void> execute({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
