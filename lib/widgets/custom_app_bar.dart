import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 60,
      leading:
          automaticallyImplyLeading && onBackPressed != null
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF100F21)),
                onPressed: onBackPressed,
              )
              : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF100F21),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'KBO',
          letterSpacing: -0.02,
        ),
      ),
      centerTitle: false,
      actions: actions,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
