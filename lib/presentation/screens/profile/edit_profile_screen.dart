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
    _pharmacyNameController =
        TextEditingController(text: user?.pharmacyName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProviderNotifier).getProfile();
      ref.read(addressProviderNotifier).loadAddresses();
    });
  }

  @override
  void didUpdateWidget(EditProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final user = ref.read(authProviderNotifier).currentUser;
    if (user != null) {
      if (_nameController.text.isEmpty && user.name.isNotEmpty) {
        _nameController.text = user.name;
      }
      if (_pharmacyNameController.text.isEmpty &&
          (user.pharmacyName ?? '').isNotEmpty) {
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
                const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text('Profile updated successfully',
                    style: CustomTextStyle.bodyMedium
                        .copyWith(color: Colors.white, fontSize: 13)),
              ],
            ),
            backgroundColor: CustomTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
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
      appBar: _buildAppBar(),
      body: user == null
          ? Center(
              child: CircularProgressIndicator(
                color: CustomTheme.primaryColor,
                strokeWidth: 2.5,
              ),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(user),
                        const SizedBox(height: 24),
                        _buildSectionHeader('Account Information',
                            Icons.shield_outlined),
                        const SizedBox(height: 12),
                        _buildAccountInfoCard(user),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                            'Personal Details', Icons.edit_outlined),
                        const SizedBox(height: 12),
                        _buildEditCard(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionHeader(
                                'Addresses', Icons.location_on_outlined),
                            GestureDetector(
                              onTap: () => _showAddressForm(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: CustomTheme.primaryColor
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_rounded,
                                        size: 14,
                                        color: CustomTheme.primaryColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Add New',
                                      style: TextStyle(
                                        fontFamily:
                                            CustomTheme.primaryFontFamily,
                                        fontSize: 12,
                                        fontWeight:
                                            CustomTheme.fontWeightSemiBold,
                                        color: CustomTheme.primaryColor,
                                      ),
                                    ),
                                  ],
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
                _buildBottomAction(isLoading),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: CustomTheme.textPrimary, size: 15),
            ),
          ),
        ),
      ),
      title: Text(
        'Edit Profile',
        style: CustomTextStyle.heading2.copyWith(fontSize: 18),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: CustomTheme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: CustomTheme.primaryColor),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: CustomTextStyle.heading4.copyWith(
            fontSize: 14,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(UserEntity user) {
    final initials = user.name.isNotEmpty
        ? user.name
            .trim()
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase()
        : 'U';

    return Center(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 32,
                  fontWeight: CustomTheme.fontWeightBold,
                  color: CustomTheme.primaryColor,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: CustomTextStyle.heading2.copyWith(
              fontSize: 20,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.toUpperCase(),
              style: TextStyle(
                fontFamily: CustomTheme.primaryFontFamily,
                fontSize: 10,
                fontWeight: CustomTheme.fontWeightBold,
                color: CustomTheme.primaryColor,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(UserEntity user) {
    final formattedDate =
        DateFormat('MMMM dd, yyyy').format(user.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            Icons.email_outlined,
            'Email Address',
            user.email,
            isLast: false,
          ),
          _buildInfoTile(
            Icons.verified_user_outlined,
            'Account Status',
            user.isApproved ? 'Verified & Approved' : 'Pending Approval',
            valueColor: user.isApproved
                ? CustomTheme.successColor
                : CustomTheme.warningColor,
            isLast: false,
          ),
          _buildInfoTile(
            Icons.calendar_today_outlined,
            'Member Since',
            formattedDate,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CustomTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Icon(icon, size: 17, color: CustomTheme.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: CustomTextStyle.caption.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.4,
                        color: CustomTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        color: valueColor ?? CustomTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              color: CustomTheme.borderLight,
              indent: 64,
              endIndent: 16),
      ],
    );
  }

  Widget _buildEditCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildFormTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            hint: 'Your full name',
            validator: (v) => v!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          _buildFormTextField(
            controller: _pharmacyNameController,
            label: 'Pharmacy Name',
            icon: Icons.local_pharmacy_outlined,
            hint: 'Your business name',
            validator: (v) =>
                v!.isEmpty ? 'Business name is required' : null,
          ),
          const SizedBox(height: 14),
          _buildFormTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_android_rounded,
            hint: 'Primary contact number',
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v!.length < 11 ? 'Enter a valid number' : null,
          ),
        ],
      ),
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
          style: CustomTextStyle.caption.copyWith(
            fontSize: 11,
            letterSpacing: 0.3,
            color: CustomTheme.textTertiary,
            fontWeight: CustomTheme.fontWeightSemiBold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: CustomTextStyle.bodyMedium.copyWith(
            fontWeight: CustomTheme.fontWeightMedium,
            color: CustomTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: CustomTextStyle.bodySmall
                .copyWith(color: CustomTheme.textTertiary, fontSize: 13),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 18, color: CustomTheme.textTertiary),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 46, minHeight: 46),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                  color: CustomTheme.primaryColor.withOpacity(0.5),
                  width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                  color: CustomTheme.errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                  color: CustomTheme.errorColor, width: 1.5),
            ),
            errorStyle: CustomTextStyle.caption
                .copyWith(color: CustomTheme.errorColor),
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
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  CustomTheme.primaryColor.withOpacity(0.5),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              overlayColor: Colors.transparent,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF2A2A2A), Color(0xFF010101)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save Changes',
                            style: CustomTextStyle.button.copyWith(
                              fontSize: 15,
                              fontWeight: CustomTheme.fontWeightBold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressesSection() {
    final addressProvider = ref.watch(addressProviderNotifier);
    final addresses = addressProvider.addresses;
    final isLoading = addressProvider.isLoading;

    if (isLoading && addresses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: CustomTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    if (addresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_off_outlined,
                  size: 26, color: CustomTheme.textTertiary),
            ),
            const SizedBox(height: 12),
            Text(
              'No addresses yet',
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.textSecondary,
                fontWeight: CustomTheme.fontWeightMedium,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "+ Add New" to add a shipping address',
              style: CustomTextStyle.caption
                  .copyWith(fontSize: 11, color: CustomTheme.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: addresses
          .map((addr) => _buildAddressCard(addr, addressProvider))
          .toList(),
    );
  }

  Widget _buildAddressCard(
      AddressEntity address, AddressProvider addressProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(
                color: CustomTheme.primaryColor.withOpacity(0.2), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: address.isDefault
                ? CustomTheme.primaryColor.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: address.isDefault
                    ? CustomTheme.primaryColor.withOpacity(0.08)
                    : CustomTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                address.isDefault
                    ? Icons.home_rounded
                    : Icons.location_on_outlined,
                size: 20,
                color: address.isDefault
                    ? CustomTheme.primaryColor
                    : CustomTheme.textTertiary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.isDefault
                            ? 'Default Address'
                            : 'Shipping Address',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 11,
                          fontWeight: CustomTheme.fontWeightSemiBold,
                          color: address.isDefault
                              ? CustomTheme.primaryColor
                              : CustomTheme.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: CustomTheme.successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.street,
                    style: CustomTextStyle.bodyMedium.copyWith(
                      color: CustomTheme.textPrimary,
                      fontWeight: CustomTheme.fontWeightMedium,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${address.city}, ${address.state} ${address.postalCode}',
                    style: CustomTextStyle.caption
                        .copyWith(fontSize: 11, color: CustomTheme.textTertiary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                _buildIconBtn(
                  Icons.edit_outlined,
                  CustomTheme.textSecondary,
                  CustomTheme.backgroundColor,
                  () => _showAddressForm(context, address: address),
                ),
                const SizedBox(width: 6),
                _buildIconBtn(
                  Icons.delete_outline_rounded,
                  CustomTheme.errorColor,
                  CustomTheme.errorColor.withOpacity(0.08),
                  () => _showDeleteConfirmation(address),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(
      IconData icon, Color color, Color bg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(9),
        ),
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
      builder: (dialogContext) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: CustomTheme.surfaceColor,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: CustomTheme.errorColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_off_outlined,
                    color: CustomTheme.errorColor, size: 24),
              ),
              const SizedBox(height: 16),
              Text('Delete Address',
                  style: CustomTextStyle.heading3.copyWith(fontSize: 17)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete this address?',
                textAlign: TextAlign.center,
                style:
                    CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: CustomTheme.textSecondary,
                              fontWeight: CustomTheme.fontWeightMedium,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final provider = ref.read(addressProviderNotifier);
                        await provider.deleteAddress(address.id);
                        if (dialogContext.mounted)
                          Navigator.pop(dialogContext);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.errorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Delete',
                            style: CustomTextStyle.button
                                .copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Address Form Bottom Sheet ────────────────────────────────────────────────

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
    _streetController =
        TextEditingController(text: widget.address?.street ?? '');
    _cityController =
        TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(
        text: widget.address?.state ?? 'Dhaka Division');
    _zipController =
        TextEditingController(text: widget.address?.postalCode ?? '');
    _countryController =
        TextEditingController(text: widget.address?.country ?? 'Bangladesh');
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
    final isEditing = widget.address != null;

    return Container(
      decoration: const BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CustomTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CustomTheme.primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      isEditing
                          ? Icons.edit_location_alt_outlined
                          : Icons.add_location_alt_outlined,
                      color: CustomTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Update Address' : 'Add New Address',
                        style: CustomTextStyle.heading3.copyWith(fontSize: 17),
                      ),
                      Text(
                        isEditing
                            ? 'Edit your delivery address'
                            : 'Where should we deliver?',
                        style: CustomTextStyle.caption
                            .copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField('Street Address', _streetController,
                        Icons.location_on_outlined,
                        maxLines: 2),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                              'City', _cityController, Icons.location_city_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField('Postal Code', _zipController,
                              Icons.markunread_mailbox_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField('State / Division', _stateController,
                        Icons.map_outlined),
                    const SizedBox(height: 12),
                    _buildField(
                        'Country', _countryController, Icons.public_outlined),
                    const SizedBox(height: 16),

                    // Default toggle
                    GestureDetector(
                      onTap: () =>
                          setState(() => _isDefault = !_isDefault),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _isDefault
                              ? CustomTheme.primaryColor.withOpacity(0.06)
                              : CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: _isDefault
                                ? CustomTheme.primaryColor.withOpacity(0.2)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 18,
                              color: _isDefault
                                  ? CustomTheme.primaryColor
                                  : CustomTheme.textTertiary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set as default address',
                                    style: TextStyle(
                                      fontFamily: CustomTheme.primaryFontFamily,
                                      fontSize: 13,
                                      fontWeight: CustomTheme.fontWeightSemiBold,
                                      color: _isDefault
                                          ? CustomTheme.primaryColor
                                          : CustomTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Used automatically at checkout',
                                    style: CustomTextStyle.caption
                                        .copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _isDefault
                                    ? CustomTheme.primaryColor
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isDefault
                                      ? CustomTheme.primaryColor
                                      : CustomTheme.borderMedium,
                                  width: 2,
                                ),
                              ),
                              child: _isDefault
                                  ? const Icon(Icons.check_rounded,
                                      size: 13, color: Colors.white)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CustomTheme.primaryColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              CustomTheme.primaryColor.withOpacity(0.5),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          surfaceTintColor: Colors.transparent,
                          overlayColor: Colors.transparent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: isLoading
                                ? null
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFF2A2A2A),
                                      Color(0xFF010101)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    isEditing
                                        ? 'Update Address'
                                        : 'Save Address',
                                    style: CustomTextStyle.button.copyWith(
                                      fontSize: 14,
                                      fontWeight: CustomTheme.fontWeightBold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CustomTextStyle.caption.copyWith(
            fontSize: 11,
            letterSpacing: 0.3,
            color: CustomTheme.textTertiary,
            fontWeight: CustomTheme.fontWeightSemiBold,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (val) =>
              val == null || val.isEmpty ? 'Required' : null,
          style: CustomTextStyle.bodyMedium.copyWith(
            fontWeight: CustomTheme.fontWeightMedium,
            color: CustomTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 17, color: CustomTheme.textTertiary),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 44, minHeight: 44),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                  color: CustomTheme.primaryColor.withOpacity(0.5),
                  width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                  color: CustomTheme.errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                  color: CustomTheme.errorColor, width: 1.5),
            ),
            errorStyle: CustomTextStyle.caption
                .copyWith(color: CustomTheme.errorColor),
          ),
        ),
      ],
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
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
            'isDefault': _isDefault,
          });

    if (success && mounted) Navigator.of(context).pop();
  }
}