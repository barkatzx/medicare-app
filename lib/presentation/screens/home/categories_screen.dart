import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medicare_app/core/providers.dart';
import 'package:medicare_app/presentation/widgets/common/custom_theme.dart';
import 'package:medicare_app/routes/app_routes.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(categoryProviderNotifier);
      if (provider.categories.isEmpty) {
        provider.fetchCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(categoryProviderNotifier);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Company',
          style: CustomTextStyle.heading2,
        ),
        backgroundColor: CustomTheme.backgroundColor,
        foregroundColor: CustomTheme.textPrimary,
        elevation: 0,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(provider) {
    if (provider.isLoading && provider.categories.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: CustomTheme.primaryColor,
        ),
      );
    }

    if (provider.errorMessage != null && provider.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CustomTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: CustomTheme.errorColor,
              ),
            ),
            SizedBox(height: CustomTheme.spacingLG),
            Text(
              provider.errorMessage!,
              style: CustomTextStyle.bodyMedium.copyWith(
                color: CustomTheme.errorColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: CustomTheme.spacingLG),
            ElevatedButton(
              onPressed: () {
                provider.fetchCategories();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CustomTheme.radiusRound),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: CustomTheme.spacingXL,
                  vertical: CustomTheme.spacingMD,
                ),
              ),
              child: Text(
                'Retry',
                style: CustomTextStyle.button,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: CustomTheme.textTertiary,
            ),
            SizedBox(height: CustomTheme.spacingMD),
            Text(
              'No categories found',
              style: CustomTextStyle.bodyLarge.copyWith(
                color: CustomTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchCategories(),
      color: CustomTheme.primaryColor,
      child: GridView.builder(
        padding: EdgeInsets.all(CustomTheme.spacingMD),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final category = provider.categories[index];
          return Container(
            decoration: BoxDecoration(
              color: CustomTheme.surfaceColor,
              borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
              boxShadow: CustomTheme.boxShadowLight,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(CustomTheme.radiusLG),
                onTap: () {
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.categoryProducts, 
                    arguments: {
                      'id': category.id,
                      'name': category.name.trim(),
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(CustomTheme.spacingSM),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: CustomTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 30,
                          color: CustomTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: CustomTheme.spacingMD),
                      Text(
                        category.name.trim(),
                        style: CustomTextStyle.bodyMedium.copyWith(
                          fontWeight: CustomTheme.fontWeightSemiBold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: CustomTheme.spacingXS),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: CustomTheme.spacingSM,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CustomTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
                        ),
                        child: Text(
                          '${category.productCount} Products',
                          style: CustomTextStyle.caption.copyWith(
                            color: CustomTheme.primaryColor,
                            fontWeight: CustomTheme.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
