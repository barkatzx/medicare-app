import '../../domain/entities/address_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> addAddress(AddressEntity address);
  Future<AddressEntity> updateAddress(String id, Map<String, dynamic> data);
  Future<void> setDefaultAddress(String id);
  Future<void> deleteAddress(String id);
}
