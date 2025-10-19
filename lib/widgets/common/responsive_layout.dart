import 'package:flutter/material.dart';
import 'package:edu_sync/utils/responsive.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context) && maxWidth != null) {
      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: child,
        ),
      );
    }
    return child;
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: Responsive.gridColumns(context),
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: children,
    );
  }
}
