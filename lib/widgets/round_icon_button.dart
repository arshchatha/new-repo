import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      color: Theme.of(context).primaryColor,
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        color: Colors.white,
      ),
    );
  }
}
