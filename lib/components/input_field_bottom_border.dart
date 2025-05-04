import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputFieldBottomBorder extends StatelessWidget {
  final TextInputType? keyboardType;
  final String? prefixText;
  final Widget? suffixIcon;
  final Function()? onTap;
  final TextEditingController controller;
  final bool isReadOnly;
  final Function(String)? onChange;
  final double? fontSize;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormats;
  final FocusNode? focusNode;
  final Color borderColor;
  const InputFieldBottomBorder(
      {super.key,
      this.keyboardType,
      this.prefixText,
      this.suffixIcon,
      this.onTap,
      required this.controller,
      required this.isReadOnly,
      this.onChange,
      this.fontSize,
      this.textAlign = TextAlign.start,
      this.inputFormats,
      this.focusNode,
      this.borderColor = const Color(0xFFEFEFEF)});

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: TextStyle(
        fontSize: fontSize ?? 25,
      ),
      onChanged: onChange,
      focusNode: focusNode,
      readOnly: isReadOnly,
      controller: controller,
      textAlign: textAlign,
      onTap: onTap,
      textAlignVertical: TextAlignVertical.center,
      keyboardType: keyboardType,
      inputFormatters: inputFormats,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontSize: fontSize ?? 25,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF456EFE)),
        ),
      ),
    );
  }
}
