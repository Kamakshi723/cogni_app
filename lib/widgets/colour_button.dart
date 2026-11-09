import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/stroop_colors.dart';

class ColourButton extends StatefulWidget {
  final StroopItem item;
  final bool showColorBlindSymbol;
  final VoidCallback onTap;

  const ColourButton({
    super.key,
    required this.item,
    required this.showColorBlindSymbol,
    required this.onTap,
  });

  @override
  State<ColourButton> createState() => _ColourButtonState();
}

class _ColourButtonState extends State<ColourButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = StroopColors.getColor(widget.item);
    final textColor = StroopColors.getTextColor(widget.item);
    final name = StroopColors.getName(widget.item);
    final symbol = StroopColors.getSymbol(widget.item);

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 90),
      child: Container(
        constraints: const BoxConstraints(minHeight: 90),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            splashColor: Colors.black.withValues(alpha: 0.15),
            highlightColor: Colors.transparent,
            onHighlightChanged: (pressed) {
              if (mounted) setState(() => _isPressed = pressed);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.s16,
                vertical: AppTheme.s16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.showColorBlindSymbol) ...[
                    Text(
                      symbol,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: textColor,
                    ),
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
