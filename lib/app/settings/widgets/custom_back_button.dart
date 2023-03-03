import 'package:flutter/material.dart';

Widget customBackButton(BuildContext context) {
  return Material(
    color: const Color(0xFFF8F8F8),
    borderRadius: BorderRadius.circular(12),
    child: Ink(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 24,
            color: Color(0xFF797979),
          ),
        ),
      ),
    ),
  );
}
