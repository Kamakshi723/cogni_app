import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class CogniCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? customSurface;
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final Border? customBorder;
  final double? borderRadius;

  const CogniCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.customSurface,
    this.gradient,
    this.boxShadow,
    this.customBorder,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = customSurface ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final radius = borderRadius ?? AppTheme.radiusCard;

    final decoration = BoxDecoration(
      color: gradient == null ? surfaceColor : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: customBorder ?? Border.all(
        color: gradient != null 
            ? Colors.white.withValues(alpha: 0.12)
            : borderColor, 
        width: 1.0,
      ),
      boxShadow: boxShadow ?? (isDark 
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ]
          : AppTheme.cardShadow),
    );

    Widget content = Container(
      margin: margin,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.s20),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            splashColor: isDark 
                ? Colors.white.withValues(alpha: 0.08) 
                : AppColors.lightAccent.withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            onTap: onTap,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppTheme.s20),
              child: child,
            ),
          ),
        ),
      );
    }

    return content;
  }
}
