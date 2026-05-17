import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
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
                decoration: const BoxDecoration(color: CustomTheme.surfaceColor, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: CustomTheme.textPrimary, size: 16),
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
                  _buildInfoRow('Version', '1.2.2'),
                  _buildDivider(),
                  _buildInfoRow('Last Update', 'May 2026'),
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
                  _buildInfoRow('Website', 'www.medicare.com'),
                  _buildDivider(),
                  _buildInfoRow('Contact', 'support@medicare.com'),
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
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: CustomTheme.surfaceColor,
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset(
              'assets/images/MediCarePLC.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: CustomTheme.spacingLG),
        Text(
          'MediCarePLC',
          style: CustomTextStyle.heading2.copyWith(fontWeight: CustomTheme.fontWeightBold),
        ),
        const SizedBox(height: CustomTheme.spacingXS),
        Text(
          'Your Trusted Health Partner',
          style: CustomTextStyle.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: CustomTheme.spacingSM, bottom: CustomTheme.spacingSM),
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
          child: Column(
            children: children,
          ),
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
              ),
            ),
            Text(
              value,
              style: CustomTextStyle.bodyMedium.copyWith(
                color: onTap != null ? CustomTheme.primaryColor : CustomTheme.textSecondary,
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
            _buildSocialIcon(FontAwesomeIcons.facebookF, const Color(0xFF1877F2), 'https://facebook.com/'),
            const SizedBox(width: CustomTheme.spacingLG),
            _buildSocialIcon(FontAwesomeIcons.instagram, const Color(0xFFE4405F), 'https://instagram.com/'),
            const SizedBox(width: CustomTheme.spacingLG),
            _buildSocialIcon(FontAwesomeIcons.linkedinIn, const Color(0xFF0A66C2), 'https://linkedin.com/'),
            const SizedBox(width: CustomTheme.spacingLG),
            _buildSocialIcon(FontAwesomeIcons.whatsapp, const Color(0xFF25D366), 'https://whatsapp.com/'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(dynamic icon, Color color, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: CustomTheme.surfaceColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  void _showQodeaxModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CustomTheme.radiusXL)),
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
                style: CustomTextStyle.heading3.copyWith(fontWeight: CustomTheme.fontWeightBold),
              ),
              const SizedBox(height: CustomTheme.spacingLG),
              Text(
                'Qodeax is a premier software development agency specializing in modern, beautiful, and scalable applications.',
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodyMedium,
              ),
              const SizedBox(height: CustomTheme.spacingLG),
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://www.qodeax.com/');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
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
