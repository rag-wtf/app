import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_builder/responsive_builder.dart';

class InputField extends StatelessWidget {
  const InputField({
    required this.controller,
    super.key,
    this.errorText,
    this.hintText = '',
    this.inputFormatters,
    this.textInputType,
    this.prefixIcon,
  });
  final TextEditingController controller;
  final String? errorText;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
  final Widget? prefixIcon;
  static const Color kcMediumGrey = Color(0xFF222222);
  static const Color kcLightGrey = Color(0xff989898);
  static const double kdDesktopMaxContentWidth = 1150;
  static final ktsBodyRegular = GoogleFonts.openSans(
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: getValueForScreenType<double>(
            context: context,
            mobile: double.infinity,
            tablet: kdDesktopMaxContentWidth * 0.3,
            desktop: kdDesktopMaxContentWidth * 0.3,
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.openSans(
                color: kcLightGrey,
              ),
              filled: true,
              fillColor: kcMediumGrey,
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            inputFormatters: inputFormatters,
            keyboardType: textInputType,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (errorText != null) ...[
          const Gap(5),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              errorText!,
              style: ktsBodyRegular.copyWith(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
