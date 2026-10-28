import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:medicare_app/features/entity/user_entity.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProviderNotifier);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
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
      ),
      body: user == null
          ? Center(
              child: CircularProgressIndicator(
                color: CustomTheme.primaryColor,
                strokeWidth: 2.5,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          size: 20,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Account Information',
                          style: CustomTextStyle.heading4.copyWith(
                            fontSize: 16,
                            fontWeight: CustomTheme.fontWeightBold,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'Edit name and pharmacy',
                        child: Material(
                          color: CustomTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => _showEditSheet(context, ref, user),
                            borderRadius: BorderRadius.circular(10),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.edit_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: CustomTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _InfoTile(
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: user.name,
                          color: const Color(0xFF3B82F6),
                        ),
                        _InfoTile(
                          icon: Icons.local_pharmacy_outlined,
                          label: 'Pharmacy Name',
                          value: user.pharmacyName?.isNotEmpty == true
                              ? user.pharmacyName!
                              : '—',
                          color: const Color(0xFF10B981),
                        ),
                        _InfoTile(
                          icon: Icons.phone_android_rounded,
                          label: 'Phone Number',
                          value: user.phoneNumber,
                          color: const Color(0xFF8B5CF6),
                        ),
                        _InfoTile(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email,
                          color: const Color(0xFFF59E0B),
                        ),
                        _InfoTile(
                          icon: Icons.verified_user_outlined,
                          label: 'Account Status',
                          value: user.isApproved
                              ? 'Verified & Approved'
                              : 'Pending Approval',
                          valueColor: user.isApproved
                              ? CustomTheme.successColor
                              : CustomTheme.warningColor,
                          color: const Color(0xFF10B981),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileEditSheet(user: user),
    );
    if (updated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: CustomTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.valueColor,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? valueColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: CustomTextStyle.caption.copyWith(
                        fontSize: 13,
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        color: CustomTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightBold,
                        color: valueColor ?? CustomTheme.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: CustomTheme.borderLight, indent: 64, endIndent: 16),
      ],
    );
  }
}

class _ProfileEditSheet extends ConsumerStatefulWidget {
  const _ProfileEditSheet({required this.user});

  final UserEntity user;

  @override
  ConsumerState<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<_ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pharmacyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _pharmacyController = TextEditingController(
      text: widget.user.pharmacyName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pharmacyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProviderNotifier).isLoading;

    return Container(
      decoration: const BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CustomTheme.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Account Information',
                          style: CustomTextStyle.heading3.copyWith(fontSize: 17),
                        ),
                        Text(
                          'Edit your name and pharmacy name',
                          style: CustomTextStyle.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _pharmacyController,
                  label: 'Pharmacy Name',
                  icon: Icons.local_pharmacy_outlined,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Pharmacy name is required'
                      : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Update Information',
                            style: CustomTextStyle.button.copyWith(
                              fontSize: 14,
                              fontWeight: CustomTheme.fontWeightBold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textCapitalization: TextCapitalization.words,
      style: CustomTextStyle.bodyMedium.copyWith(
        fontWeight: CustomTheme.fontWeightBold,
        color: CustomTheme.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18),
        filled: true,
        fillColor: CustomTheme.backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: CustomTheme.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: CustomTheme.errorColor, width: 1.5),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(authProviderNotifier).updateProfile(
      name: _nameController.text.trim(),
      pharmacyName: _pharmacyController.text.trim(),
      phoneNumber: widget.user.phoneNumber,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final error = ref.read(authProviderNotifier).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to update profile'),
          backgroundColor: CustomTheme.errorColor,
        ),
      );
    }
  }
}
