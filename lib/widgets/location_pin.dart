import 'package:flutter/material.dart';

class LocationPin extends StatelessWidget {
  const LocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: 48,
      color: Colors.redAccent,
    );
  }
}
