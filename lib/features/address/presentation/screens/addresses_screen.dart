import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/address_provider.dart';
import '../../../../core/theme/custom_theme.dart';

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
      appBar: _buildAppBar(),
      body: _buildBody(isLoading, addresses, addressProvider),
      bottomNavigationBar: _buildBottomAction(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        'My Addresses',
        style: CustomTextStyle.heading2.copyWith(fontSize: 19),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
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
          onPressed: () => _showAddressForm(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            overlayColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add New Address',
                style: CustomTextStyle.button.copyWith(
                  fontSize: 15,
                  fontWeight: CustomTheme.fontWeightBold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    bool isLoading,
    List<AddressEntity> addresses,
    AddressProvider addressProvider,
  ) {
    if (isLoading && addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Loading addresses…',
              style: CustomTextStyle.bodySmall.copyWith(
                fontSize: 13,
                color: CustomTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    if (addresses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: CustomTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  size: 40,
                  color: CustomTheme.textTertiary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Addresses Saved',
                style: CustomTextStyle.heading3.copyWith(
                  fontSize: 17,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a shipping address for\na faster checkout experience.',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(addressProviderNotifier).loadAddresses(),
      color: CustomTheme.primaryColor,
      backgroundColor: CustomTheme.surfaceColor,
      strokeWidth: 2,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          return _buildAddressCard(addresses[index], addressProvider);
        },
      ),
    );
  }

  Widget _buildAddressCard(
    AddressEntity address,
    AddressProvider addressProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(
                color: CustomTheme.primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              )
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: address.isDefault
                        ? CustomTheme.primaryColor.withValues(alpha: 0.08)
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
                      const SizedBox(height: 3),
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
                        style: CustomTextStyle.caption.copyWith(
                          fontSize: 11,
                          color: CustomTheme.textTertiary,
                        ),
                      ),
                      Text(
                        address.country,
                        style: CustomTextStyle.caption.copyWith(
                          fontSize: 11,
                          color: CustomTheme.textTertiary,
                        ),
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
                      CustomTheme.errorColor.withValues(alpha: 0.08),
                      () => _showDeleteConfirmation(address),
                    ),
                  ],
                ),
              ],
            ),

            // Set as default
            if (!address.isDefault) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: CustomTheme.borderLight),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => addressProvider.setDefaultAddress(address.id),
                child: Row(
                  children: [
                    const SizedBox(width: 54),
                    Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: CustomTheme.primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Set as default address',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 12,
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        color: CustomTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(
    IconData icon,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  color: CustomTheme.errorColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  color: CustomTheme.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Address',
                style: CustomTextStyle.heading3.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(
                'This address will be permanently removed. This action cannot be undone.',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium.copyWith(fontSize: 13),
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
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
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
                            style: CustomTextStyle.button.copyWith(
                              fontSize: 14,
                            ),
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
    _streetController = TextEditingController(
      text: widget.address?.street ?? '',
    );
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(
      text: widget.address?.state ?? 'Dhaka Division',
    );
    _zipController = TextEditingController(
      text: widget.address?.postalCode ?? '',
    );
    _countryController = TextEditingController(
      text: widget.address?.country ?? 'Bangladesh',
    );
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
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
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
                      color: CustomTheme.primaryColor.withValues(alpha: 0.08),
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
                        style: CustomTextStyle.caption.copyWith(fontSize: 11),
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
                    _buildField(
                      'Street Address',
                      _streetController,
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            'City',
                            _cityController,
                            Icons.location_city_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            'Postal Code',
                            _zipController,
                            Icons.markunread_mailbox_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      'State / Division',
                      _stateController,
                      Icons.map_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      'Country',
                      _countryController,
                      Icons.public_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Default toggle
                    GestureDetector(
                      onTap: () => setState(() => _isDefault = !_isDefault),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _isDefault
                              ? CustomTheme.primaryColor.withValues(alpha: 0.06)
                              : CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: _isDefault
                                ? CustomTheme.primaryColor.withValues(
                                    alpha: 0.2,
                                  )
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
                                      fontWeight:
                                          CustomTheme.fontWeightSemiBold,
                                      color: _isDefault
                                          ? CustomTheme.primaryColor
                                          : CustomTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Used automatically at checkout',
                                    style: CustomTextStyle.caption.copyWith(
                                      fontSize: 10,
                                    ),
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
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    )
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
                          disabledBackgroundColor: CustomTheme.primaryColor
                              .withValues(alpha: 0.5),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
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
                                      Color(0xFF010101),
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
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
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
    IconData icon,
  ) {
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
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
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
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            filled: true,
            fillColor: CustomTheme.backgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final provider = ref.read(addressProviderNotifier);
    final success = widget.address == null
        ? await provider.addAddress(
            AddressEntity(
              id: '',
              userId: '',
              street: _streetController.text.trim(),
              city: _cityController.text.trim(),
              state: _stateController.text.trim(),
              postalCode: _zipController.text.trim(),
              country: _countryController.text.trim(),
              isDefault: _isDefault,
            ),
          )
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
