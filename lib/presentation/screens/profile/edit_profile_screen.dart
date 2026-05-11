import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/user_entity.dart';
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: CustomTextStyle.heading1.copyWith(color: CustomTheme.primaryColor, fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: CustomTextStyle.heading3),
          const SizedBox(height: 4),
          Text(
            user.role.toUpperCase(),
            style: CustomTextStyle.caption.copyWith(
              color: CustomTheme.primaryColor,
              fontWeight: CustomTheme.fontWeightBold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(UserEntity user) {
    final formattedDate = DateFormat('MMMM dd, yyyy').format(user.createdAt);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        border: Border.all(color: CustomTheme.borderLight, width: 1),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email Address', user.email),
          const Divider(height: 32, color: CustomTheme.borderLight),
          _buildInfoRow(Icons.local_pharmacy_outlined, 'Pharmacy Name', user.pharmacyName ?? 'N/A'),
          const Divider(height: 32, color: CustomTheme.borderLight),
          _buildInfoRow(Icons.phone_outlined, 'Phone Number', user.phoneNumber),
          const Divider(height: 32, color: CustomTheme.borderLight),
          _buildInfoRow(
            Icons.verified_user_outlined,
            'Account Status',
            user.isApproved ? 'Verified & Approved' : 'Pending Approval',
            valueColor: user.isApproved ? Colors.green.shade600 : Colors.orange.shade700,
          ),
          const Divider(height: 32, color: CustomTheme.borderLight),
          _buildInfoRow(Icons.calendar_today_outlined, 'Customer Since', formattedDate),
        ],
      ),
    );
  }

  Widget _buildEditCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
        border: Border.all(color: CustomTheme.borderLight, width: 1),
      ),
      child: Column(
        children: [
          _buildFormTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            hint: 'Enter your full name',
            validator: (v) => v!.isEmpty ? 'Name cannot be empty' : null,
          ),
          const SizedBox(height: 20),
          _buildFormTextField(
            controller: _pharmacyNameController,
            label: 'Pharmacy Name',
            icon: Icons.local_pharmacy_outlined,
            hint: 'Enter your pharmacy name',
            validator: (v) => v!.isEmpty ? 'Pharmacy name is required' : null,
          ),
          const SizedBox(height: 20),
          _buildFormTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            hint: '01XXXXXXXXX',
            keyboardType: TextInputType.phone,
            validator: (v) => v!.length < 11 ? 'Enter a valid phone number' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: CustomTheme.backgroundColor, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: CustomTheme.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: CustomTextStyle.caption.copyWith(color: CustomTheme.textTertiary)),
              const SizedBox(height: 2),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
            ),
            elevation: 0,
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
              : Text('Update Profile', style: CustomTextStyle.button),
        ),
      ),
    );
  }
}
