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

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPayment = 'cash_on_delivery';
  bool _isPlacingOrder = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
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
    _notesController.dispose();
    super.dispose();
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
          _buildStepIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(CustomTheme.spacingMD),
              child: _currentStep == 0
                  ? _buildShippingForm(cartProvider)
                  : _buildOrderReview(cartProvider),
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
      leading: Container(
        margin: EdgeInsets.only(left: CustomTheme.spacingMD),
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomTheme.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep = 0);
            } else {
              Navigator.pop(context);
            }
          },
          splashRadius: 20,
        ),
      ),
      title: Text('Checkout', style: CustomTextStyle.heading2),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CustomTheme.spacingXXL,
        vertical: CustomTheme.spacingMD,
      ),
      child: Row(
        children: [
          _buildStep(0, 'Shipping', Icons.local_shipping_outlined),
          Expanded(child: _buildStepLine(0)),
          _buildStep(1, 'Review', Icons.receipt_long_outlined),
        ],
      ),
    );
  }

  Widget _buildStep(int index, String label, IconData icon) {
    final isActive = _currentStep >= index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isActive ? CustomTheme.primaryColor : CustomTheme.surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? CustomTheme.primaryColor : CustomTheme.borderLight,
              width: 2,
            ),
          ),
          child: Icon(icon, size: 20, color: isActive ? Colors.white : CustomTheme.textTertiary),
        ),
        SizedBox(height: CustomTheme.spacingXS),
        Text(
          label,
          style: CustomTextStyle.caption.copyWith(
            color: isActive ? CustomTheme.primaryColor : CustomTheme.textTertiary,
            fontWeight: isActive ? CustomTheme.fontWeightSemiBold : CustomTheme.fontWeightRegular,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Container(
      height: 2,
      margin: EdgeInsets.only(bottom: CustomTheme.spacingLG),
      decoration: BoxDecoration(
        color: isActive ? CustomTheme.primaryColor : CustomTheme.borderLight,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  // ─── Step 1: Shipping Form ───
  Widget _buildShippingForm(CartProvider cartProvider) {
    final items = cartProvider.cartItems;
    final addressProvider = ref.watch(addressProviderNotifier);
    final user = ref.watch(authProviderNotifier).currentUser;

    // Find default address: prioritize isDefault, then the first one, or null
    final defaultAddress = addressProvider.addresses.where((a) => a.isDefault).firstOrNull ??
        (addressProvider.addresses.isNotEmpty ? addressProvider.addresses.first : null);

    // If we have a default address, pre-fill the controllers if they are empty
    if (defaultAddress != null && _addressController.text.isEmpty) {
      _addressController.text = defaultAddress.street;
      _cityController.text = defaultAddress.city;
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Order Items Summary ──
          _buildSectionTitle('Your Items (${items.length})', Icons.shopping_bag_outlined),
          SizedBox(height: CustomTheme.spacingMD),
          Container(
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
            ),
            child: Column(
              children: [
                ...items.map((item) => Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: CustomTheme.spacingMD,
                    vertical: CustomTheme.spacingSM,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: CustomTheme.secondaryColor,
                          borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                          child: item.productImage.isNotEmpty
                              ? Image.network(item.productImage, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.medical_services, size: 20, color: CustomTheme.textTertiary))
                              : Icon(Icons.medical_services, size: 20, color: CustomTheme.textTertiary),
                        ),
                      ),
                      SizedBox(width: CustomTheme.spacingSM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: CustomTextStyle.bodySmall.copyWith(
                              fontWeight: CustomTheme.fontWeightMedium, color: CustomTheme.textPrimary),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${item.finalPrice.toStringAsFixed(2)}৳ × ${item.quantity}',
                                style: CustomTextStyle.caption),
                          ],
                        ),
                      ),
                      Text('${item.itemTotal.toStringAsFixed(2)}৳', style: CustomTextStyle.bodySmall.copyWith(
                        fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.primaryColor)),
                    ],
                  ),
                )),
                Divider(height: 1, color: CustomTheme.borderLight),
                Padding(
                  padding: EdgeInsets.all(CustomTheme.spacingMD),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightSemiBold)),
                      Text('${cartProvider.total.toStringAsFixed(2)}৳', style: CustomTextStyle.bodyMedium.copyWith(
                        fontWeight: CustomTheme.fontWeightBold, color: CustomTheme.primaryColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: CustomTheme.spacingXL),

          // ── Delivery Information ──
          _buildSectionTitle('Delivery Information', Icons.person_outline),
          SizedBox(height: CustomTheme.spacingMD),
          Container(
            padding: EdgeInsets.all(CustomTheme.spacingMD),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
              border: Border.all(color: CustomTheme.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.person_outline, 'Name', user?.name ?? 'N/A'),
                Divider(height: 24),
                _buildInfoRow(Icons.local_pharmacy_outlined, 'Pharmacy', user?.pharmacyName ?? 'N/A'),
                Divider(height: 24),
                _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? 'N/A'),
                Divider(height: 24),
                _buildInfoRow(Icons.phone_outlined, 'Phone', user?.phoneNumber ?? 'N/A'),
              ],
            ),
          ),
          SizedBox(height: CustomTheme.spacingXL),

          // ── Shipping Address ──
          _buildSectionTitle('Shipping Address', Icons.location_on_outlined),
          SizedBox(height: CustomTheme.spacingMD),
          
          if (defaultAddress != null)
            Container(
              padding: EdgeInsets.all(CustomTheme.spacingMD),
              decoration: BoxDecoration(
                color: CustomTheme.surfaceColor,
                borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                border: Border.all(color: CustomTheme.primaryColor.withOpacity(0.5), width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.home_outlined, color: CustomTheme.primaryColor),
                  SizedBox(width: CustomTheme.spacingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(defaultAddress.street, style: CustomTextStyle.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text('${defaultAddress.city}, ${defaultAddress.state}', style: CustomTextStyle.bodySmall),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/addresses'),
                    child: Text('Change', style: TextStyle(color: CustomTheme.primaryColor)),
                  ),
                ],
              ),
            )
          else ...[
            _buildTextField(_addressController, 'Full Address', Icons.home_outlined,
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Address is required' : null),
            SizedBox(height: CustomTheme.spacingMD),
            _buildTextField(_cityController, 'City / Area', Icons.location_city_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'City is required' : null),
          ],
          
          SizedBox(height: CustomTheme.spacingXL),

          _buildSectionTitle('Payment Method', Icons.payment_outlined),
          SizedBox(height: CustomTheme.spacingMD),
          _buildPaymentOption('cash_on_delivery', 'Cash on Delivery', Icons.money_outlined,
              'Pay when you receive your order'),
          SizedBox(height: CustomTheme.spacingXL),
          _buildSectionTitle('Order Notes (Optional)', Icons.note_alt_outlined),
          SizedBox(height: CustomTheme.spacingMD),
          _buildTextField(_notesController, 'Special instructions...', Icons.edit_note_outlined,
              maxLines: 3, isRequired: false),
          SizedBox(height: CustomTheme.spacingXXL),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: CustomTheme.textSecondary),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CustomTextStyle.caption.copyWith(fontSize: 10)),
            Text(value, style: CustomTextStyle.bodyMedium.copyWith(
              color: CustomTheme.textPrimary,
              fontWeight: CustomTheme.fontWeightSemiBold,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: CustomTheme.primaryColor),
        SizedBox(width: CustomTheme.spacingSM),
        Text(title, style: CustomTextStyle.heading4),
      ],
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
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
        border: Border.all(color: CustomTheme.borderLight),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: CustomTextStyle.bodySmall,
          prefixIcon: Icon(icon, size: 20, color: CustomTheme.textTertiary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: CustomTheme.spacingMD,
            vertical: CustomTheme.spacingMD,
          ),
        ),
        validator: isRequired ? validator : null,
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon, String subtitle) {
    final isSelected = _selectedPayment == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(CustomTheme.spacingMD),
        decoration: BoxDecoration(
          color: isSelected ? CustomTheme.primaryColor.withOpacity(0.05) : CustomTheme.surfaceColor,
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          border: Border.all(
            color: isSelected ? CustomTheme.primaryColor : CustomTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isSelected ? CustomTheme.primaryColor.withOpacity(0.1) : CustomTheme.secondaryColor,
                borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
              ),
              child: Icon(icon, size: 20, color: isSelected ? CustomTheme.primaryColor : CustomTheme.textTertiary),
            ),
            SizedBox(width: CustomTheme.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: CustomTextStyle.bodyMedium.copyWith(
                    fontWeight: CustomTheme.fontWeightSemiBold,
                    color: CustomTheme.textPrimary,
                  )),
                  Text(subtitle, style: CustomTextStyle.caption),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CustomTheme.primaryColor : CustomTheme.borderMedium,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: CustomTheme.primaryColor),
                      ),
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
    final items = cartProvider.cartItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shipping summary card
        _buildSectionTitle('Shipping To', Icons.location_on_outlined),
        SizedBox(height: CustomTheme.spacingMD),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(CustomTheme.spacingMD),
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_nameController.text, style: CustomTextStyle.bodyMedium.copyWith(
                fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.textPrimary)),
              SizedBox(height: CustomTheme.spacingXS),
              Text(_phoneController.text, style: CustomTextStyle.bodySmall),
              SizedBox(height: CustomTheme.spacingXS),
              Text('${_addressController.text}, ${_cityController.text}', style: CustomTextStyle.bodySmall),
            ],
          ),
        ),
        SizedBox(height: CustomTheme.spacingXL),

        // Payment summary
        _buildSectionTitle('Payment', Icons.payment_outlined),
        SizedBox(height: CustomTheme.spacingMD),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(CustomTheme.spacingMD),
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          ),
          child: Text(
            'Cash on Delivery',
            style: CustomTextStyle.bodyMedium.copyWith(
              fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.textPrimary),
          ),
        ),
        SizedBox(height: CustomTheme.spacingXL),

        // Order items
        _buildSectionTitle('Order Items (${items.length})', Icons.shopping_bag_outlined),
        SizedBox(height: CustomTheme.spacingMD),
        ...items.map((item) => _buildReviewItem(item)),

        if (_notesController.text.isNotEmpty) ...[
          SizedBox(height: CustomTheme.spacingXL),
          _buildSectionTitle('Notes', Icons.note_alt_outlined),
          SizedBox(height: CustomTheme.spacingMD),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(CustomTheme.spacingMD),
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
            ),
            child: Text(_notesController.text, style: CustomTextStyle.bodyMedium),
          ),
        ],
        SizedBox(height: CustomTheme.spacingXXL),
      ],
    );
  }

  Widget _buildReviewItem(CartItemEntity item) {
    return Container(
      margin: EdgeInsets.only(bottom: CustomTheme.spacingSM),
      padding: EdgeInsets.all(CustomTheme.spacingMD),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: CustomTheme.secondaryColor,
              borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
              child: item.productImage.isNotEmpty
                  ? Image.network(item.productImage, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.medical_services, size: 24, color: CustomTheme.textTertiary))
                  : Icon(Icons.medical_services, size: 24, color: CustomTheme.textTertiary),
            ),
          ),
          SizedBox(width: CustomTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.productName, style: CustomTextStyle.bodyMedium.copyWith(
                  fontWeight: CustomTheme.fontWeightMedium, color: CustomTheme.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: CustomTheme.spacingXS),
                Text('${item.finalPrice.toStringAsFixed(2)}৳ × ${item.quantity}',
                    style: CustomTextStyle.bodySmall),
              ],
            ),
          ),
          Text('${item.itemTotal.toStringAsFixed(2)}৳', style: CustomTextStyle.bodyMedium.copyWith(
            fontWeight: CustomTheme.fontWeightSemiBold, color: CustomTheme.primaryColor)),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(CustomTheme.spacingXXL),
            decoration: BoxDecoration(color: CustomTheme.surfaceColor, shape: BoxShape.circle),
            child: Icon(Icons.shopping_cart_outlined, size: 64, color: CustomTheme.textTertiary),
          ),
          SizedBox(height: CustomTheme.spacingXL),
          Text('Your cart is empty', style: CustomTextStyle.heading3.copyWith(color: CustomTheme.textSecondary)),
          SizedBox(height: CustomTheme.spacingSM),
          Text('Add items to proceed with checkout', style: CustomTextStyle.bodyMedium),
          SizedBox(height: CustomTheme.spacingXXL),
          ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: CustomTheme.spacingXXL, vertical: CustomTheme.spacingMD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
            ),
            child: Text('Start Shopping', style: CustomTextStyle.button),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ───
  Widget _buildBottomBar(CartProvider cartProvider) {
    final total = cartProvider.total;
    final totalSavings = cartProvider.totalSavings;

    return Container(
      padding: EdgeInsets.all(CustomTheme.spacingLG),
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(CustomTheme.radiusLG),
          topRight: Radius.circular(CustomTheme.radiusLG),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentStep == 1) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: CustomTextStyle.bodyMedium),
                Text('${cartProvider.subtotal.toStringAsFixed(2)}৳',
                    style: CustomTextStyle.bodyMedium.copyWith(fontWeight: CustomTheme.fontWeightMedium)),
              ],
            ),
            SizedBox(height: CustomTheme.spacingXS),
            if (totalSavings > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Savings', style: CustomTextStyle.bodySmall),
                  Text('-${totalSavings.toStringAsFixed(2)}৳',
                      style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.successColor)),
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping', style: CustomTextStyle.bodySmall),
                Text('Free', style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.successColor)),
              ],
            ),
            Divider(height: CustomTheme.spacingLG, color: CustomTheme.borderLight),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: CustomTextStyle.heading3.copyWith(fontWeight: CustomTheme.fontWeightBold)),
                Text('${total.toStringAsFixed(2)}৳',
                    style: CustomTextStyle.heading2.copyWith(color: CustomTheme.primaryColor)),
              ],
            ),
            SizedBox(height: CustomTheme.spacingMD),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPlacingOrder ? null : () => _handleContinue(cartProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                disabledBackgroundColor: CustomTheme.primaryColor.withOpacity(0.6),
                padding: EdgeInsets.symmetric(vertical: CustomTheme.spacingMD),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
              ),
              child: _isPlacingOrder
                  ? SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      _currentStep == 0 ? 'Continue to Review' : 'Place Order  •  ${total.toStringAsFixed(2)}৳',
                      style: CustomTextStyle.button,
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
      if (_formKey.currentState?.validate() ?? false) {
        final addressProvider = ref.read(addressProviderNotifier);
        
        // If there are no addresses or no default address, and they filled the form
        if (addressProvider.addresses.isEmpty) {
          setState(() => _isPlacingOrder = true);
          final success = await addressProvider.addAddress(AddressEntity(
            id: '', userId: '',
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
                SnackBar(content: Text(addressProvider.error ?? 'Failed to save address')),
              );
            }
            return;
          }
        }
        
        setState(() => _currentStep = 1);
      }
    } else {
      _placeOrder(cartProvider);
    }
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    setState(() => _isPlacingOrder = true);

    try {
      final prefsHelper = ref.read(sharedPrefsHelperProvider);
      final token = await prefsHelper.getToken();
      if (token == null) throw Exception('Not authenticated');

      final addressProvider = ref.read(addressProviderNotifier);
      final defaultAddress = addressProvider.addresses.where((a) => a.isDefault).firstOrNull ??
          (addressProvider.addresses.isNotEmpty ? addressProvider.addresses.first : null);

      if (defaultAddress == null) {
        throw Exception('Please select or add a shipping address first');
      }

      final body = {
        'shippingAddressId': defaultAddress.id,
        'paymentMethod': _selectedPayment == 'cash_on_delivery' ? 'cod' : _selectedPayment,
        if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
      };

      final response = await http.Client()
          .post(
            Uri.parse(ApiConstants.createOrder),
            headers: ApiConstants.getHeaders(token: token),
            body: json.encode(body),
          )
          .timeout(ApiConstants.connectionTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final respData = json.decode(response.body);
        final orderId = respData['data']?['id']?.toString() ?? respData['data']?['_id']?.toString();
        
        // Clear cart after successful order
        await cartProvider.clearCart();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OrderConfirmScreen(orderId: orderId),
            ),
          );
        }
      } else {
        final errData = json.decode(response.body);
        throw Exception(errData['error'] ?? errData['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: CustomTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }
}
