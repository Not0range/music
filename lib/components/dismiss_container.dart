import 'package:flutter/material.dart';

class DismissContainer extends StatelessWidget {
  final Widget child;

  const DismissContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
}
