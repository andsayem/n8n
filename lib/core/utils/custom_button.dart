import 'package:flutter/material.dart';
import 'package:n8n_manager/core/utils/app_colors.dart';
import 'package:n8n_manager/core/utils/app_sizes.dart';
import 'package:n8n_manager/core/utils/customtext.dart';
 

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.text,
    this.textColor,
    this.backgroundColor,
    this.icon,

    this.containerWidth,
    this.containerPadding,
    required this.onPressed,
    this.containerHeight,
    this.borderRadius,
    this.boxBorder,
  });

  final String? text;
  final Color? textColor;
  final Widget? icon;
  final Color? backgroundColor;
  final double? containerWidth, containerHeight;
  final EdgeInsetsGeometry? containerPadding;
  final VoidCallback onPressed;
  final Radius? borderRadius;
  final BoxBorder? boxBorder;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(100),
      color: backgroundColor ?? AppColors.primary,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
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
                : BorderRadius.circular(4),

            border: boxBorder,
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
              SizedBox(width: getWidth(15)),
              CustomText(
                text: text ?? '',
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.textWhite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
