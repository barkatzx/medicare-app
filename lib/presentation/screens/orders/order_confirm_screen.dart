import 'package:flutter/material.dart';
import '../../widgets/common/custom_theme.dart';

class OrderConfirmScreen extends StatelessWidget {
  final String? orderId;
  const OrderConfirmScreen({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(CustomTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildSuccessIcon(),
              SizedBox(height: CustomTheme.spacingXXL),
              Text(
                'Order Placed Successfully!',
                style: CustomTextStyle.heading1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: CustomTheme.spacingMD),
              Text(
                'Thank you for your purchase. Your order is being processed and will be delivered soon.',
                style: CustomTextStyle.bodyLarge.copyWith(color: CustomTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              if (orderId != null) ...[
                SizedBox(height: CustomTheme.spacingXL),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: CustomTheme.spacingLG,
                    vertical: CustomTheme.spacingMD,
                  ),
                  decoration: BoxDecoration(
                    color: CustomTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                    border: Border.all(color: CustomTheme.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Order ID: ', style: CustomTextStyle.bodyMedium),
                      Text(
                        orderId!,
                        style: CustomTextStyle.bodyMedium.copyWith(
                          fontWeight: CustomTheme.fontWeightBold,
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: CustomTheme.successColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated or static circles for ripple effect
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: CustomTheme.successColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 80,
            color: CustomTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushNamed(context, '/my-orders');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
              ),
              elevation: 0,
            ),
            child: Text('Track My Order', style: CustomTextStyle.button),
          ),
        ),
        SizedBox(height: CustomTheme.spacingMD),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: CustomTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
              ),
            ),
            child: Text(
              'Continue Shopping',
              style: CustomTextStyle.button.copyWith(color: CustomTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
}
