import 'package:flutter/material.dart';
import 'package:n8n_manager/core/utils/app_colors.dart';
import 'package:n8n_manager/core/utils/app_sizer.dart';
import 'package:n8n_manager/core/utils/customtext.dart';
 
class CustomAppbar extends StatelessWidget {
  final String? title;
  final Widget? icon;
  final double? fontSize;
  final Color? titleColor;
  final Color? iconColor;
  final bool centerTitle;
  final Widget? trailing;
  final Widget? leading;

  const CustomAppbar({
    super.key,
    this.title,
    this.icon,
    this.fontSize,
    this.titleColor,
    this.iconColor,
    this.centerTitle = false,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: SizedBox(
        height: 52.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasTitle)
              Align(
                alignment: centerTitle
                    ? Alignment.center
                    : Alignment.centerLeft,
                child: Padding(
                  padding: centerTitle
                      ? EdgeInsets.zero
                      : EdgeInsets.only(left: 50.w),
                  child: CustomText(
                    text: title!,
                    fontSize: fontSize ?? 18.sp,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? AppColors.textPrimary,
                  ),
                ),
              ),

            if (trailing != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: trailing!,
                ),
              ),
            if (leading != null)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: leading!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
