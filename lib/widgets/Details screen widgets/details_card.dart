import 'package:flutter/material.dart';

import '../../const.dart';

Widget cardDetails(
    {required String title,
    required IconData icon,
    required String controller}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: secColor,
                    size: 35,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      SelectableText(
                        title,
                        style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
                child: SelectableText(
                  controller,
                  style: const TextStyle(fontSize: 14),
                ))
          ],
        ),
        const SizedBox(
          height: 25,
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
        ),
      ],
    ),
  );
}
