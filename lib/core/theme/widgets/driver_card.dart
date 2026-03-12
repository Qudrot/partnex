import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

enum DriverRiskLevel { critical, needsWork, moderate, good, excellent }

class DriverCard extends StatefulWidget {
  final String driverName;
  final DriverRiskLevel riskLevel;
  final double percentage;
  final double impactPoints;
  final String description;
  final bool initiallyExpanded;

  const DriverCard({
    super.key,
    required this.driverName,
    required this.riskLevel,
    required this.percentage,
    required this.impactPoints,
    required this.description,
    this.initiallyExpanded = false,
  });

  @override
  State<DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<DriverCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggleExpand() => setState(() => _isExpanded = !_isExpanded);

  String get _riskLevelLabel {
    switch (widget.riskLevel) {
      case DriverRiskLevel.critical:
        return 'Critical Risk';
      case DriverRiskLevel.needsWork:
        return 'Needs Work';
      case DriverRiskLevel.moderate:
        return 'Moderate';
      case DriverRiskLevel.good:
        return 'Good';
      case DriverRiskLevel.excellent:
        return 'Excellent';
    }
  }

  Color get _badgeBackgroundColor {
    switch (widget.riskLevel) {
      case DriverRiskLevel.critical:
        return AppColors.dangerRed.withValues(alpha: 0.1);
      case DriverRiskLevel.needsWork:
      case DriverRiskLevel.moderate:
        return AppColors.warningBg;
      case DriverRiskLevel.good:
      case DriverRiskLevel.excellent:
        return AppColors.successBg;
    }
  }

  Color get _badgeTextColor {
    switch (widget.riskLevel) {
      case DriverRiskLevel.critical:
        return AppColors.dangerRed;
      case DriverRiskLevel.needsWork:
      case DriverRiskLevel.moderate:
        return AppColors.warningAmberText;
      case DriverRiskLevel.good:
      case DriverRiskLevel.excellent:
        return AppColors.successGreenText;
    }
  }

  Color get _progressFillColor {
    switch (widget.riskLevel) {
      case DriverRiskLevel.critical:
        return AppColors.dangerRed;
      case DriverRiskLevel.needsWork:
      case DriverRiskLevel.moderate:
        return AppColors.warningOrange;
      case DriverRiskLevel.good:
        return AppColors.warningAmber;
      case DriverRiskLevel.excellent:
        return AppColors.successGreen;
    }
  }

  Color get _impactPointsColor => widget.impactPoints > 0
      ? AppColors.successGreen
      : AppColors.dangerRed;

  @override
  Widget build(BuildContext context) {
    final impactSign = widget.impactPoints > 0 ? '+' : '';

    return Semantics(
      label: '${widget.driverName} driver card',
      expanded: _isExpanded,
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpand,
            hoverColor: AppColors.slate50,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.driverName,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.slate900,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _toggleExpand,
                        iconSize: 20,
                        color: AppColors.slate600,
                        icon: Icon(
                          _isExpanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                        ),
                        tooltip: _isExpanded
                            ? 'Collapse description'
                            : 'Expand description',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (widget.percentage / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _progressFillColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced spacing per request
                  Text(
                    '${widget.percentage.toInt()}%',
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.slate600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: _isExpanded
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top: 8,
                                ), // Maintained spacing
                                child: Text(
                                  widget.description,
                                  style: AppTypography.textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppColors.slate600,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        height: 1.6,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Text(
                                    '$impactSign${widget.impactPoints.toStringAsFixed(1)} pts',
                                    style: AppTypography.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: _impactPointsColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _badgeBackgroundColor,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _riskLevelLabel,
                                      style: AppTypography.textTheme.bodySmall
                                          ?.copyWith(
                                            color: _badgeTextColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
