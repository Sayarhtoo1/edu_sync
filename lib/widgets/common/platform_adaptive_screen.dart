import 'package:flutter/material.dart';
import 'package:edu_sync/utils/responsive.dart';

class PlatformAdaptiveScreen extends StatelessWidget {
  final Widget mobileScreen;
  final Widget? desktopScreen;

  const PlatformAdaptiveScreen({
    super.key,
    required this.mobileScreen,
    this.desktopScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && desktopScreen != null) {
      return desktopScreen!;
    }
    return mobileScreen;
  }
}
