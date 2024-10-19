import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:resturant_delivery_boy/provider/language_provider.dart';

// class CustomTextField extends StatefulWidget {
//   final String hintText;
//   final TextEditingController controller;
//   final FocusNode? focusNode;
//   final FocusNode? nextFocus;
//   final TextInputType inputType;
//   final TextInputAction inputAction;
//   final Color? fillColor;
//   final int maxLines;
//   final bool isPassword;
//   final bool isCountryPicker;
//   final bool isShowBorder;
//   final bool isIcon;
//   final bool isShowSuffixIcon;
//   final bool isShowPrefixIcon;
//   final void Function() onTap;
//   final String? suffixIconUrl;
//   final String? prefixIconUrl;
//   final bool isSearch;
//   // final LanguageProvider languageProvider;

//   const CustomTextField({
//     Key? key,
//     // this.languageProvider
//     this.hintText = '',
//     required this.controller,
//     this.focusNode,
//     this.nextFocus,
//     this.inputType = TextInputType.text,
//     this.inputAction = TextInputAction.next,
//     this.fillColor,
//     this.maxLines = 1,
//     this.isPassword = false,
//     this.isCountryPicker = false,
//     this.isShowBorder = false,
//     this.isIcon = false,
//     this.isShowSuffixIcon = false,
//     this.isShowPrefixIcon = false,
//     required this.onTap,
//     this.suffixIconUrl,
//     this.prefixIconUrl,
//     this.isSearch = false,
//   }) : super(key: key);

//   @override
//   _CustomTextFieldState createState() => _CustomTextFieldState();
// }

// class _CustomTextFieldState extends State<CustomTextField> {
//   bool _obscureText = true;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           borderRadius:
//               BorderRadius.circular(Dimensions.PADDING_SIZE_EXTRA_SMALL),
//           color: Theme.of(context).cardColor,
//           border: Border.all(
//               color: widget.isShowBorder
//                   ? ColorResources.colorMap[200]!
//                   : Colors.transparent)),
//       child: TextField(
//         maxLines: widget.maxLines,
//         controller: widget.controller,
//         focusNode: widget.focusNode,
//         style: Theme.of(context).textTheme.headline2?.copyWith(
//             color: Theme.of(context).highlightColor,
//             fontSize: Dimensions.FONT_SIZE_LARGE),
//         textInputAction: widget.inputAction,
//         keyboardType: widget.inputType,

//         cursorColor: ColorResources.COLOR_PRIMARY,
//         //onChanged: widget.isSearch ? widget.languageProvider.searchLanguage : null,
//         obscureText: widget.isPassword ? _obscureText : false,
//         decoration: InputDecoration(
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.0),
//             borderSide: const BorderSide(style: BorderStyle.none, width: 0),
//           ),
//           isDense: true,
//           hintText: widget.hintText,
//           fillColor: widget.fillColor ?? Theme.of(context).cardColor,
//           hintStyle: Theme.of(context).textTheme.headline2?.copyWith(
//               fontSize: Dimensions.FONT_SIZE_SMALL,
//               color: ColorResources.COLOR_GREY_CHATEAU),
//           filled: true,
//           prefixIcon: widget.isShowPrefixIcon
//               ? Padding(
//                   padding: const EdgeInsets.only(
//                       left: Dimensions.PADDING_SIZE_LARGE,
//                       right: Dimensions.PADDING_SIZE_SMALL),
//                   child: Image.asset(widget.prefixIconUrl!),
//                 )
//               : const SizedBox.shrink(),
//           prefixIconConstraints:
//               const BoxConstraints(minWidth: 23, maxHeight: 20),
//           suffixIcon: widget.isShowSuffixIcon
//               ? widget.isPassword
//                   ? IconButton(
//                       splashColor: ColorResources.COLOR_WHITE,
//                       icon: Icon(
//                           _obscureText
//                               ? Icons.visibility_sharp
//                               : Icons.visibility_off,
//                           color: Theme.of(context).primaryColor),
//                       onPressed: _toggle)
//                   : widget.isIcon
//                       ? Padding(
//                           padding: const EdgeInsets.only(
//                               left: Dimensions.PADDING_SIZE_LARGE,
//                               right: Dimensions.PADDING_SIZE_SMALL),
//                           child: Image.asset(
//                             widget.suffixIconUrl!,
//                             width: 15,
//                             height: 15,
//                           ),
//                         )
//                       : null
//               : null,
//         ),
//         onTap: widget.onTap,
//         onSubmitted: (text) => widget.nextFocus != null
//             ? FocusScope.of(context).requestFocus(widget.nextFocus)
//             : null,
//       ),
//     );
//   }

//   void _toggle() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }
// }

class MainTextField extends StatefulWidget {
  BuildContext? context;
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool isShowSuffixIcon;

  final Function(String? value)? onSave;
  final FormFieldValidator<String>? validator;
  final Function(String? value)? onChanged;
  final bool? isEnabled;
  final bool? obscureText;
  final bool? isPassword;
  final TextInputType? inputType;
  MainTextField(
      {Key? key,
      this.validator,
      this.controller,
      this.labelText,
      this.hintText,
      this.prefixIcon,
      this.onSave,
      this.onChanged,
      this.isEnabled,
      this.obscureText,
      this.isPassword,
      required this.isShowSuffixIcon,
      this.inputType})
      : super(key: key);

