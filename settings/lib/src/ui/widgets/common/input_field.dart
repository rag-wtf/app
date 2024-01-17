import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatelessWidget {
  const InputField({
    required this.controller,
    super.key,
    this.labelText,
    this.errorText,
    this.hintText = '',
    this.inputFormatters,
    this.textInputType,
    this.prefixIcon,
  });
  final TextEditingController controller;
  final String? labelText;
  final String? errorText;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? textInputType;
  final Widget? prefixIcon;

  static const double kdDesktopMaxContentWidth = 1150;
  static final ktsBodyRegular = GoogleFonts.openSans(
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*SizedBox(
            width: getValueForScreenType<double>(
              context: context,
              mobile: double.infinity,
              tablet: kdDesktopMaxContentWidth * 0.3,
              desktop: kdDesktopMaxContentWidth * 0.3,
            ),
            child:*/
          TextField(
            controller: controller,
            decoration: InputDecoration(
              label: labelText != null ? Text(labelText!) : null,
              //alignLabelWithHint: false,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: hintText,
              hintStyle: GoogleFonts.openSans(
                color: Colors.grey,
              ),
              //          filled: true,
              //          fillColor: kcMediumGrey,
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            obscureText: textInputType == TextInputType.none,
            obscuringCharacter: '*',
            inputFormatters: inputFormatters,
            keyboardType: textInputType,
          ),
          //),
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
      ),
    );
  }
}
