import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/entities/address_entity.dart';
import '../../providers/address_provider.dart';
import '../../widgets/common/custom_theme.dart';

class AddressesScreen extends ConsumerStatefulWidget {
  const AddressesScreen({super.key});

  @override
  ConsumerState<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends ConsumerState<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressProviderNotifier).loadAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = ref.watch(addressProviderNotifier);
    final addresses = addressProvider.addresses;
    final isLoading = addressProvider.isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: CustomTheme.backgroundColor,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Addresses', style: CustomTextStyle.heading2),
      ),
      body: _buildBody(isLoading, addresses, addressProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context),
        backgroundColor: CustomTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add New Address', style: CustomTextStyle.button),
      ),
    );
  }

  Widget _buildBody(bool isLoading, List<AddressEntity> addresses, AddressProvider addressProvider) {
    if (isLoading && addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (addressProvider.error != null && addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: CustomTheme.errorColor),
            const SizedBox(height: 16),
            Text('Failed to load addresses', style: CustomTextStyle.heading3),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                addressProvider.error!,
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(addressProviderNotifier).loadAddresses(),
              style: ElevatedButton.styleFrom(backgroundColor: CustomTheme.primaryColor),
              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 80, color: CustomTheme.textTertiary),
            const SizedBox(height: 16),
            Text('No addresses found', style: CustomTextStyle.heading3),
            const SizedBox(height: 8),
            Text('Add your first shipping address to get started', style: CustomTextStyle.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(addressProviderNotifier).loadAddresses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return _buildAddressCard(address, addressProvider);
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressEntity address, AddressProvider addressProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        boxShadow: CustomTheme.boxShadowLight,
        border: address.isDefault 
          ? Border.all(color: CustomTheme.primaryColor, width: 2) 
          : Border.all(color: CustomTheme.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryColor,
                      borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                    ),
                    child: const Text(
                      'DEFAULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () => _showAddressForm(context, address: address),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: CustomTheme.errorColor),
                      onPressed: () => _showDeleteConfirmation(address),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(address.street, style: CustomTextStyle.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${address.city}, ${address.state} ${address.postalCode}', style: CustomTextStyle.bodyMedium),
            Text(address.country, style: CustomTextStyle.bodyMedium),
            if (!address.isDefault) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => addressProvider.setDefaultAddress(address.id),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD)),
                  ),
                  child: Text('Set as Default', style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.primaryColor)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddressForm(BuildContext context, {AddressEntity? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressFormSheet(address: address),
    );
  }

  void _showDeleteConfirmation(AddressEntity address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressProviderNotifier).deleteAddress(address.id);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: CustomTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

class AddressFormSheet extends ConsumerStatefulWidget {
  final AddressEntity? address;
  const AddressFormSheet({super.key, this.address});

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  late TextEditingController _countryController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _streetController = TextEditingController(text: widget.address?.street ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? 'Dhaka Division');
    _zipController = TextEditingController(text: widget.address?.postalCode ?? '');
    _countryController = TextEditingController(text: widget.address?.country ?? 'Bangladesh');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.address == null ? 'Add New Address' : 'Edit Address',
                style: CustomTextStyle.heading2,
              ),
              const SizedBox(height: 24),
              _buildField('Street Address', _streetController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('City', _cityController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Postal Code', _zipController)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField('State/Division', _stateController),
              const SizedBox(height: 16),
              _buildField('Country', _countryController),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Set as default address', style: CustomTextStyle.bodyMedium),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
                activeTrackColor: CustomTheme.primaryColor.withOpacity(0.5),
                activeColor: CustomTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD)),
                  ),
                  child: Text(
                    widget.address == null ? 'Add Address' : 'Update Address',
                    style: CustomTextStyle.button,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = ref.read(addressProviderNotifier);
    bool success;

    if (widget.address == null) {
      success = await provider.addAddress(AddressEntity(
        id: '',
        userId: '',
        street: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _zipController.text,
        country: _countryController.text,
        isDefault: _isDefault,
      ));
    } else {
      success = await provider.updateAddress(widget.address!.id, {
        'street': _streetController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'postalCode': _zipController.text,
        'country': _countryController.text,
        'isDefault': _isDefault,
      });
    }

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'An error occurred')),
      );
    }
  }
}
