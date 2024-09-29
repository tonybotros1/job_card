// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../const.dart';
// import '../../models/job_card_model.dart';
// import '../../screens/Cards screens/card_details_screen.dart';
// import 'package:auto_size_text/auto_size_text.dart';

// Widget carCardStyleForMWeb(
//     {required controller,
//     required listName,
//     required Color color,
//     required String status}) {
//   return LayoutBuilder(builder: (context, constraints) {
//     return Column(
//       children: [
//         Container(
//           constraints: BoxConstraints(maxWidth: constraints.maxWidth),
//           color: const Color.fromARGB(255, 250, 177, 177),
//           height: 50,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               mainRowSections(title: 'Name'),
//               mainRowSections(title: 'Car'),
//               mainRowSections(title: 'Model'),
//               mainRowSections(title: 'Number'),
//               mainRowSections(title: 'Date'),
//               mainRowSections(title: 'Status'),
//               mainRowSections(title: 'Share'),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//               itemCount: listName.length,
//               shrinkWrap: true,
//               itemBuilder: (context, i) {
//                 var carCard = listName[i];
//                 List<String> carImages = [];
          
//                 for (var item in carCard['car_images']) {
//                   try {
//                     carImages.add(item.toString());
//                   } catch (e) {
//                     // Handle the exception, or skip the item if necessary
//                   }
//                 }
          
//                 return buildCelles(index: i, name: carCard['customer_name'], car: carCard['car_brand'], model: carCard['car_model'], number: carCard['plate_number'], date: carCard['date'], status: status, mileage: carCard['car_mileage'], chassisNumber: carCard['chassis_number'], color: color, controller: controller);
//               }),
//         ),
//       ],
//     );
//   });
// }

// Widget mainRowSections({required String title}) {
//   return Expanded(
//       child: Center(
//     child: AutoSizeText(title,
//         style: GoogleFonts.fredoka(color: Colors.black54, fontSize: 20)),
//   ));
// }

// Widget buildCelles(
//     {required int index,required name,required car,required model,required number,required date,required status,required mileage,required chassisNumber,required color ,required controller}) {
//   return Container(
//     color: index.isEven ? Colors.grey[200] : Colors.grey[300],
//     child: Row(
//       children: [
//         mainRowSections(title: name),
//         mainRowSections(title: car),
//         mainRowSections(title: model),
//         mainRowSections(title: number),
//         mainRowSections(title: date),
//         mainRowSections(title: status),
//         IconButton(
//           onPressed: () {
//             controller.shareToSocialMedia(
//               'Dear $name,\n\nWe are pleased to inform you that we have received your car. Here are its details:\n\nBrand & Model: $car, $model\nPlate:  $number\nMileage: $mileage km\nChassis No.: $chassisNumber\nColor:  $color\nReceived on: $date\nShould you have any queries, please do not hesitate to reach out. Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear',
//             );
//           },
//           icon: Icon(
//             Icons.share,
//             color: mainColor,
//             size: 35,
//           ),
//         )
//       ],
//     ),
//   );
// }


//           //     Container(
            
//           //   margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//           //   decoration: BoxDecoration(
//           //     borderRadius: BorderRadius.circular(8),
//           //     color: mainColorForWeb,
//           //   ),
//           //   child: InkWell(
//           //     onTap: () {
//           //       Get.to(() => CarDetailsScreen(),
//           //           arguments: JobCardModel(
//           //               carImages: carImages,
//           //               customerSignature: carCard['customer_signature'],
//           //               carBrand: carCard['car_brand'],
//           //               carMileage: carCard['car_mileage'],
//           //               carModel: carCard['car_model'],
//           //               chassisNumber: carCard['chassis_number'],
//           //               color: carCard['color'],
//           //               customerName: carCard['customer_name'],
//           //               date: carCard['date'],
//           //               emailAddress: carCard['email_address'],
//           //               fuelAmount: carCard['fuel_amount'],
//           //               phoneNumber: carCard['phone_number'],
//           //               plateNumber: carCard['plate_number'],
//           //               comments: carCard['comments'],
//           //               docID: carCard.id,
//           //               carVideo: carCard['car_video'],
//           //               status: carCard['status']),
//           //           transition: Transition.leftToRight);
//           //     },
//           //     child: Column(
//           //       children: [
//           //         Expanded(
//           //             flex: 1,
//           //             child: Container(
//           //               width: constraints.maxWidth,
//           //               decoration: const BoxDecoration(
//           //                 borderRadius: BorderRadius.only(
//           //                   topLeft: Radius.circular(8),
//           //                   topRight: Radius.circular(8),
//           //                 ),
//           //                 color: Color.fromARGB(255, 250, 177, 177),
//           //               ),
//           //               child: Center(
//           //                 child: AutoSizeText('${carCard['customer_name']}',
//           //                     maxLines: 2,
//           //                     style: GoogleFonts.fredoka(
//           //                         color: Colors.black54, fontSize: 20)),
//           //               ),
//           //             )),
//           //         Expanded(flex: 4, child: Container()),
//           //       ],
//           //     ),
//           //   ),
//           // );