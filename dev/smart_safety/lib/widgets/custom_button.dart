import 'package:flutter/material.dart';

/// A reusable, theme-aware button for the entire app.
///
/// Features:
/// - Supports null onPressed (disables button)
/// - Shows loading spinner when isLoading = true
/// - Adapts to light/dark mode
/// - Fully customizable colors, size, and text
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // ✅ Nullable — standard in Flutter
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isExpanded;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed, // Can be null to disable
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;
    final bgColor = backgroundColor ?? theme.colorScheme.primary;
    final txtColor = textColor ?? Colors.white;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(txtColor),
          strokeWidth: 2,
        ),
      );
    } else {
      child = Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: txtColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return SizedBox(
      width: isExpanded ? double.infinity : width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? bgColor.withOpacity(0.6) : bgColor,
          foregroundColor: txtColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          elevation: 0,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        child: child,
      ),
    );
  }
}