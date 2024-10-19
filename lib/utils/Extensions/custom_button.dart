import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final void Function() onTap;
  final String buttonText;
  final String? startText;
  final bool isShowBorder;
  final Color? color;
  final double? fontSize;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final double? radius;
  final double? height;

  const CustomButton(
      {required this.onTap,
      required this.buttonText,
      this.startText,
      this.radius,
      this.height,
      this.color,
      this.fontSize,
      this.fontFamily,
      this.fontWeight,
      this.isShowBorder = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: !isShowBorder
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.transparent,
                spreadRadius: 1,
                blurRadius: 7,
                offset: const Offset(0, 1))
          ],
          borderRadius: BorderRadius.circular(radius ?? 25),
          border: Border.all(
              color: isShowBorder ? Colors.grey : Colors.transparent),
          color: !isShowBorder
              ? color ?? Theme.of(context).primaryColor
              : Colors.transparent),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
        child: startText == null
            ? Text(
                buttonText,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    startText!,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    buttonText,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
