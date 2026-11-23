import 'package:flutter/material.dart';
import 'package:my_porfolio/constants/colors.dart';

class CustomTextfield extends StatefulWidget {
  const CustomTextfield({
    super.key,
    this.controller,
    this.maxLine = 1,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final int maxLine;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      maxLines: widget.isPassword ? 1 : widget.maxLine,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: const TextStyle(
        color: CustomColor.whitePrimary,
        fontSize: 14.5,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(16),
        filled: true,
        fillColor: CustomColor.textFieldBg,
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: CustomColor.whiteSecondary),
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: CustomColor.hintDark),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: CustomColor.yellowSecondary,
                size: 19,
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: _obscureText ? "Show Passcode" : "Hide Passcode",
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: CustomColor.whiteSecondary,
                  size: 19,
                ),
              )
            : null,
        focusedBorder: _border(CustomColor.yellowPrimary, width: 1.5),
        enabledBorder: _border(CustomColor.cardBorder),
        errorBorder: _border(CustomColor.crimsonAccent),
        focusedErrorBorder: _border(CustomColor.crimsonAccent, width: 1.5),
        border: _border(CustomColor.cardBorder),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.0}) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
      borderRadius: BorderRadius.circular(12),
    );
  }
}
