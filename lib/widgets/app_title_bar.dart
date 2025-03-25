import 'package:flutter/material.dart';

class AppTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? left;
  final Widget? center;
  final Widget? right;

  const AppTitleBar({super.key, this.left, this.center, this.right});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      color: Colors.white,
      child: Row(
        children: [
          left ?? const SizedBox(width: 48),
          Expanded(child: Center(child: center)),
          right ?? const SizedBox(width: 48),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(49);
}
