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
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, 
          children: [
            Flexible(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: secColor,
                    size: 35,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: SelectableText(
                      title,
                      style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                      textAlign: TextAlign.left, 
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText(
                    controller,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: 25,
          child: Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
        ),
      ],
    ),
  );
}
