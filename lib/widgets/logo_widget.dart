import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double height;
  final double width;
  final bool showProductName;
  final double? productNameFontSize;

  const LogoWidget({
    super.key, 
    this.height = 40, 
    this.width = 40,
    this.showProductName = true,
    this.productNameFontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: height,
          width: width,
          fit: BoxFit.contain,
        ),
        if (showProductName) ...[
          const SizedBox(height: 2),
          Text(
            'Isovia Load Board',
            style: TextStyle(
              fontSize: productNameFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
