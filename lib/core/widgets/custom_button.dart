import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? borderSide;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textStyle,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8.0),
            side: borderSide ?? BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: textStyle ??
              const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
