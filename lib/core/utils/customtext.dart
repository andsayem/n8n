import 'package:flutter/material.dart';
import 'package:n8n_manager/core/utils/app_colors.dart';
import 'package:n8n_manager/core/utils/app_sizer.dart';
 

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? letterSpacing;
  final double? height;
  final TextDecoration? textDecoration;
  final Color? textDecorationColor;

  const CustomText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.letterSpacing,
    this.height,
    this.textDecoration,
    this.textDecorationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: TextStyle(
        fontSize: fontSize?.sp,
        fontWeight: fontWeight,
        color: color ?? AppColors.textPrimary,
        letterSpacing: letterSpacing,
        height: height,
        decoration: textDecoration,
        decorationColor: textDecorationColor,
      ),
    );
  }
}
