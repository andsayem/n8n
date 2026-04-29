import 'package:flutter/material.dart';
import 'package:n8n_manager/core/utils/app_colors.dart';
import 'package:n8n_manager/core/utils/app_sizes.dart';
import 'package:n8n_manager/core/utils/customtext.dart';
 

class CustomOutlineButton extends StatelessWidget {
  const CustomOutlineButton({
    super.key,
    this.text,
    this.textColor,
    this.backgroundColor,
    this.icon,
    this.borderColor,
    this.containerWidth,
    this.containerPadding,
    required this.onPressed,
    this.containerHeight,
    this.borderRadius,
  });

  final String? text;
  final Color? textColor;
  final Widget? icon;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? containerWidth, containerHeight;
  final EdgeInsetsGeometry? containerPadding;
  final VoidCallback onPressed;
  final Radius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(100),
      color: backgroundColor ?? Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        splashColor: Colors.white.withValues(alpha: 0.5),
        onTap: onPressed,
        child: Container(
          width: containerWidth,
          height: containerHeight,
          padding:
              containerPadding ??
              EdgeInsets.symmetric(
                vertical: getHeight(17),
                horizontal: getWidth(16),
              ),
          decoration: BoxDecoration(
            borderRadius: borderRadius != null
                ? BorderRadius.all(borderRadius!)
                : BorderRadius.circular(100),
            border: Border.all(color: borderColor ?? AppColors.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                const SizedBox(),
                SizedBox(
                  height: getHeight(23),
                  width: getWidth(23),
                  child: icon!,
                ),
              ],
              // SizedBox(
              //   width: getWidth(12),
              // ),
              CustomText(
                text: text ?? '',
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
