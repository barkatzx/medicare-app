import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/theme/custom_theme.dart';
import '../entity/location_entity.dart';
import '../entity/user_entity.dart';

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
      ref.read(authProviderNotifier).getProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProviderNotifier);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(authProviderNotifier).getProfile(),
              color: CustomTheme.primaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [_buildAddressCard(user)],
              ),
            ),
      bottomNavigationBar: user == null ? null : _buildBottomAction(user),
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
        'My Address',
        style: CustomTextStyle.heading2.copyWith(fontSize: 19),
      ),
    );
  }

  Widget _buildBottomAction(UserEntity user) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () => _showAddressForm(user),
          icon: Icon(
            user.hasAddress ? Icons.edit_outlined : Icons.add_rounded,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            user.hasAddress ? 'Edit Address' : 'Add Address',
            style: CustomTextStyle.button.copyWith(
              fontSize: 15,
              fontWeight: CustomTheme.fontWeightBold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressCard(UserEntity user) {
    if (!user.hasAddress) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
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
              'No Address Added',
              style: CustomTextStyle.heading3.copyWith(
                fontSize: 17,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your address for\na faster checkout experience.',
              textAlign: TextAlign.center,
              style: CustomTextStyle.bodyMedium.copyWith(
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _infoRow(Icons.home_outlined, 'Full Address', user.fullAddress!),
          _divider(),
          _infoRow(Icons.map_outlined, 'Division', user.division!.label),
          _divider(),
          _infoRow(
            Icons.location_city_outlined,
            'District',
            user.district!.label,
          ),
          _divider(),
          _infoRow(Icons.pin_drop_outlined, 'Upazila', user.upazila!.label),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: CustomTheme.borderLight),
  );

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: CustomTheme.primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: CustomTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
              const SizedBox(height: 3),
              Text(
                value,
                style: CustomTextStyle.bodyMedium.copyWith(
                  color: CustomTheme.textPrimary,
                  fontWeight: CustomTheme.fontWeightMedium,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddressForm(UserEntity user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddressFormSheet(user: user),
    );
  }
}

// ─── Address Form Bottom Sheet ────────────────────────────────────────────────

class AddressFormSheet extends ConsumerStatefulWidget {
  final UserEntity user;
  const AddressFormSheet({super.key, required this.user});

  @override
  ConsumerState<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;

  List<LocationEntity> _divisions = [];
  List<LocationEntity> _districts = [];
  List<LocationEntity> _upazilas = [];
  String? _divisionId;
  String? _districtId;
  String? _upazilaId;
  bool _loadingLocations = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _addressController = TextEditingController(text: user.fullAddress ?? '');
    _divisionId = user.division?.id;
    _districtId = user.district?.id;
    _upazilaId = user.upazila?.id;
    _loadInitialLocations();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLocations() async {
    final repo = ref.read(locationRepositoryProvider);
    setState(() {
      _loadingLocations = true;
      _locationError = null;
    });
    try {
      final divisions = await repo.getDivisions();
      final districts = _divisionId != null
          ? await repo.getDistricts(_divisionId!)
          : <LocationEntity>[];
      final upazilas = _districtId != null
          ? await repo.getUpazilas(_districtId!)
          : <LocationEntity>[];
      if (!mounted) return;
      setState(() {
        _divisions = divisions;
        _districts = districts;
        _upazilas = upazilas;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationError = 'Could not load locations');
    } finally {
      if (mounted) setState(() => _loadingLocations = false);
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
    });
    if (id == null) return;
    try {
      final data = await ref.read(locationRepositoryProvider).getDistricts(id);
      if (!mounted || _divisionId != id) return;
      setState(() => _districts = data);
    } catch (_) {
      if (mounted) setState(() => _locationError = 'Could not load districts');
    }
  }

  Future<void> _onDistrictChanged(String? id) async {
    setState(() {
      _districtId = id;
      _upazilaId = null;
      _upazilas = [];
      _locationError = null;
    });
    if (id == null) return;
    try {
      final data = await ref.read(locationRepositoryProvider).getUpazilas(id);
      if (!mounted || _districtId != id) return;
      setState(() => _upazilas = data);
    } catch (_) {
      if (mounted) setState(() => _locationError = 'Could not load upazilas');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProviderNotifier).isLoading;
    final isEditing = widget.user.hasAddress;

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
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CustomTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
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
                        isEditing ? 'Update Address' : 'Add Address',
                        style: CustomTextStyle.heading3.copyWith(fontSize: 17),
                      ),
                      Text(
                        'Where should we deliver?',
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
                    _buildAddressField(),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'Division',
                      Icons.map_outlined,
                      _divisions,
                      _divisionId,
                      _onDivisionChanged,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'District',
                      Icons.location_city_outlined,
                      _districts,
                      _districtId,
                      _onDistrictChanged,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      'Upazila',
                      Icons.pin_drop_outlined,
                      _upazilas,
                      _upazilaId,
                      (id) => setState(() => _upazilaId = id),
                    ),
                    if (_locationError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _locationError!,
                          style: CustomTextStyle.caption.copyWith(
                            color: CustomTheme.errorColor,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
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
                                isEditing ? 'Update Address' : 'Save Address',
                                style: CustomTextStyle.button.copyWith(
                                  fontSize: 14,
                                  fontWeight: CustomTheme.fontWeightBold,
                                  letterSpacing: 0.3,
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

  InputDecoration _decoration(String? hint, IconData icon) {
    OutlineInputBorder border([Color? color]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: 1.5),
    );
    return InputDecoration(
      hintText: hint,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, size: 17, color: CustomTheme.textTertiary),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      filled: true,
      fillColor: CustomTheme.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: border(),
      focusedBorder: border(CustomTheme.primaryColor.withValues(alpha: 0.5)),
      errorBorder: border(CustomTheme.errorColor),
      focusedErrorBorder: border(CustomTheme.errorColor),
      errorStyle: CustomTextStyle.caption.copyWith(
        color: CustomTheme.errorColor,
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: CustomTextStyle.caption.copyWith(
          fontSize: 11,
          letterSpacing: 0.3,
          color: CustomTheme.textTertiary,
          fontWeight: CustomTheme.fontWeightSemiBold,
        ),
      ),
    ),
  );

  TextStyle get _valueStyle => CustomTextStyle.bodyMedium.copyWith(
    fontWeight: CustomTheme.fontWeightMedium,
    color: CustomTheme.textPrimary,
    fontSize: 14,
  );

  Widget _buildAddressField() {
    return Column(
      children: [
        _label('Full Address'),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          style: _valueStyle,
          decoration: _decoration('House, road, area', Icons.home_outlined),
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Full address is required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    List<LocationEntity> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    final selected = items.any((e) => e.id == value) ? value : null;
    return Column(
      children: [
        _label(label),
        DropdownButtonFormField<String>(
          key: ValueKey('$label-${items.length}-$selected'),
          initialValue: selected,
          isExpanded: true,
          icon: _loadingLocations
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.keyboard_arrow_down_rounded),
          style: _valueStyle,
          decoration: _decoration('Select ${label.toLowerCase()}', icon),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e.id,
                  child: Text(e.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
          validator: (v) => v == null ? '$label is required' : null,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final auth = ref.read(authProviderNotifier);
    final user = widget.user;
    final success = await auth.updateProfile(
      name: user.name,
      pharmacyName: user.pharmacyName ?? '',
      phoneNumber: user.phoneNumber,
      fullAddress: _addressController.text.trim(),
      divisionId: _divisionId,
      districtId: _districtId,
      upazilaId: _upazilaId,
    );

    if (!mounted) return;
    if (success) {
      await auth.getProfile();
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to update address'),
          backgroundColor: CustomTheme.errorColor,
        ),
      );
    }
  }
}
