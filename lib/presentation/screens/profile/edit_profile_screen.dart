import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/user_entity.dart';
import 'package:medicare_app/domain/entities/address_entity.dart';
import 'package:medicare_app/presentation/providers/address_provider.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _pharmacyNameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProviderNotifier).currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _pharmacyNameController = TextEditingController(text: user?.pharmacyName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');

    // Refresh profile data on load to ensure we have latest fields
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProviderNotifier).getProfile();
      ref.read(addressProviderNotifier).loadAddresses();
    });
  }

  @override
  void didUpdateWidget(EditProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the provider updates the user data (e.g. from getProfile), sync controllers
    final user = ref.read(authProviderNotifier).currentUser;
    if (user != null) {
      if (_nameController.text.isEmpty && user.name.isNotEmpty) {
        _nameController.text = user.name;
      }
      if (_pharmacyNameController.text.isEmpty && (user.pharmacyName ?? '').isNotEmpty) {
        _pharmacyNameController.text = user.pharmacyName!;
      }
      if (_phoneController.text.isEmpty && user.phoneNumber.isNotEmpty) {
        _phoneController.text = user.phoneNumber;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pharmacyNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Remove focus to hide keyboard
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProviderNotifier).updateProfile(
          name: _nameController.text.trim(),
          pharmacyName: _pharmacyNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text('Profile updated successfully', style: CustomTextStyle.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusMD)),
          ),
        );
        Navigator.pop(context);
      } else {
        final error = ref.read(authProviderNotifier).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update profile'),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authProviderNotifier);
    final user = authProvider.currentUser;
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Edit Profile', style: CustomTextStyle.heading3),
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
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Profile Section
                        _buildProfileHeader(user),
                        const SizedBox(height: 24),

                        // Section 1: Account Info (Read-only)
                        _buildSectionTitle('Account Information'),
                        const SizedBox(height: 12),
                        _buildAccountInfoCard(user),
                        const SizedBox(height: 24),

                        // Section 2: Edit Fields
                        _buildSectionTitle('Personal Details'),
                        const SizedBox(height: 12),
                        _buildEditCard(),
                        const SizedBox(height: 24),

                        // Section 3: Shipping Addresses
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('Shipping Addresses'),
                            GestureDetector(
                              onTap: () => _showAddressForm(context),
                              child: Text(
                                '+ Add New',
                                style: CustomTextStyle.bodySmall.copyWith(
                                  color: CustomTheme.primaryColor,
                                  fontWeight: CustomTheme.fontWeightBold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildAddressesSection(),
                      ],
                    ),
                  ),
                ),
                // Bottom Floating Action Button
                _buildBottomAction(isLoading),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: CustomTextStyle.bodySmall.copyWith(
        fontWeight: CustomTheme.fontWeightBold,
        color: CustomTheme.textTertiary,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    final initials = user.name.isNotEmpty ? user.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'U';

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: CustomTheme.boxShadowMedium,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: CustomTextStyle.heading1.copyWith(
                          color: CustomTheme.primaryColor, 
                          fontSize: 36,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(user.name, style: CustomTextStyle.heading2.copyWith(fontSize: 24)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: CustomTextStyle.caption.copyWith(
                color: CustomTheme.primaryColor,
                fontWeight: CustomTheme.fontWeightBold,
                letterSpacing: 1.2,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(UserEntity user) {
    final formattedDate = DateFormat('MMMM dd, yyyy').format(user.createdAt);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
        boxShadow: CustomTheme.boxShadowLight,
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email Address', user.email),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: CustomTheme.borderLight),
          ),
          _buildInfoRow(
            Icons.verified_user_outlined,
            'Account Status',
            user.isApproved ? 'Verified & Approved' : 'Pending Approval',
            valueColor: user.isApproved ? CustomTheme.successColor : CustomTheme.warningColor,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: CustomTheme.borderLight),
          ),
          _buildInfoRow(Icons.calendar_today_outlined, 'Customer Since', formattedDate),
        ],
      ),
    );
  }

  Widget _buildEditCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
        boxShadow: CustomTheme.boxShadowLight,
      ),
      child: Column(
        children: [
          _buildFormTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            hint: 'How should we call you?',
            validator: (v) => v!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 24),
          _buildFormTextField(
            controller: _pharmacyNameController,
            label: 'Pharmacy Name',
            icon: Icons.local_pharmacy_outlined,
            hint: 'Your business name',
            validator: (v) => v!.isEmpty ? 'Business name is required' : null,
          ),
          const SizedBox(height: 24),
          _buildFormTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_android_rounded,
            hint: 'Primary contact number',
            keyboardType: TextInputType.phone,
            validator: (v) => v!.length < 11 ? 'Enter valid number' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CustomTheme.backgroundColor,
            borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          ),
          child: Icon(icon, size: 20, color: CustomTheme.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: CustomTextStyle.caption.copyWith(
                  color: CustomTheme.textTertiary,
                  fontWeight: CustomTheme.fontWeightMedium,
                )
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: CustomTextStyle.bodyMedium.copyWith(
                  fontWeight: CustomTheme.fontWeightSemiBold,
                  color: valueColor ?? CustomTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CustomTextStyle.bodySmall.copyWith(fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightSemiBold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary),
            prefixIcon: Icon(icon, size: 18, color: CustomTheme.primaryColor),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              borderSide: const BorderSide(color: CustomTheme.primaryColor, width: 1.5),
            ),
            errorStyle: CustomTextStyle.caption.copyWith(color: CustomTheme.errorColor),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(bool isLoading) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(CustomTheme.radiusXL)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
            ),
            elevation: 8,
            shadowColor: CustomTheme.primaryColor.withOpacity(0.4),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('Save Changes', style: CustomTextStyle.button.copyWith(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildAddressesSection() {
    final addressProvider = ref.watch(addressProviderNotifier);
    final addresses = addressProvider.addresses;
    final isLoading = addressProvider.isLoading;

    if (isLoading && addresses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (addresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
          boxShadow: CustomTheme.boxShadowLight,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_on_outlined, size: 32, color: CustomTheme.textTertiary.withOpacity(0.5)),
            ),
            const SizedBox(height: 16),
            Text(
              'No addresses added yet',
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.textSecondary,
                fontWeight: CustomTheme.fontWeightMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: addresses.map((addr) => _buildAddressCard(addr, addressProvider)).toList(),
    );
  }

  Widget _buildAddressCard(AddressEntity address, AddressProvider addressProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusXL),
        boxShadow: CustomTheme.boxShadowLight,
        border: address.isDefault 
            ? Border.all(color: CustomTheme.primaryColor.withOpacity(0.1), width: 1) 
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (address.isDefault ? CustomTheme.primaryColor : CustomTheme.backgroundColor).withOpacity(0.08),
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
                  child: Text(
                    address.isDefault ? 'Default Address' : 'Shipping Address',
                    style: CustomTextStyle.bodySmall.copyWith(
                      fontWeight: CustomTheme.fontWeightBold,
                      color: address.isDefault ? CustomTheme.primaryColor : CustomTheme.textSecondary,
                    ),
                  ),
                ),
                _buildActionIconButton(Icons.edit_outlined, Colors.blue, () => _showAddressForm(context, address: address)),
                const SizedBox(width: 10),
                _buildActionIconButton(Icons.delete_outline_rounded, CustomTheme.errorColor, () => _showDeleteConfirmation(address)),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.street, 
                    style: CustomTextStyle.bodyLarge.copyWith(
                      fontWeight: CustomTheme.fontWeightSemiBold,
                      fontSize: 15,
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.state} ${address.postalCode}',
                    style: CustomTextStyle.bodySmall.copyWith(
                      color: CustomTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.05), shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: color),
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
        content: const Text('Are you sure you want to delete this address?'),
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
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                          elevation: 8,
                          shadowColor: CustomTheme.primaryColor.withOpacity(0.4),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                widget.address == null ? 'Save Address' : 'Update Changes', 
                                style: CustomTextStyle.button.copyWith(fontSize: 16),
                              ),
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
        Text(
          label, 
          style: CustomTextStyle.bodySmall.copyWith(
            fontWeight: CustomTheme.fontWeightSemiBold, 
            color: CustomTheme.textSecondary
          )
        ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD), 
              borderSide: BorderSide.none
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD), 
              borderSide: const BorderSide(color: CustomTheme.primaryColor, width: 1.5)
            ),
            errorStyle: CustomTextStyle.caption.copyWith(color: CustomTheme.errorColor),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final provider = ref.read(addressProviderNotifier);
    final success = widget.address == null
        ? await provider.addAddress(AddressEntity(
            id: '', 
            userId: '', 
            street: _streetController.text.trim(), 
            city: _cityController.text.trim(), 
            state: _stateController.text.trim(), 
            postalCode: _zipController.text.trim(), 
            country: _countryController.text.trim(), 
            isDefault: _isDefault,
          ))
        : await provider.updateAddress(widget.address!.id, {
            'street': _streetController.text.trim(), 
            'city': _cityController.text.trim(), 
            'state': _stateController.text.trim(), 
            'postalCode': _zipController.text.trim(), 
            'country': _countryController.text.trim(), 
            'isDefault': _isDefault
          });
          
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}
