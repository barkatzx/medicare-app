import 'package:medicare_app/features/repository/auth_repository.dart';
import '../entity/user_entity.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserEntity> execute({
    required String name,
    required String pharmacyName,
    required String phoneNumber,
    String? fullAddress,
    String? divisionId,
    String? districtId,
    String? upazilaId,
  }) async {
    if (name.isEmpty) {
      throw Exception('Name is required');
    }
    if (pharmacyName.isEmpty) {
      throw Exception('Pharmacy name is required');
    }
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }

    return await repository.updateProfile(
      name: name,
      pharmacyName: pharmacyName,
      phoneNumber: phoneNumber,
      fullAddress: fullAddress,
      divisionId: divisionId,
      districtId: districtId,
      upazilaId: upazilaId,
    );
  }
}
