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
          ? Center(
              child: CircularProgressIndicator(
                color: CustomTheme.primaryColor,
                strokeWidth: 2.5,
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(authProviderNotifier).getProfile(),
              color: CustomTheme.primaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionHeader(user),
                  const SizedBox(height: 12),
                  _buildAddressCard(user),
                ],
              ),
            ),
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
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: CustomTheme.textPrimary,
                size: 18,
              ),
            ),
          ),
        ),
      ),
      title: Text(
        'My Address',
        style: CustomTextStyle.heading2.copyWith(fontSize: 20),
      ),
    );
  }

  Widget _buildSectionHeader(UserEntity user) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.location_on_outlined,
            size: 20,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Delivery Address',
            style: CustomTextStyle.heading4.copyWith(
              fontSize: 16,
              fontWeight: CustomTheme.fontWeightBold,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Tooltip(
          message: user.hasAddress ? 'Edit address' : 'Add address',
          child: Material(
            color: CustomTheme.primaryColor,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => _showAddressForm(user),
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  user.hasAddress ? Icons.edit_outlined : Icons.add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(UserEntity user) {
    if (!user.hasAddress) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
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
                color: Color(0xFF3B82F6),
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
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _AddressInfoTile(
            icon: Icons.home_outlined,
            label: 'Full Address',
            value: user.fullAddress!,
            color: const Color(0xFF3B82F6),
          ),
          _AddressInfoTile(
            icon: Icons.map_outlined,
            label: 'Division',
            value: user.division!.label,
            color: const Color(0xFF10B981),
          ),
          _AddressInfoTile(
            icon: Icons.location_city_outlined,
            label: 'District',
            value: user.district!.label,
            color: const Color(0xFF8B5CF6),
          ),
          _AddressInfoTile(
            icon: Icons.pin_drop_outlined,
            label: 'Upazila',
            value: user.upazila!.label,
            color: const Color(0xFFF59E0B),
            isLast: true,
          ),
        ],
      ),
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

class _AddressInfoTile extends StatelessWidget {
  const _AddressInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
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
                        color: CustomTheme.textPrimary,
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
          const Divider(
            height: 1,
            color: CustomTheme.borderLight,
            indent: 64,
            endIndent: 16,
          ),
      ],
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
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      isEditing
                          ? Icons.edit_location_alt_outlined
                          : Icons.add_location_alt_outlined,
                      color: const Color(0xFF3B82F6),
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
        child: Icon(icon, size: 17),
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
          minLines: 1,
          maxLines: 3,
          textAlignVertical: TextAlignVertical.center,
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
