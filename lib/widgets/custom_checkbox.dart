import 'package:flutter/material.dart';
import 'package:seungyo/theme/theme.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final double size;

  const CustomCheckbox({
    Key? key,
    required this.value,
    this.onChanged,
    required this.label,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: value ? colorScheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? colorScheme.primary : AppColors.gray30,
                width: 2,
              ),
            ),
            child:
                value
                    ? Icon(
                      Icons.check,
                      color: colorScheme.onPrimary,
                      size: size * 0.7,
                    )
                    : null,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
