import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:medicare_app/core/constants/api_constants.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/domain/entities/cart_entity.dart';
import 'package:medicare_app/domain/entities/address_entity.dart';
import 'package:medicare_app/presentation/providers/cart_provider.dart';
import 'package:medicare_app/presentation/screens/orders/order_confirm_screen.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedPayment = 'cash_on_delivery';
  bool _isPlacingOrder = false;
  int _currentStep = 0;

  AnimationController? _stepAnimController;
  Animation<double>? _stepFadeAnim;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnim;

  @override
  void initState() {
    super.initState();

    final stepCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _stepAnimController = stepCtrl;
    _stepFadeAnim = CurvedAnimation(
      parent: stepCtrl,
      curve: Curves.easeOut,
    );
    stepCtrl.forward();

    final pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseController = pulseCtrl;
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();
      ref.read(addressProviderNotifier).loadAddresses();
    });
  }

  void _prefillUserData() {
    final user = ref.read(authProviderNotifier).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stepAnimController?.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    final ctrl = _stepAnimController;
    if (ctrl == null) {
      setState(() => _currentStep = step);
      return;
    }
    ctrl.reverse().then((_) {
      setState(() => _currentStep = step);
      ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = ref.watch(cartProviderNotifier);
    final cartItems = cartProvider.cartItems;

    if (cartItems.isEmpty && !_isPlacingOrder) {
      return Scaffold(
        backgroundColor: CustomTheme.backgroundColor,
        appBar: _buildAppBar(),
        body: _buildEmptyCart(),
      );
    }

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _stepFadeAnim ?? const AlwaysStoppedAnimation(1.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: _currentStep == 0
                    ? _buildShippingForm(cartProvider)
                    : _buildOrderReview(cartProvider),
              ),
            ),
          ),
          _buildBottomBar(cartProvider),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: CustomTheme.backgroundColor,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Center(
          child: GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                _goToStep(0);
              } else {
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 35,
              height: 35,
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
        'Checkout',
        style: CustomTextStyle.heading2.copyWith(
          fontSize: 19,
          letterSpacing: -0.4,
        ),
      ),
    );
  }


  // ─── Step 1: Shipping Form ───
  Widget _buildShippingForm(CartProvider cartProvider) {
    final items = cartProvider.cartItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Order Items Summary ──
        _buildSectionHeader('Your Order', '${items.length} items',
            Icons.shopping_bag_outlined),
        const SizedBox(height: 12),
        _buildItemsCard(items, cartProvider),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: CustomTheme.primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: CustomTheme.primaryColor),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: CustomTextStyle.heading4.copyWith(
                  fontSize: 15,
                  letterSpacing: -0.2,
                )),
            Text(subtitle,
                style: CustomTextStyle.caption.copyWith(
                  fontSize: 11,
                  color: CustomTheme.textTertiary,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsCard(List<CartItemEntity> items, CartProvider cartProvider) {
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
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.productImage.isNotEmpty
                              ? Image.network(
                                  item.productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                      Icons.medical_services,
                                      size: 22,
                                      color: CustomTheme.textTertiary),
                                )
                              : Icon(Icons.medical_services,
                                  size: 22, color: CustomTheme.textTertiary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: CustomTextStyle.bodyMedium.copyWith(
                                fontWeight: CustomTheme.fontWeightMedium,
                                color: CustomTheme.textPrimary,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'x${item.quantity}',
                                    style: TextStyle(
                                      fontFamily: CustomTheme.primaryFontFamily,
                                      fontSize: 11,
                                      fontWeight: CustomTheme.fontWeightSemiBold,
                                      color: CustomTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${item.finalPrice.toStringAsFixed(2)}৳ each',
                                  style: CustomTextStyle.caption
                                      .copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.itemTotal.toStringAsFixed(2)}৳',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 14,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < items.length - 1)
                  Divider(height: 1, color: CustomTheme.borderLight, indent: 14, endIndent: 14),
              ],
            );
          }),

          // Total row
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: BoxDecoration(
              color: CustomTheme.backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Total',
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 13,
                    fontWeight: CustomTheme.fontWeightSemiBold,
                    color: CustomTheme.textSecondary,
                  ),
                ),
                Text(
                  '${cartProvider.total.toStringAsFixed(2)}৳',
                  style: TextStyle(
                    fontFamily: CustomTheme.primaryFontFamily,
                    fontSize: 16,
                    fontWeight: CustomTheme.fontWeightBold,
                    color: CustomTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.person_outline, 'Full Name', user?.name ?? 'N/A', false),
          _buildInfoTile(Icons.local_pharmacy_outlined, 'Pharmacy', user?.pharmacyName ?? 'N/A', false),
          _buildInfoTile(Icons.email_outlined, 'Email', user?.email ?? 'N/A', false),
          _buildInfoTile(Icons.phone_outlined, 'Phone', user?.phoneNumber ?? 'N/A', true),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: CustomTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(9),
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
                        letterSpacing: 0.5,
                        color: CustomTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        color: CustomTheme.textPrimary,
                        fontWeight: CustomTheme.fontWeightMedium,
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
              indent: 62,
              endIndent: 16),
      ],
    );
  }

  Widget _buildAddressCard(dynamic address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_outlined,
                color: CustomTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Default Address',
                      style: TextStyle(
                        fontFamily: CustomTheme.primaryFontFamily,
                        fontSize: 10,
                        fontWeight: CustomTheme.fontWeightSemiBold,
                        color: CustomTheme.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
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
                Text(
                  '${address.city}, ${address.state}',
                  style: CustomTextStyle.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/addresses'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: CustomTheme.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Change',
                style: TextStyle(
                  fontFamily: CustomTheme.primaryFontFamily,
                  fontSize: 11,
                  fontWeight: CustomTheme.fontWeightSemiBold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isRequired = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: CustomTextStyle.bodyMedium.copyWith(
          color: CustomTheme.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: CustomTextStyle.bodySmall.copyWith(fontSize: 13),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, size: 19, color: CustomTheme.textTertiary),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 48, minHeight: 48),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: CustomTheme.primaryColor.withOpacity(0.4), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.transparent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: CustomTheme.errorColor, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: CustomTheme.errorColor, width: 1.5),
          ),
        ),
        validator: isRequired ? validator : null,
      ),
    );
  }

  Widget _buildPaymentOption(
      String value, String title, dynamic icon, String subtitle) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? CustomTheme.primaryColor
                    : CustomTheme.backgroundColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: icon is IconData
                    ? Icon(
                        icon,
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : CustomTheme.textSecondary,
                      )
                    : FaIcon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : CustomTheme.textSecondary,
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 14,
                      fontWeight: CustomTheme.fontWeightSemiBold,
                      color: isSelected
                          ? CustomTheme.textPrimary
                          : CustomTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CustomTextStyle.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? CustomTheme.primaryColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? CustomTheme.primaryColor
                      : CustomTheme.borderMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: Order Review ───
  Widget _buildOrderReview(CartProvider cartProvider) {
    final addressProvider = ref.watch(addressProviderNotifier);
    final user = ref.watch(authProviderNotifier).currentUser;

    final defaultAddress =
        addressProvider.addresses.where((a) => a.isDefault).firstOrNull ??
            (addressProvider.addresses.isNotEmpty
                ? addressProvider.addresses.first
                : null);

    if (defaultAddress != null && _addressController.text.isEmpty) {
      _addressController.text = defaultAddress.street;
      _cityController.text = defaultAddress.city;
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Delivery Information ──
          _buildSectionHeader(
              'Delivery Info', 'Auto-filled', Icons.person_outline),
          const SizedBox(height: 12),
          _buildDeliveryInfoCard(user),
          const SizedBox(height: 20),

          // ── Shipping Address ──
          _buildSectionHeader(
              'Ship To', 'Delivery address', Icons.location_on_outlined),
          const SizedBox(height: 12),

          if (defaultAddress != null)
            _buildAddressCard(defaultAddress)
          else ...[
            _buildTextField(_addressController, 'Full Address',
                Icons.home_outlined,
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Address is required' : null),
            const SizedBox(height: 10),
            _buildTextField(
                _cityController, 'City / Area', Icons.location_city_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'City is required' : null),
          ],

          const SizedBox(height: 20),

          _buildSectionHeader(
              'Payment', 'How you\'ll pay', Icons.payment_outlined),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'cash_on_delivery',
            'Cash on Delivery',
            FontAwesomeIcons.handHoldingDollar,
            'Pay when you receive your order',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReviewItem(CartItemEntity item) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CustomTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.productImage.isNotEmpty
                  ? Image.network(
                      item.productImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.medical_services,
                          size: 22,
                          color: CustomTheme.textTertiary),
                    )
                  : Icon(Icons.medical_services,
                      size: 22, color: CustomTheme.textTertiary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: CustomTextStyle.bodyMedium.copyWith(
                    fontWeight: CustomTheme.fontWeightMedium,
                    color: CustomTheme.textPrimary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.finalPrice.toStringAsFixed(2)}৳ × ${item.quantity}',
                  style: CustomTextStyle.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${item.itemTotal.toStringAsFixed(2)}৳',
            style: TextStyle(
              fontFamily: CustomTheme.primaryFontFamily,
              fontSize: 14,
              fontWeight: CustomTheme.fontWeightBold,
              color: CustomTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 46, color: CustomTheme.textTertiary),
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: CustomTextStyle.heading3.copyWith(
                color: CustomTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items to proceed\nwith checkout',
              style: CustomTextStyle.bodyMedium.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: CustomTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  'Start Shopping',
                  style: CustomTextStyle.button.copyWith(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Bar ───
  Widget _buildBottomBar(CartProvider cartProvider) {
    final total = cartProvider.total;
    final totalSavings = cartProvider.totalSavings;

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: CustomTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          if (_currentStep == 1) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal',
                          style: CustomTextStyle.bodyMedium
                              .copyWith(fontSize: 13)),
                      Text(
                        '${cartProvider.subtotal.toStringAsFixed(2)}৳',
                        style: CustomTextStyle.bodyMedium.copyWith(
                          fontWeight: CustomTheme.fontWeightMedium,
                          color: CustomTheme.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (totalSavings > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('You save',
                            style: CustomTextStyle.caption
                                .copyWith(fontSize: 12)),
                        Text(
                          '-${totalSavings.toStringAsFixed(2)}৳',
                          style: TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 12,
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Divider(height: 1, color: CustomTheme.borderLight),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 15,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)}৳',
                        style: TextStyle(
                          fontFamily: CustomTheme.primaryFontFamily,
                          fontSize: 20,
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.primaryColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 54,
            child: AnimatedBuilder(
              animation: _pulseAnim ?? const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPlacingOrder ? (_pulseAnim?.value ?? 1.0) : 1.0,
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed:
                    _isPlacingOrder ? null : () => _handleContinue(cartProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                  disabledBackgroundColor:
                      CustomTheme.primaryColor.withOpacity(0.5),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: _isPlacingOrder
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF2A2A2A), Color(0xFF010101)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                    boxShadow: _isPlacingOrder
                        ? []
                        : [
                            BoxShadow(
                              color: CustomTheme.primaryColor.withOpacity(0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _isPlacingOrder
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentStep == 0
                                    ? 'Continue to Review'
                                    : 'Place Order',
                                style: CustomTextStyle.button.copyWith(
                                  fontSize: 15,
                                  fontWeight: CustomTheme.fontWeightBold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              if (_currentStep == 1) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    '${total.toStringAsFixed(2)}৳',
                                    style: CustomTextStyle.button.copyWith(
                                      fontSize: 13,
                                      fontWeight: CustomTheme.fontWeightSemiBold,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Actions ───
  void _handleContinue(CartProvider cartProvider) async {
    if (_currentStep == 0) {
      _goToStep(1);
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        final addressProvider = ref.read(addressProviderNotifier);

        if (addressProvider.addresses.isEmpty) {
          setState(() => _isPlacingOrder = true);
          final success = await addressProvider.addAddress(AddressEntity(
            id: '',
            userId: '',
            street: _addressController.text.trim(),
            city: _cityController.text.trim(),
            state: 'Dhaka Division',
            postalCode: '1000',
            country: 'Bangladesh',
            isDefault: true,
          ));
          setState(() => _isPlacingOrder = false);

          if (!success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        addressProvider.error ?? 'Failed to save address')),
              );
            }
            return;
          }
        }

        _placeOrder(cartProvider);
      }
    }
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    setState(() => _isPlacingOrder = true);

    try {
      final addressProvider = ref.read(addressProviderNotifier);
      final defaultAddress =
          addressProvider.addresses.where((a) => a.isDefault).firstOrNull ??
              (addressProvider.addresses.isNotEmpty
                  ? addressProvider.addresses.first
                  : null);

      if (defaultAddress == null) {
        throw Exception('Please select or add a shipping address first');
      }

      final orderProvider = ref.read(orderProviderNotifier);
      final orderId = await orderProvider.placeOrder(
        shippingAddressId: defaultAddress.id,
        paymentMethod:
            _selectedPayment == 'cash_on_delivery' ? 'cod' : _selectedPayment,
        notes: null,
      );

      await cartProvider.clearCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmScreen(orderId: orderId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $errorMessage'),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _placeOrder(cartProvider),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}