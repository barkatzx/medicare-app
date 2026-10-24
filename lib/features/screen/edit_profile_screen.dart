import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/features/entity/user_entity.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';

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
    _pharmacyNameController = TextEditingController(
      text: user?.pharmacyName ?? '',
    );
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProviderNotifier).getProfile();
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

    final success = await ref
        .read(authProviderNotifier)
        .updateProfile(
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
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  'Profile updated successfully',
                  style: CustomTextStyle.bodyMedium.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            backgroundColor: CustomTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
              borderRadius: BorderRadius.circular(12),
            ),
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
                        _buildSectionHeader(
                          'Account Information',
                          Icons.shield_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildAccountInfoCard(user),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          'Personal Details',
                          Icons.edit_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildEditCard(),
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
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: CustomTheme.textPrimary,
                size: 15,
              ),
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
            color: CustomTheme.primaryColor.withValues(alpha: 0.08),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withValues(alpha: 0.08),
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
    final formattedDate = DateFormat('MMMM dd, yyyy').format(user.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
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
                child: Icon(icon, size: 17, color: CustomTheme.textSecondary),
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
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildEditCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
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
            validator: (v) => v!.isEmpty ? 'Business name is required' : null,
          ),
          const SizedBox(height: 14),
          _buildFormTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_android_rounded,
            hint: 'Primary contact number',
            keyboardType: TextInputType.phone,
            validator: (v) => v!.length < 11 ? 'Enter a valid number' : null,
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
            hintStyle: CustomTextStyle.bodySmall.copyWith(
              color: CustomTheme.textTertiary,
              fontSize: 13,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 18, color: CustomTheme.textTertiary),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 46,
              minHeight: 46,
            ),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(
                color: CustomTheme.primaryColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: CustomTheme.errorColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: CustomTheme.errorColor,
                width: 1.5,
              ),
            ),
            errorStyle: CustomTextStyle.caption.copyWith(
              color: CustomTheme.errorColor,
            ),
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
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CustomTheme.primaryColor.withValues(
                alpha: 0.5,
              ),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
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
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
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
                          const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
