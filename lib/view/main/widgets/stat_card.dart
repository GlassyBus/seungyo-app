import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final int value;

  const StatCard({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF656A77),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: 'KBO',
              letterSpacing: -0.03,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Color(0xFF09004C),
              fontSize: 32,
              fontWeight: FontWeight.w700,
              fontFamily: 'KBO',
              letterSpacing: -0.02,
            ),
          ),
        ],
      ),
    );
  }
}
