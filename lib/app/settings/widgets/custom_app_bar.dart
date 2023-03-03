import 'package:flutter/material.dart';

import 'custom_back_button.dart';

Widget customAppBar(
    {required BuildContext context, required String title, Widget? action}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        customBackButton(context),
        // const SizedBox(width: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        if (action != null) ...[
          action,
        ] else ...[
          const SizedBox(
            width: 48,
            height: 48,
          ),
        ]
      ],
    ),
  );
}
