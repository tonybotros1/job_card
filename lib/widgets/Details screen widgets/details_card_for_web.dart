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
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: mainColor,
                size: 35,
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SelectableText(
                      title,
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                    SelectableText(
                      controller,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                      // minLines: 1,
                    )
                  ],
                ),
              ),
            ],
          ),
          // const Divider(
          //   color: Colors.grey,
          //   thickness: 1,
          //   indent: 0,
          //   endIndent: 0,
          // ),
        ],
      ));
}

// Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Flexible(
//               flex: 2,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(
//                     icon,
//                     color: secColor,
//                     size: 35,
//                   ),
//                   const SizedBox(
//                     width: 5,
//                   ),
//                   Expanded(
//                     child: SelectableText(
//                       title,
//                       style: TextStyle(
//                           fontSize: 17,
//                           color: Colors.grey[700],
//                           fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.left,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Flexible(
//               flex: 1,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   SelectableText(
//                     controller,
//                     style: const TextStyle(fontSize: 14),
//                     textAlign: TextAlign.right,
//                     maxLines: 2,
//                   )
//                 ],
//               ),
//             )
//           ],
//         ),
//         const SizedBox(
//           height: 25,
//           child: Divider(
//             color: Colors.grey,
//             thickness: 1,
//             indent: 0,
//             endIndent: 0,
//           ),
//         ),
//       ],
//     ),
