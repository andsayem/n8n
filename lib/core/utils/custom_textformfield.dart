import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:n8n_manager/core/utils/app_colors.dart';
import 'package:n8n_manager/core/utils/app_sizer.dart';
 
class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    this.textController,
    this.width = double.maxFinite,
    this.headerTitle,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.fillColor,
    this.prefixIcon,
    this.formValidator,
    this.suffixWidget,
    this.maxLines,
    this.borderSide,
    this.borderRadius,
    this.hintTextColor,
    this.hintTextFontWeight,
    this.headerTextColor,
    this.textColor,
    this.headerFontWeight,
    this.fontWeight,
    this.prefixIconColor,
    this.isReadOnly,
    this.fontSize,
    this.isObsecure,
    this.inputFormatters,
    this.onPressed,
    this.onChanged,
    this.headerfontSize,
  });

  final TextEditingController? textController;
  final double width;
  final String? headerTitle;
  final String? hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color? fillColor;
  final FormFieldValidator<String>? formValidator;
  final Widget? suffixWidget;
  final int? maxLines;
  final IconData? prefixIcon;
  final BorderSide? borderSide;
  final double? borderRadius;
  final Color? hintTextColor;
  final Color? textColor;
  final Color? headerTextColor;
  final FontWeight? hintTextFontWeight;
  final FontWeight? headerFontWeight;
  final FontWeight? fontWeight;
  final Color? prefixIconColor;
  final bool? isReadOnly;
  final double? fontSize;
  final double? headerfontSize;
  final bool? isObsecure;
  final void Function(dynamic)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final void Function()? onPressed;

  OutlineInputBorder _outlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(
        borderRadius != null ? borderRadius! : 10,
      ),
      borderSide: borderSide != null
          ? borderSide!
          : BorderSide(width: 1.w, color: Color(0xFFD1D1D1)),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: hintTextColor ?? const Color(0xFF6B6B6B),
        fontSize: (fontSize ?? 14).sp,
        fontWeight: hintTextFontWeight ?? FontWeight.w400,
      ),
      fillColor: fillColor ?? AppColors.textWhite,
      filled: true,
      border: _outlineInputBorder(),
      focusedBorder: _outlineInputBorder(),
      enabledBorder: _outlineInputBorder(),
      disabledBorder: _outlineInputBorder(),
      errorBorder: _outlineInputBorder(),
      focusedErrorBorder: _outlineInputBorder(),
      suffixIcon: suffixWidget,
      prefixIcon: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(
                prefixIcon,
                color: prefixIconColor ?? const Color(0xFF636F85),
                size: 22.w,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerTitle != null)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                headerTitle!,
                style: TextStyle(
                  color: headerTextColor ?? AppColors.textPrimary,
                  fontSize: (headerfontSize ?? 14).sp,
                  fontWeight: headerFontWeight ?? FontWeight.w500,
                ),
              ),
            ),
          if (headerTitle != null) SizedBox(height: 8),
          TextFormField(
            readOnly: isReadOnly ?? false,
            maxLines: maxLines ?? 1,
            onTap: onPressed,
            inputFormatters: inputFormatters,
            style: TextStyle(
              color: textColor ?? const Color(0xFF636F85),
              fontSize: (fontSize ?? 14).sp,
              fontWeight: fontWeight ?? FontWeight.w400,
            ),
            onChanged: onChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: textController,
            keyboardType: keyboardType,
            obscureText: isObsecure ?? false,
            decoration: _inputDecoration(),
            validator: formValidator,
          ),
        ],
      ),
    );
  }
}