  @override
  State<MainTextField> createState() => _MainTextFieldState();
}

class _MainTextFieldState extends State<MainTextField> {
  bool isObscure = false;
  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText ?? false;
  }

  void _toggle() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      // width: kIsWeb ? 354.spMin : 354.w,
      child: TextFormField(
        controller: widget.controller,
        onSaved: widget.onSave,
        readOnly: widget.isEnabled == false,
        onChanged: widget.onChanged,
        validator: widget.validator,
        obscureText: (isObscure && (widget.isPassword ?? false)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.right,
        keyboardType: widget.inputType,
        inputFormatters: [
          RemoveSpaceFromTheBeginig(),
        ],
        style:
            TextStyle(fontSize: 18, color: Colors.white, locale: Locale('ar')),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.always,
          label: Text(widget.labelText ?? ""),
          prefixIcon: widget.prefixIcon,

          // labelText: labelText,
          labelStyle: Theme.of(context!).textTheme.displayMedium!.copyWith(
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 13,
          ),
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
                fontSize: 18,
                color: Colors.white,
              ),

          suffixIcon: widget.isShowSuffixIcon
              ? IconButton(
                  splashColor: Colors.white,
                  icon: Icon(
                      isObscure ? Icons.visibility_sharp : Icons.visibility_off,
                      color: Color.fromARGB(255, 90, 88, 92)),
                  onPressed: _toggle)
              : null,
          border: widget.isEnabled == false
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Color(0xffD9D9D9),
                  ),
                ),
          focusedBorder: widget.isEnabled == false
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Color(0xffD9D9D9),
                  ),
                ),
          enabledBorder: widget.isEnabled == false
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Color(0xffD9D9D9),
                  ),
                ),
          errorBorder: widget.isEnabled == false
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
// Widget MainTextFielde({
//   BuildContext? context,
//   TextEditingController? controller,
//   String? labelText,
//   String? hintText,
//   Widget? prefixIcon,
//   Function(String? value)? onSave,
//   final FormFieldValidator<String>? validator,
//   Function(String? value)? onChanged,
//   required bool isEnabled,
// }) {
//   return SizedBox(
//     // height: kIsWeb ? 44.spMin : 44.h,
//     // width: kIsWeb ? 354.spMin : 354.w,
//     child: TextFormField(
//       controller: controller,
//       onSaved: onSave,
//       readOnly: !isEnabled,
//       onChanged: onChanged,
//       validator: validator,
//       inputFormatters: [
//         RemoveSpaceFromTheBeginig(),
//       ],
//       style: TextStyle(
//         fontSize: 18.sp,
//       ),
//       decoration: InputDecoration(
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         label: Text(labelText ?? ""),
//         prefixIcon: prefixIcon,

//         // labelText: labelText,
//         labelStyle: Theme.of(context!).textTheme.displayMedium!.copyWith(
//               fontSize: 15.sp,
//               color: const Color(0xff333333),
//               letterSpacing: 1.5,
//             ),
//         contentPadding: EdgeInsets.symmetric(
//           vertical: ScreenUtil().setHeight(0),
//           horizontal: ScreenUtil().setWidth(13),
//         ),
//         hintText: hintText,
//         hintStyle: Theme.of(context).textTheme.displaySmall!.copyWith(
//               fontSize: 12.sp,
//               color: const Color(0xffD9D9D9),
//             ),

//                suffixIcon: isShowSuffixIcon
//               ? isPassword
//                   ? IconButton(
//                       splashColor: ColorResources.COLOR_WHITE,
//                       icon: Icon(
//                           _obscureText
//                               ? Icons.visibility_sharp
//                               : Icons.visibility_off,
//                           color: Theme.of(context).primaryColor),
//                       onPressed: _toggle),
//         border: !isEnabled
//             ? InputBorder.none
//             : OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//                 borderSide: BorderSide(
//                   color: Color(0xffD9D9D9),
//                 ),
//               ),
//         focusedBorder: !isEnabled
//             ? InputBorder.none
//             : OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//                 borderSide: BorderSide(
//                   color: Color(0xffD9D9D9),
//                 ),
//               ),
//         enabledBorder: !isEnabled
//             ? InputBorder.none
//             : OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//                 borderSide: BorderSide(
//                   color: Color(0xffD9D9D9),
//                 ),
//               ),
//         errorBorder: !isEnabled
//             ? InputBorder.none
//             : OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(16.r),
//                 borderSide: BorderSide(
//                   color: Colors.red,
//                   width: 1.w,
//                 ),
//               ),
//       ),
//     ),
//   );

// }

class RemoveSpaceFromTheBeginig extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith(' ')) {
      // If the new value starts with a space, remove it
      return TextEditingValue(
        text: newValue.text.trimLeft(),
        selection: TextSelection.fromPosition(
          TextPosition(offset: newValue.text.trimLeft().length),
        ),
      );
    }
    return newValue;
  }
}

Widget buildTextField(
    {required title, required TextEditingController textController}) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: TextField(
      controller: textController,
      textInputAction: TextInputAction.done,
      style: TextStyle(color: Color(0xff242123)),
      decoration: InputDecoration(
        hintText: title,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabled: false,
      ),
    ),
  );
}
