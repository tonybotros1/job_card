// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import '../../const.dart';
// import '../../widgets/styles/wavy_style.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: mainColorForWeb,
//         toolbarHeight: kIsWeb ? 75 : null,
//         title: const Flexible(
//           child: AutoSizeText(
//             'Compass Automatic Gear',
//             style: TextStyle(color: iconColor),
//           ),
//         ),
//       ),
//       body: LayoutBuilder(builder: (context, constraints) {
//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                       flex: 2,
//                       child: Container(
//                         margin: const EdgeInsets.fromLTRB(25, 25, 12.5, 25),
//                         constraints: BoxConstraints(
//                             maxWidth: constraints.maxWidth,
//                             maxHeight: constraints.maxHeight / 2),
//                         decoration: BoxDecoration(
//                             color: mainColorForWeb,
//                             borderRadius: BorderRadius.circular(8)),
//                         // child: ,
//                       )),
//                   Expanded(
//                       flex: 1,
//                       child: Container(
//                         margin: const EdgeInsets.fromLTRB(12.5, 25, 25, 25),
//                         constraints: BoxConstraints(
//                             maxWidth: constraints.maxWidth,
//                             maxHeight: constraints.maxHeight / 2),
//                         decoration: BoxDecoration(
//                             color: mainColorForWeb,
//                             borderRadius: BorderRadius.circular(8)),
//                       )),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   customContainerCard(
//                     constraints: constraints,
//                     color: [
//                       const Color(0xFFE43A72),
//                       const Color.fromARGB(255, 247, 135, 165),
//                     ],
//                   ),
//                   customContainerCard(
//                     constraints: constraints,
//                     color: [
//                       const Color(0xFF655DF5),
//                       const Color.fromARGB(255, 174, 166, 252),
//                     ],
//                     wave: Positioned.fill(
//                       child: CustomPaint(
//                         painter: WavePainter(),
//                       ),
//                     ),
//                   ),
//                   customContainerCard(constraints: constraints, color: [
//                     const Color(0xFF44C7F5),
//                     const Color.fromARGB(255, 154, 224, 245),
//                   ]),
//                   customContainerCard(constraints: constraints, color: [
//                     const Color(0xFFFFA63D),
//                     const Color.fromARGB(255, 253, 215, 169),
//                   ]),
//                 ],
//               ),
//               const Row()
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget customContainerCard(
//       {required BoxConstraints constraints, required List<Color> color, wave}) {
//     return Stack(
//       children: [
//         Container(
//           // margin: const EdgeInsets.fromLTRB(25, 25, 25, 12.5),
//           constraints: BoxConstraints(
//               maxWidth: constraints.maxWidth / 5,
//               maxHeight: constraints.maxHeight / 3),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             gradient: LinearGradient(
//               colors: color,
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         wave ?? const SizedBox()
//       ],
//     );
//   }
// }
