import 'package:flutter/material.dart';
import 'package:partnex/core/theme/app_colors.dart';
import 'package:partnex/core/theme/app_typography.dart';

/// A widget that renders [text] constrained to 2 lines.
/// If the text exceeds 2 lines, it is cut at exactly the 2nd line
/// (leaving enough room for [ctaText] on the same line) and an inline
/// CTA link is appended — always on the same line as the ellipsis.
class TwoLineText extends StatelessWidget {
  final String text;
  final String ctaText;
  final VoidCallback? onCtaTap;
  final TextStyle? textStyle;
  final TextStyle? ctaStyle;

  const TwoLineText({
    super.key,
    required this.text,
    required this.ctaText,
    this.onCtaTap,
    this.textStyle,
    this.ctaStyle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;

        final TextStyle resolvedTextStyle = (textStyle ??
                AppTypography.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary(context),
                  height: 1.6,
                ))!;

        final TextStyle resolvedCtaStyle = (ctaStyle ??
                AppTypography.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.linkBlue,
                ))!;

        // Measure if the full text fits in 2 lines.
        final fullPainter = TextPainter(
          text: TextSpan(text: text, style: resolvedTextStyle),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: maxWidth);

        final bool exceedsMaxLines = fullPainter.didExceedMaxLines;

        if (!exceedsMaxLines) {
          // Text fits in 2 lines or fewer — still append CTA inline.
          return Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$text ', style: resolvedTextStyle),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: onCtaTap,
                    child: Text(ctaText, style: resolvedCtaStyle),
                  ),
                ),
              ],
            ),
          );
        }

        // Measure width required by the CTA label (with "... " prefix).
        final ctaPrefixSpan = TextSpan(text: '... ', style: resolvedTextStyle);
        final ctaLabelSpan = TextSpan(text: ctaText, style: resolvedCtaStyle);
        
        final ctaPainter = TextPainter(
          text: TextSpan(children: [ctaPrefixSpan, ctaLabelSpan]),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        final double ctaWidth = ctaPainter.size.width;

        // Find the character position that fills line 2 without exceeding (maxWidth - ctaWidth).
        // We do a binary search on the text length.
        int lo = 0;
        int hi = text.length;
        while (lo < hi - 1) {
          final int mid = (lo + hi) ~/ 2;
          final painter = TextPainter(
            text: TextSpan(text: text.substring(0, mid), style: resolvedTextStyle),
            maxLines: 2,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: maxWidth);

          final metrics = painter.computeLineMetrics();
          bool tooBig = painter.didExceedMaxLines;
          
          if (!tooBig && metrics.length == 2) {
             if (metrics.last.width > maxWidth - ctaWidth) {
                tooBig = true;
             }
          }

          if (tooBig) {
            hi = mid;
          } else {
            lo = mid;
          }
        }

        final String truncated = text.substring(0, lo).trimRight();

        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$truncated... ', style: resolvedTextStyle),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: onCtaTap,
                  child: Text(ctaText, style: resolvedCtaStyle),
                ),
              ),
            ],
          ),
          maxLines: 2,
        );
      },
    );
  }
}
