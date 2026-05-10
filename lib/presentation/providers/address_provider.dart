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
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAddress(AddressEntity address) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newAddress = await addressRepository.addAddress(address);
      _addresses = [..._addresses, newAddress];
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAddress(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

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
      final updatedAddress = await addressRepository.updateAddress(id, data);
      final currentIndex = _addresses.indexWhere((a) => a.id == id);
      if (currentIndex != -1) {
        _addresses[currentIndex] = updatedAddress;
      } else {
        _addresses.add(updatedAddress);
      }
      return true;
    } catch (e) {
      _addresses = oldAddresses; // Rollback
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await addressRepository.setDefaultAddress(id);
      // Update local state for immediate feedback
      _addresses = _addresses.map((a) {
        return a.copyWith(isDefault: a.id == id);
      }).toList();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final oldAddresses = List<AddressEntity>.from(_addresses);
    
    // Optimistic Delete
    _addresses.removeWhere((a) => a.id == id);
    notifyListeners();

    try {
      await addressRepository.deleteAddress(id);
      return true;
    } catch (e) {
      _addresses = oldAddresses; // Rollback
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
