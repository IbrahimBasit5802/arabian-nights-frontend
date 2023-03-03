import 'package:flutter/material.dart';

class SettingListTile extends StatelessWidget {
  final GestureTapCallback onTap;
  final String title;
  final Color iconBackground;
  final Color iconForeground;
  final IconData icon;
  const SettingListTile({
    Key? key,
    required this.onTap,
    required this.title,
    required this.iconBackground,
    this.iconForeground = Colors.white,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 30),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: const Color(0xFFFAFAFA),
        child: Ink(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                // color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconForeground,
                    ),
                  ),
                  const SizedBox(width: 25),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
