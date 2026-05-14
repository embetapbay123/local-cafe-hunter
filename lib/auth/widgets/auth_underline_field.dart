import 'package:flutter/material.dart';

import '../../theme/cafe_theme.dart';

class AuthUnderlineField extends StatelessWidget {
  const AuthUnderlineField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? trailing;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Icon(icon, color: CafeColors.muted, size: 33),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: CafeColors.surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: CafeColors.dark.withValues(alpha: 0.12),
              ),
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              cursorColor: CafeColors.dark,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CafeColors.dark,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 10, top: 8),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CafeColors.dark, width: 1.8),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: CafeColors.dark, width: 2.6),
                ),
                suffixIcon: trailing,
              ),
              validator: validator,
            ),
          ),
        ),
      ],
    );
  }
}
