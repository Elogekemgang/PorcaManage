import 'package:flutter/material.dart';
import '../../customers/colors.dart';

class CustomInputAuth extends StatelessWidget {
  final String label;
  final String? hintext;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final String? Function(void)? onChanged;


  const CustomInputAuth({
    super.key,
    required this.label,
    this.hintext,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintext,
        prefixIcon: Icon(prefixIcon,color: AppColors.primary,),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}