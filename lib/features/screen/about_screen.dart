import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicare_app/core/theme/custom_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text('About', style: CustomTextStyle.heading3),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: CustomTheme.surfaceColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: CustomTheme.textPrimary,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(CustomTheme.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: CustomTheme.spacingXL),
              _buildLogoSection(),
              const SizedBox(height: CustomTheme.spacingXXL),
              _buildSection(
                title: 'APP INFO',
                children: [
                  _buildInfoRow('Version', '2.0.0'),
                  _buildDivider(),
                  _buildInfoRow('Last Update', 'Oct 2026'),
                  _buildDivider(),
                  _buildInfoRow(
                    'Privacy Policy',
                    'View',
                    onTap: () => _openLink(
                      context,
                      'https://medicareplc.com/privacy-policy.html',
                    ),
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Refund & Return Policy',
                    'View',
                    onTap: () => _openLink(
                      context,
                      'https://medicareplc.com/return-refund-policy.html',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CustomTheme.spacingXL),
              _buildSection(
                title: 'COMPANY INFO',
                children: [
                  _buildInfoRow(
                    'Developer',
                    'Qodeax',
                    onTap: () => _showQodeaxModal(context),
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Website',
                    'medicareplc.com',
                    onTap: () => _openLink(context, 'https://medicareplc.com'),
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    'Contact',
                    'support@medicareplc.com',
                    onTap: () =>
                        _openLink(context, 'mailto:support@medicareplc.com'),
                  ),
                ],
              ),
              const SizedBox(height: CustomTheme.spacingXL),
              _buildSection(
                title: 'SUPPORT',
                children: [
                  _buildInfoRow(
                    'Rate the App',
                    'Rate',
                    onTap: () => _openLink(
                      context,
                      'https://play.google.com/store/apps/details?id=com.medicareplc.app&pcampaignid=web_share',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CustomTheme.spacingXL),
              _buildSocialLinks(context),
              const SizedBox(height: CustomTheme.spacingXXL),
              Text(
                '© ${DateTime.now().year} MediCare PLC. All rights reserved.',
                style: CustomTextStyle.caption,
              ),
              const SizedBox(height: CustomTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/MediCarePLC.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: CustomTheme.spacingMD),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MediCarePLC',
                  style: CustomTextStyle.heading2.copyWith(
                    color: CustomTheme.primaryColor,
                    fontWeight: CustomTheme.fontWeightBold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: CustomTheme.spacingXS),
                Text(
                  'Your Trusted B2B Sales Partner',
                  style: CustomTextStyle.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: CustomTheme.spacingSM,
            bottom: CustomTheme.spacingSM,
          ),
          child: Text(
            title,
            style: CustomTextStyle.bodySmall.copyWith(
              color: CustomTheme.textTertiary,
              letterSpacing: 1.2,
              fontWeight: CustomTheme.fontWeightBold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CustomTheme.spacingLG,
          vertical: CustomTheme.spacingMD,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: CustomTextStyle.bodyMedium.copyWith(
                fontWeight: CustomTheme.fontWeightMedium,
                fontSize: 15,
              ),
            ),
            Text(
              value,
              style: CustomTextStyle.bodyMedium.copyWith(
                color: onTap != null
                    ? CustomTheme.primaryColor
                    : CustomTheme.textSecondary,
                fontWeight: onTap != null ? CustomTheme.fontWeightBold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: CustomTheme.borderLight,
      indent: CustomTheme.spacingLG,
      endIndent: CustomTheme.spacingLG,
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    return Column(
      children: [
        Text(
          'CONNECT WITH US',
          style: CustomTextStyle.bodySmall.copyWith(
            color: CustomTheme.textTertiary,
            letterSpacing: 1.2,
            fontWeight: CustomTheme.fontWeightBold,
          ),
        ),
        const SizedBox(height: CustomTheme.spacingLG),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              context,
              FontAwesomeIcons.facebookF,
              const Color(0xFF1877F2),
              'https://www.facebook.com/MediCareplc/',
            ),
            const SizedBox(width: CustomTheme.spacingLG),
            _buildSocialIcon(
              context,
              FontAwesomeIcons.instagram,
              const Color(0xFFE4405F),
              'https://www.instagram.com/MediCareplc/',
            ),
            const SizedBox(width: CustomTheme.spacingLG),
            _buildSocialIcon(
              context,
              FontAwesomeIcons.linkedinIn,
              const Color(0xFF0A66C2),
              'https://www.linkedin.com/company/medicareplc/',
            ),
            const SizedBox(width: CustomTheme.spacingLG),
            _buildSocialIcon(
              context,
              FontAwesomeIcons.whatsapp,
              const Color(0xFF25D366),
              'https://whatsapp.com/+8801568393323',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    dynamic icon,
    Color color,
    String url,
  ) {
    return InkWell(
      onTap: () => _openLink(context, url),
      borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: FaIcon(icon, color: color, size: 20)),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String link) async {
    final uri = Uri.parse(link);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open this link')));
    }
  }

  void _showQodeaxModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CustomTheme.radiusXL),
        ),
      ),
      backgroundColor: CustomTheme.surfaceColor,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(CustomTheme.spacingXXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: CustomTheme.borderMedium,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: CustomTheme.spacingXL),
              Text(
                'About Qodeax',
                style: CustomTextStyle.heading3.copyWith(
                  fontWeight: CustomTheme.fontWeightBold,
                ),
              ),
              const SizedBox(height: CustomTheme.spacingLG),
              Text(
                'Qodeax is a premier software development agency specializing in modern, beautiful, and scalable applications.',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium,
              ),
              const SizedBox(height: CustomTheme.spacingLG),
              InkWell(
                onTap: () => _openLink(context, 'https://www.qodeax.com/'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.link, color: CustomTheme.primaryColor),
                      const SizedBox(width: CustomTheme.spacingSM),
                      Text(
                        'https://www.qodeax.com/',
                        style: CustomTextStyle.link,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: CustomTheme.spacingXXL),
            ],
          ),
        );
      },
    );
  }
}
