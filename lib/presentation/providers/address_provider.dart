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
      final newAddress = await addressRepository.addAddress(address);
      _addresses.add(newAddress);
      if (newAddress.isDefault) {
        // Update local state to reflect only one default
        _addresses = _addresses.map((a) => a.id == newAddress.id ? a : a.copyWith(isDefault: false)).toList();
      }
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
    _isLoading = true;
    notifyListeners();
    try {
      final updatedAddress = await addressRepository.updateAddress(id, data);
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        _addresses[index] = updatedAddress;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await addressRepository.setDefaultAddress(id);
      _addresses = _addresses.map((a) {
        return a.copyWith(isDefault: a.id == id);
      }).toList();
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
    _isLoading = true;
    notifyListeners();
    try {
      await addressRepository.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
