import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color checkColor;
  final Color inactiveColor;
  final Color labelColor;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.activeColor = const Color(0xFF09004C), // Figma: Navy Blue
    this.checkColor = Colors.white,
    this.inactiveColor = const Color(0xFFD6D9DD), // Figma: Light Gray border
    this.labelColor = const Color(0xFF100F21), // Figma: Dark text
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      splashColor: activeColor.withValues(alpha: 0.1),
      highlightColor: activeColor.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        // Added padding for better touch area and visual spacing
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: value ? activeColor : inactiveColor,
                  width: 2,
                ),
              ),
              child:
                  value ? Icon(Icons.check, size: 16, color: checkColor) : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500, // As per Figma's visual weight
              ),
            ),
          ],
        ),
      ),
    );
  }
}
