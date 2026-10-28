import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/custom_theme.dart';

class OrderConfirmScreen extends StatefulWidget {
  final String? orderId;
  const OrderConfirmScreen({super.key, this.orderId});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _checkScale;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _checkScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    _ringScale = Tween<double>(begin: 0.7, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _ringOpacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_contentFade);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Respect the system "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _copyOrderId() {
    final id = widget.orderId;
    if (id == null) return;
    Clipboard.setData(ClipboardData(text: id));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Order ID copied'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  CustomTheme.spacingXL,
                  CustomTheme.spacingXXL,
                  CustomTheme.spacingXL,
                  CustomTheme.spacingLG,
                ),
                child: Column(
                  children: [
                    SizedBox(height: CustomTheme.spacingXL),
                    _buildSuccessIcon(),
                    SizedBox(height: CustomTheme.spacingXXL),
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            Text(
                              'Order Placed Successfully',
                              style: CustomTextStyle.heading1,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: CustomTheme.spacingMD),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(
                                'Thanks for your purchase. We\'re getting your order ready and will deliver it soon.',
                                style: CustomTextStyle.bodyLarge.copyWith(
                                  color: CustomTheme.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: CustomTheme.spacingXXL),
                            _buildSummaryCard(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeTransition(
              opacity: _contentFade,
              child: _buildActions(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------------

  Widget _buildSuccessIcon() {
    final color = CustomTheme.successColor;
    return SizedBox(
      width: 160,
      height: 160,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // One-time ripple that expands and fades out.
              Opacity(
                opacity: _ringOpacity.value,
                child: Transform.scale(
                  scale: _ringScale.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                    ),
                  ),
                ),
              ),
              // Soft halo.
              Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.08),
                ),
              ),
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.16),
                ),
              ),
              // Solid badge with check.
              Transform.scale(
                scale: _checkScale.value.clamp(0.0, 1.2),
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Summary card: order id + delivery progress
  // ---------------------------------------------------------------------------

  Widget _buildSummaryCard() {
    final hasId = widget.orderId != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CustomTheme.surfaceColor,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
      ),
      child: Column(
        children: [
          if (hasId) ...[
            _buildOrderIdRow(),
            Divider(height: 1, thickness: 1, color: CustomTheme.borderLight),
          ],
          Padding(
            padding: EdgeInsets.all(CustomTheme.spacingLG),
            child: Column(
              children: const [
                _TimelineStep(
                  title: 'Order placed',
                  subtitle: 'We\'ve received your order',
                  state: _StepState.done,
                ),
                _TimelineStep(
                  title: 'Processing',
                  subtitle: 'Packing your items',
                  state: _StepState.current,
                ),
                _TimelineStep(
                  title: 'On the way',
                  subtitle: 'Out for delivery soon',
                  state: _StepState.upcoming,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderIdRow() {
    return InkWell(
      onTap: _copyOrderId,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(CustomTheme.radiusMD),
        topRight: Radius.circular(CustomTheme.radiusMD),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: CustomTheme.spacingLG,
          vertical: CustomTheme.spacingMD,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID',
                    style: CustomTextStyle.bodyMedium.copyWith(
                      color: CustomTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.orderId!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyle.bodyLarge.copyWith(
                      fontWeight: CustomTheme.fontWeightBold,
                      color: CustomTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CustomTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.copy_rounded,
                size: 18,
                color: CustomTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        CustomTheme.spacingXL,
        CustomTheme.spacingMD,
        CustomTheme.spacingXL,
        CustomTheme.spacingLG,
      ),
      decoration: BoxDecoration(
        color: CustomTheme.backgroundColor,
        border: Border(top: BorderSide(color: CustomTheme.borderLight)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushNamed(context, '/my-orders');
              },
              icon: const Icon(Icons.local_shipping_outlined, size: 20),
              label: Text('Track my order', style: CustomTextStyle.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
                ),
              ),
            ),
          ),
          SizedBox(height: CustomTheme.spacingMD),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: TextButton.styleFrom(
                foregroundColor: CustomTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
              ),
              child: Text(
                'Continue shopping',
                style: CustomTextStyle.button.copyWith(
                  color: CustomTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Timeline step
// -----------------------------------------------------------------------------

enum _StepState { done, current, upcoming }

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final _StepState state;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.state,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = state == _StepState.done;
    final isCurrent = state == _StepState.current;
    final isUpcoming = state == _StepState.upcoming;

    final accent = isDone ? CustomTheme.successColor : CustomTheme.primaryColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                _buildDot(accent, isDone, isCurrent, isUpcoming),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: isDone
                            ? CustomTheme.successColor.withValues(alpha: 0.5)
                            : CustomTheme.borderLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: CustomTheme.spacingMD),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : CustomTheme.spacingLG,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomTextStyle.bodyMedium.copyWith(
                      fontWeight: CustomTheme.fontWeightBold,
                      color: isUpcoming ? CustomTheme.textSecondary : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: CustomTextStyle.bodyMedium.copyWith(
                      color: CustomTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color accent, bool isDone, bool isCurrent, bool isUpcoming) {
    if (isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
      );
    }
    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent.withValues(alpha: 0.12),
          border: Border.all(color: accent, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: CustomTheme.borderLight, width: 2),
      ),
    );
  }
}
