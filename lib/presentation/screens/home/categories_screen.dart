import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(categoryProviderNotifier);

    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        title: _buildSearchField(provider),
        titleSpacing: 20,
        backgroundColor: CustomTheme.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildSearchField(provider) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => provider.searchCategories(value),
        style: CustomTextStyle.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Square, Beximco, Incepta ...',
          hintStyle: CustomTextStyle.bodyMedium.copyWith(color: CustomTheme.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded, color: CustomTheme.primaryColor, size: 22),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: CustomTheme.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    provider.searchCategories('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildBody(provider) {
    if (provider.isLoading && provider.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: CustomTheme.primaryColor, strokeWidth: 2));
    }

    if (provider.errorMessage != null && provider.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: CustomTheme.errorColor),
              const SizedBox(height: 24),
              Text('Oops! Something went wrong', style: CustomTextStyle.heading3),
              const SizedBox(height: 8),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textSecondary),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => provider.fetchCategories(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CustomTheme.radiusRound)),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categories = provider.categories;

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: CustomTheme.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded, size: 48, color: CustomTheme.textTertiary.withOpacity(0.5)),
            ),
            const SizedBox(height: 20),
            Text('No companies found', style: CustomTextStyle.heading3),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name',
              style: CustomTextStyle.bodySmall.copyWith(color: CustomTheme.textTertiary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchCategories(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 5),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(category) {
    return GestureDetector(
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
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CustomTheme.radiusMD),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CustomTheme.primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(CustomTheme.radiusSM),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: CustomTheme.primaryColor,
                size: 14,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name.trim(),
                    style: CustomTextStyle.bodyLarge.copyWith(
                      fontWeight: CustomTheme.fontWeightBold,
                      color: CustomTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.productCount} Products Available',
                    style: CustomTextStyle.caption.copyWith(
                      color: CustomTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: CustomTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
