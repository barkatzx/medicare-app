import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/di/providers.dart';
import 'package:medicare_app/features/entity/cart_entity.dart';
import 'package:medicare_app/features/entity/user_entity.dart';
import 'package:medicare_app/features/screen/addresses_screen.dart';
import 'package:medicare_app/features/provider/cart_provider.dart';
import 'package:medicare_app/features/screen/order_confirm_screen.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:medicare_app/core/utils/network_error.dart';
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
    _stepFadeAnim = CurvedAnimation(parent: stepCtrl, curve: Curves.easeOut);
    stepCtrl.forward();

    final pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseController = pulseCtrl;
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();
      ref.read(authProviderNotifier).getProfile();
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
        style: CustomTextStyle.heading2.copyWith(fontSize: 20),
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
        _buildSectionHeader(
          'Products Checklist',
          '${items.length} items',
          Icons.shopping_bag_outlined,
        ),
        const SizedBox(height: 8),
        _buildItemsCard(items, cartProvider),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    final accentColor = switch (title) {
      'Delivery Info' => const Color(0xFF3B82F6),
      'Ship To' => const Color(0xFF10B981),
      'Payment' => const Color(0xFF8B5CF6),
      _ => CustomTheme.primaryColor,
    };

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CustomTextStyle.heading4.copyWith(
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              subtitle,
              style: CustomTextStyle.caption.copyWith(
                fontSize: 13,
                color: CustomTheme.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsCard(
    List<CartItemEntity> items,
    CartProvider cartProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CustomTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: item.productImage.isNotEmpty
                              ? Image.network(
                                  item.productImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.medical_services,
                                    size: 22,
                                    color: CustomTheme.textTertiary,
                                  ),
                                )
                              : Icon(
                                  Icons.medical_services,
                                  size: 22,
                                  color: CustomTheme.textTertiary,
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: CustomTextStyle.bodyMedium.copyWith(
                                fontWeight: CustomTheme.fontWeightBold,
                                color: CustomTheme.textPrimary,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CustomTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'x ${item.quantity}',
                                    style: TextStyle(
                                      fontFamily: CustomTheme.primaryFontFamily,
                                      fontSize: 12,
                                      fontWeight: CustomTheme.fontWeightBold,
                                      color: CustomTheme.surfaceColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${item.finalPrice.toStringAsFixed(2)}৳ each',
                                  style: CustomTextStyle.caption.copyWith(
                                    fontSize: 13,
                                    color: CustomTheme.textSecondary,
                                  ),
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
                  Divider(
                    height: 1,
                    color: CustomTheme.borderLight,
                    indent: 14,
                    endIndent: 14,
                  ),
              ],
            );
          }),

          // Total row
          Divider(
            height: 1,
            thickness: 1,
            color: CustomTheme.borderLight,
            indent: 12,
            endIndent: 12,
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
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
                    fontSize: 15,
                    fontWeight: CustomTheme.fontWeightBold,
                    color: CustomTheme.textPrimary,
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
          _buildInfoTile(
            Icons.person_outline,
            'Full Name',
            user?.name ?? 'N/A',
            false,
            const Color(0xFF3B82F6),
          ),
          _buildInfoTile(
            Icons.local_pharmacy_outlined,
            'Pharmacy',
            user?.pharmacyName ?? 'N/A',
            false,
            const Color(0xFF14B8A6),
          ),
          _buildInfoTile(
            Icons.email_outlined,
            'Email',
            user?.email ?? 'N/A',
            false,
            const Color(0xFF8B5CF6),
          ),
          _buildInfoTile(
            Icons.phone_outlined,
            'Phone',
            user?.phoneNumber ?? 'N/A',
            true,
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    bool isLast,
    Color iconColor,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: CustomTextStyle.caption.copyWith(
                        fontSize: 13,
                        letterSpacing: 0.5,
                        color: CustomTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: CustomTextStyle.bodyMedium.copyWith(
                        color: CustomTheme.textPrimary,
                        fontWeight: CustomTheme.fontWeightBold,
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
          Divider(
            height: 1,
            color: CustomTheme.borderLight,
            indent: 62,
            endIndent: 16,
          ),
      ],
    );
  }

  Widget _buildAddressCard(UserEntity? user) {
    final hasAddress = user?.hasAddress ?? false;
    const addressColor = Color(0xFF10B981);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: addressColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.home_outlined, color: addressColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasAddress ? user!.fullAddress! : 'No address added yet',
                style: CustomTextStyle.bodyMedium.copyWith(
                  color: CustomTheme.textPrimary,
                  fontWeight: CustomTheme.fontWeightBold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasAddress)
                Text(
                  '${user!.upazila!.label}, ${user.district!.label}, ${user.division!.label}',
                  style: CustomTextStyle.caption.copyWith(fontSize: 13),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _editAddress(user),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: CustomTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              hasAddress ? 'Change' : 'Add',
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
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    dynamic icon,
    String subtitle,
  ) {
    final isSelected = _selectedPayment == value;
    const paymentColor = Color(0xFF8B5CF6);
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: paymentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: icon is IconData
                    ? Icon(icon, size: 22, color: paymentColor)
                    : FaIcon(icon, size: 20, color: paymentColor),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: CustomTheme.primaryFontFamily,
                      fontSize: 15,
                      fontWeight: CustomTheme.fontWeightBold,
                      color: isSelected
                          ? CustomTheme.textPrimary
                          : CustomTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CustomTextStyle.caption.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? paymentColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? paymentColor : CustomTheme.borderMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 2: Order Review ───
  Widget _buildOrderReview(CartProvider cartProvider) {
    final user = ref.watch(authProviderNotifier).currentUser;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Delivery Information ──
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildSectionHeader(
              'Personal Details',
              'Auto-filled',
              Icons.person_outline,
            ),
          ),
          _buildDeliveryInfoCard(user),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildSectionHeader(
              'Ship & Payment',
              'Address and payment method',
              Icons.local_shipping_outlined,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressCard(user),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    color: CustomTheme.borderLight,
                    indent: 46,
                  ),
                ),
                _buildPaymentOption(
                  'cash_on_delivery',
                  'Cash on Delivery',
                  FontAwesomeIcons.handHoldingDollar,
                  'Pay when you receive your order',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
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
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 46,
                color: CustomTheme.textTertiary,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: CustomTheme.primaryColor,
                  borderRadius: BorderRadius.circular(14),
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
        10,
        16,
        MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStep == 1) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: CustomTextStyle.bodyMedium.copyWith(
                          fontSize: 13,
                        ),
                      ),
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
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your savings',
                          style: CustomTextStyle.caption.copyWith(fontSize: 13),
                        ),
                        Text(
                          '-${totalSavings.toStringAsFixed(2)}৳',
                          style: TextStyle(
                            fontFamily: CustomTheme.primaryFontFamily,
                            fontSize: 13,
                            fontWeight: CustomTheme.fontWeightSemiBold,
                            color: CustomTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Divider(height: 1, color: CustomTheme.borderLight),
                  const SizedBox(height: 6),
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
                          fontSize: 18,
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
            const SizedBox(height: 8),
          ],

          SizedBox(
            width: double.infinity,
            height: 48,
            child: AnimatedBuilder(
              animation: _pulseAnim ?? const AlwaysStoppedAnimation(1.0),
              builder: (context, child) {
                return Transform.scale(
                  scale: _isPlacingOrder ? (_pulseAnim?.value ?? 1.0) : 1.0,
                  child: child,
                );
              },
              child: ElevatedButton(
                onPressed: _isPlacingOrder
                    ? null
                    : () => _handleContinue(cartProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryColor,
                  disabledBackgroundColor: CustomTheme.primaryColor.withValues(
                    alpha: 0.5,
                  ),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: CustomTheme.primaryColor,
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
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    '${total.toStringAsFixed(2)}৳',
                                    style: CustomTextStyle.button.copyWith(
                                      fontSize: 13,
                                      fontWeight:
                                          CustomTheme.fontWeightSemiBold,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
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
        final user = ref.read(authProviderNotifier).currentUser;
        if (user == null || !user.hasAddress) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add your delivery address first'),
            ),
          );
          await _editAddress(user);
          final updated = ref.read(authProviderNotifier).currentUser;
          if (mounted && (updated?.hasAddress ?? false)) {
            _placeOrder(cartProvider);
          }
          return;
        }
        _placeOrder(cartProvider);
      }
    }
  }

  Future<void> _editAddress(UserEntity? user) async {
    if (user == null) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressFormSheet(user: user),
    );
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);

    try {
      final orderProvider = ref.read(orderProviderNotifier);
      final orderId = await orderProvider.placeOrder(
        paymentMethod: _selectedPayment == 'cash_on_delivery'
            ? 'cod'
            : _selectedPayment,
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
        final errorMessage = friendlyErrorMessage(
          e,
        ).replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $errorMessage'),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
