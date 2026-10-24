import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../entity/location_entity.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _addressController = TextEditingController();

  List<LocationEntity> _divisions = [];
  List<LocationEntity> _districts = [];
  List<LocationEntity> _upazilas = [];
  String? _divisionId;
  String? _districtId;
  String? _upazilaId;
  bool _loadingDivisions = false;
  bool _loadingDistricts = false;
  bool _loadingUpazilas = false;
  String? _locationError;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loadDivisions();
  }

  Future<void> _loadDivisions() async {
    setState(() {
      _loadingDivisions = true;
      _locationError = null;
    });
    try {
      final data = await ref.read(locationRepositoryProvider).getDivisions();
      if (!mounted) return;
      setState(() => _divisions = data);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _locationError = 'Could not load locations. Tap to retry.',
      );
    } finally {
      if (mounted) setState(() => _loadingDivisions = false);
    }
  }

  Future<void> _onDivisionChanged(String? id) async {
    setState(() {
      _divisionId = id;
      _districtId = null;
      _upazilaId = null;
      _districts = [];
      _upazilas = [];
      _locationError = null;
      _loadingDistricts = id != null;
    });
    if (id == null) return;
    try {
      final data = await ref.read(locationRepositoryProvider).getDistricts(id);
      if (!mounted || _divisionId != id) return;
      setState(() => _districts = data);
    } catch (_) {
      if (!mounted || _divisionId != id) return;
      setState(() => _locationError = 'Could not load districts.');
    } finally {
      if (mounted && _divisionId == id) {
        setState(() => _loadingDistricts = false);
      }
    }
  }

  Future<void> _onDistrictChanged(String? id) async {
    setState(() {
      _districtId = id;
      _upazilaId = null;
      _upazilas = [];
      _locationError = null;
      _loadingUpazilas = id != null;
    });
    if (id == null) return;
    try {
      final data = await ref.read(locationRepositoryProvider).getUpazilas(id);
      if (!mounted || _districtId != id) return;
      setState(() => _upazilas = data);
    } catch (_) {
      if (!mounted || _districtId != id) return;
      setState(() => _locationError = 'Could not load upazilas.');
    } finally {
      if (mounted && _districtId == id) {
        setState(() => _loadingUpazilas = false);
      }
    }
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required List<LocationEntity> items,
    required String? value,
    required bool isLoading,
    required ValueChanged<String?> onChanged,
    required String requiredMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: CustomTheme.fontSizeSM,
            fontWeight: CustomTheme.fontWeightMedium,
            color: CustomTheme.textSecondary,
          ),
        ),
        SizedBox(height: CustomTheme.spacingSM),
        DropdownButtonFormField<String>(
          key: ValueKey('$label-${items.length}-$value'),
          initialValue: value,
          isExpanded: true,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.keyboard_arrow_down_rounded),
          style: TextStyle(fontSize: 15, color: CustomTheme.textSecondary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 15, color: CustomTheme.textTertiary),
            prefixIcon: Icon(icon, size: 20, color: CustomTheme.textTertiary),
            filled: true,
            fillColor: CustomTheme.surfaceColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: CustomTheme.spacingMD,
              vertical: CustomTheme.spacingLG,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              borderSide: BorderSide(color: CustomTheme.secondaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              borderSide: BorderSide(color: CustomTheme.secondaryColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              borderSide: BorderSide(color: CustomTheme.secondaryColor),
            ),
          ),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(e.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
          validator: (v) => v == null ? requiredMessage : null,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.primaryColor.withValues(alpha: 0.03),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: CustomTheme.spacingXXL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    SizedBox(height: CustomTheme.spacingXL),
                    Text(
                      'Join MediCarePLC',
                      style: CustomTextStyle.heading1.copyWith(
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: CustomTheme.spacingXS),
                    Text(
                      'Create an account to start ordering',
                      style: CustomTextStyle.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: CustomTheme.spacingXL * 1.5),

                    // Registration Form Card
                    Container(
                      padding: EdgeInsets.all(CustomTheme.spacingXXL),
                      decoration: BoxDecoration(
                        color: CustomTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(
                          CustomTheme.radiusXL,
                        ),
                        boxShadow: CustomTheme.boxShadowLight,
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hintText: 'John Doe',
                            prefixIcon: Icons.person_outline_rounded,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Full name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'example@mail.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!_isValidEmail(value)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _pharmacyNameController,
                            label: 'Pharmacy Name',
                            hintText: 'Your pharmacy name',
                            prefixIcon: Icons.local_pharmacy_outlined,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Pharmacy name is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hintText: '01XXXXXXXXX',
                            prefixIcon: Icons.phone_android_rounded,
                            keyboardType: TextInputType.phone,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (value.length < 11) {
                                return 'Enter a valid 11-digit number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: CustomTheme.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            obscureText: !_isPasswordVisible,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Min. 6 characters required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_reset_rounded,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: CustomTheme.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            obscureText: !_isConfirmPasswordVisible,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          CustomTextField(
                            controller: _addressController,
                            label: 'Full Address',
                            hintText: 'House, road, area',
                            prefixIcon: Icons.home_outlined,
                            keyboardType: TextInputType.multiline,
                            maxLines: 3,
                            fontSize: 15,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Full address is required';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          _buildDropdown(
                            label: 'Division',
                            hint: 'Select division',
                            icon: Icons.map_outlined,
                            items: _divisions,
                            value: _divisionId,
                            isLoading: _loadingDivisions,
                            onChanged: _onDivisionChanged,
                            requiredMessage: 'Division is required',
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          _buildDropdown(
                            label: 'District',
                            hint: 'Select district',
                            icon: Icons.location_city_outlined,
                            items: _districts,
                            value: _districtId,
                            isLoading: _loadingDistricts,
                            onChanged: _onDistrictChanged,
                            requiredMessage: 'District is required',
                          ),
                          SizedBox(height: CustomTheme.spacingLG),
                          _buildDropdown(
                            label: 'Upazila',
                            hint: 'Select upazila',
                            icon: Icons.pin_drop_outlined,
                            items: _upazilas,
                            value: _upazilaId,
                            isLoading: _loadingUpazilas,
                            onChanged: (id) => setState(() => _upazilaId = id),
                            requiredMessage: 'Upazila is required',
                          ),
                          if (_locationError != null)
                            GestureDetector(
                              onTap: _divisions.isEmpty ? _loadDivisions : null,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: CustomTheme.spacingSM,
                                ),
                                child: Text(
                                  _locationError!,
                                  style: CustomTextStyle.bodySmall.copyWith(
                                    color: CustomTheme.errorColor,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: CustomTheme.spacingXXL),

                          // Error Message
                          Consumer(
                            builder: (context, ref, child) {
                              final authProvider = ref.watch(
                                authProviderNotifier,
                              );
                              if (authProvider.errorMessage != null) {
                                return Container(
                                  padding: EdgeInsets.all(
                                    CustomTheme.spacingMD,
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom: CustomTheme.spacingLG,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.errorColor.withValues(
                                      alpha: 0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      CustomTheme.radiusMD,
                                    ),
                                    border: Border.all(
                                      color: CustomTheme.errorColor.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: CustomTheme.errorColor,
                                        size: 18,
                                      ),
                                      SizedBox(width: CustomTheme.spacingSM),
                                      Expanded(
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: CustomTextStyle.bodySmall
                                              .copyWith(
                                                color: CustomTheme.errorColor,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // Register Button
                          Consumer(
                            builder: (context, ref, child) {
                              final authProvider = ref.watch(
                                authProviderNotifier,
                              );
                              return CustomButton(
                                text: 'Create Account',
                                isLoading: authProvider.isLoading,
                                onPressed: _handleRegister,
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: CustomTheme.spacingXXL),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: CustomTextStyle.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                          child: Text(
                            'Sign In',
                            style: CustomTextStyle.bodyMedium.copyWith(
                              color: CustomTheme.primaryColor,
                              fontWeight: CustomTheme.fontWeightBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: CustomTheme.spacingXXL),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = ref.read(authProviderNotifier);

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        pharmacyName: _pharmacyNameController.text.trim(),
        fullAddress: _addressController.text.trim(),
        divisionId: _divisionId ?? '',
        districtId: _districtId ?? '',
        upazilaId: _upazilaId ?? '',
      );

      if (success && mounted) {
        if (authProvider.isPendingApproval) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.pendingApproval,
            (route) => false,
          );
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else if (authProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
            ),
          ),
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
