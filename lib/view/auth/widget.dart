import 'package:flutter/material.dart';
import 'package:pakket/core/constants/color.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final bool isPassword;
  final TextInputType? keyboardtype;
  final bool isPasswordVisible;
  final VoidCallback? onVisibilityToggle;
  final Widget? suffixIcon;
  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    required this.validator,
    this.keyboardtype,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onVisibilityToggle,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        keyboardType: keyboardtype,
        controller: controller,
        obscureText: isPassword ? !isPasswordVisible : false,
        validator: validator,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.grey[600]),
          hintText: hint,
          filled: true,
          fillColor: CustomColors.baseContainer,
          suffixIcon:
              suffixIcon ??
              (isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: onVisibilityToggle,
                    )
                  : null),
          border: _outlineBorder(),
          enabledBorder: _outlineBorder(),
          focusedBorder: _outlineBorder(width: 2.5),
        ),
      ),
    );
  }

  OutlineInputBorder _outlineBorder({double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: CustomColors.baseColor, width: width),
    );
  }
}
