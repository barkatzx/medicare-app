import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        title: Text('My Addresses', style: CustomTextStyle.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: CustomTheme.textPrimary, size: 16),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(isLoading, addresses, addressProvider),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddressForm(context),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Add New Address', style: CustomTextStyle.button),
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildBody(bool isLoading, List<AddressEntity> addresses, AddressProvider addressProvider) {
    if (isLoading && addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: CustomTheme.primaryColor.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(Icons.location_on_outlined, size: 64, color: CustomTheme.primaryColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 24),
            Text('No Addresses Saved', style: CustomTextStyle.heading3),
            const SizedBox(height: 8),
            Text('Add your shipping addresses for a faster checkout', style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(addressProviderNotifier).loadAddresses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          return _buildAddressCard(addresses[index], addressProvider);
        },
      ),
    );
  }

  Widget _buildAddressCard(AddressEntity address, AddressProvider addressProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: address.isDefault ? Border.all(color: CustomTheme.primaryColor.withOpacity(0.5), width: 1.5) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (address.isDefault ? CustomTheme.primaryColor : CustomTheme.backgroundColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    address.isDefault ? Icons.home_rounded : Icons.location_on_rounded,
                    size: 18,
                    color: address.isDefault ? CustomTheme.primaryColor : CustomTheme.textTertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.isDefault ? 'Default Address' : 'Shipping Address',
                        style: CustomTextStyle.bodySmall.copyWith(fontWeight: CustomTheme.fontWeightBold, color: address.isDefault ? CustomTheme.primaryColor : CustomTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildActionButton(Icons.edit_outlined, Colors.blue, () => _showAddressForm(context, address: address)),
                    const SizedBox(width: 8),
                    _buildActionButton(Icons.delete_outline_rounded, Colors.red, () => _showDeleteConfirmation(address)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.street, style: CustomTextStyle.bodyLarge.copyWith(fontWeight: CustomTheme.fontWeightSemiBold)),
                  const SizedBox(height: 4),
                  Text('${address.city}, ${address.state} ${address.postalCode}', style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary)),
                  Text(address.country, style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textSecondary)),
                ],
              ),
            ),
            if (!address.isDefault) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: TextButton(
                  onPressed: () => addressProvider.setDefaultAddress(address.id),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Set as Default', style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.primaryColor, fontWeight: CustomTheme.fontWeightBold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: color),
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusXL)),
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('Cancel', style: TextStyle(color: CustomTheme.textTertiary))),
          TextButton(
            onPressed: () async {
              final provider = ref.read(addressProviderNotifier);
              await provider.deleteAddress(address.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
    final isLoading = ref.watch(addressProviderNotifier).isLoading;

    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: CustomTheme.borderLight, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text(widget.address == null ? 'Add New Address' : 'Update Address', style: CustomTextStyle.heading3),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField('Street Address', _streetController, Icons.location_on_outlined),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField('City', _cityController, Icons.location_city_outlined)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildField('Postal Code', _zipController, Icons.markunread_mailbox_outlined)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildField('State/Division', _stateController, Icons.map_outlined),
                    const SizedBox(height: 16),
                    _buildField('Country', _countryController, Icons.public_outlined),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Set as default address', style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightSemiBold)),
                      value: _isDefault,
                      onChanged: (val) => setState(() => _isDefault = val),
                      activeColor: CustomTheme.primaryColor,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(widget.address == null ? 'Save Address' : 'Update Changes', style: CustomTextStyle.button),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomTextStyle.bodySmall.copyWith(fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightSemiBold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: CustomTheme.primaryColor),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD), borderSide: const BorderSide(color: CustomTheme.primaryColor, width: 1.5)),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = ref.read(addressProviderNotifier);
    final success = widget.address == null
        ? await provider.addAddress(AddressEntity(id: '', userId: '', street: _streetController.text, city: _cityController.text, state: _stateController.text, postalCode: _zipController.text, country: _countryController.text, isDefault: _isDefault))
        : await provider.updateAddress(widget.address!.id, {'street': _streetController.text, 'city': _cityController.text, 'state': _stateController.text, 'postalCode': _zipController.text, 'country': _countryController.text, 'isDefault': _isDefault});
    if (success && mounted) Navigator.of(context).pop();
  }
}
