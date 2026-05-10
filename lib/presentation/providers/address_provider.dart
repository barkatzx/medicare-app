import 'package:flutter/material.dart';
import '../../data/repositories/address_repository.dart';
import '../../domain/entities/address_entity.dart';

class AddressProvider extends ChangeNotifier {
  final AddressRepository addressRepository;

  AddressProvider({required this.addressRepository});

  List<AddressEntity> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<AddressEntity> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAddresses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _addresses = await addressRepository.getAddresses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(AddressEntity address) async {
    _isLoading = true;
    notifyListeners();
    try {
      await addressRepository.addAddress(address);
      await loadAddresses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    final oldAddresses = List<AddressEntity>.from(_addresses);
    final index = _addresses.indexWhere((a) => a.id == id);
    
    if (index != -1) {
      // Optimistic Update
      _addresses[index] = _addresses[index].copyWith(
        street: data['street'],
        city: data['city'],
        state: data['state'],
        postalCode: data['postalCode'],
        country: data['country'],
        isDefault: data['isDefault'],
      );
      notifyListeners();
    }

    try {
      await addressRepository.updateAddress(id, data);
      await loadAddresses(); // Force re-fetch for consistency
      return true;
    } catch (e) {
      _addresses = oldAddresses; // Rollback
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await addressRepository.setDefaultAddress(id);
      await loadAddresses(); // Force re-fetch for consistency
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String id) async {
    final oldAddresses = List<AddressEntity>.from(_addresses);
    
    // Optimistic Delete
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();

    try {
      await addressRepository.deleteAddress(id);
      await loadAddresses(); // Force re-fetch for consistency
      return true;
    } catch (e) {
      _addresses = oldAddresses; // Rollback
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }
}
