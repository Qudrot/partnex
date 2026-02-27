import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';

enum CardVariant { standard, elevated, outlined }

class CustomCard extends StatelessWidget {
  final Widget child;
  final CardVariant variant;
  final EdgeInsetsGeometry? padding;

  const CustomCard({
    super.key,
    required this.child,
    this.variant = CardVariant.standard,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case CardVariant.standard:
        return _buildStandardCard();
      case CardVariant.elevated:
        return _buildElevatedCard();
      case CardVariant.outlined:
        return _buildOutlinedCard();
    }
  }

  Widget _buildStandardCard() {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildElevatedCard() {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.07),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildOutlinedCard() {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: child,
    );
  }
}
