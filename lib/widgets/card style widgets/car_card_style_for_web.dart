import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../const.dart';
import '../../models/job_card_model.dart';
import 'package:auto_size_text/auto_size_text.dart';

Widget carCardStyleForMWeb(
    {required controller,
    required listName,
    required Color color,
    required String status}) {
  return LayoutBuilder(builder: (context, constraints) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            constraints.maxWidth <= 900 && constraints.maxWidth > 700
                ? 3
                : constraints.maxWidth <= 700
                    ? 2
                    : 4,
        // crossAxisSpacing: 10,
        // mainAxisSpacing: 10,
        childAspectRatio: 1, // تعديل نسبة العرض إلى الارتفاع
      ),
      itemCount: listName.length,
      shrinkWrap: true,
      itemBuilder: (context, i) {
        var carCard = listName[i];
        List<String> carImages = [];

        for (var item in carCard['car_images']) {
          try {
            carImages.add(item.toString());
          } catch (e) {
            // Handle the exception, or skip the item if necessary
          }
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: mainColorForWeb,
          ),
          child: InkWell(
            onTap: () {
              Get.toNamed(
                '/cardDetailsScreenForWeb',
                arguments: JobCardModel(
                    carImages: carImages,
                    customerSignature: carCard['customer_signature'],
                    carBrand: carCard['car_brand'],
                    carMileage: carCard['car_mileage'],
                    carModel: carCard['car_model'],
                    chassisNumber: carCard['chassis_number'],
                    color: carCard['color'],
                    customerName: carCard['customer_name'],
                    date: carCard['date'],
                    emailAddress: carCard['email_address'],
                    fuelAmount: carCard['fuel_amount'],
                    phoneNumber: carCard['phone_number'],
                    plateNumber: carCard['plate_number'],
                    comments: carCard['comments'],
                    docID: carCard.id,
                    carVideo: carCard['car_video'],
                    status: carCard['status']),
                // transition: Transition.leftToRight
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    width: constraints.maxWidth,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        // color: Color.fromARGB(255, 250, 177, 177),
                        // color: Color(0xffA1D6B2),
                        color: Colors.black),
                    child: Center(
                      child: AutoSizeText(
                        overflow: TextOverflow.ellipsis,
                        // '${carCard['customer_name']}',
                        '${carCard['car_brand']}'.toUpperCase(),
                        // maxLines: 2,
                        style: GoogleFonts.fredoka(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.model_training,
                              color: secColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            AutoSizeText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              ' ${carCard['car_model']}',
                              style: GoogleFonts.fredoka(
                                color: Colors.black54,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: secColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            AutoSizeText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              ' ${carCard['customer_name']}',
                              style: GoogleFonts.fredoka(
                                color: Colors.black54,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.pin,
                              color: secColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            AutoSizeText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              ' ${carCard['plate_number']}',
                              style: GoogleFonts.fredoka(
                                color: Colors.black54,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              color: secColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            AutoSizeText(
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              ' ${carCard['date']}',
                              style: GoogleFonts.fredoka(
                                color: secColor,
                                fontSize: 17,
                              ),
                            ),
                          ],
                        ),
                        // const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: AutoSizeText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                ' $status',
                                style: GoogleFonts.fredoka(
                                  color: color,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            IconTheme(
                              data: const IconThemeData(size: 20),
                              child: IconButton(
                                onPressed: () {
                                  controller.shareToSocialMedia(
                                    'Dear ${carCard['customer_name']},\n\nWe are pleased to inform you that we have received your car. Here are its details:\n\nBrand & Model: ${carCard['car_brand']}, ${carCard['car_model']}\nPlate:  ${carCard['plate_number']}\nMileage: ${carCard['car_mileage']} km\nChassis No.: ${carCard['chassis_number']}\nColor:  ${carCard['color']}\nReceived on: ${carCard['date']}\nShould you have any queries, please do not hesitate to reach out. Thank you for trusting us with your vehicle.\n\nWarm regards,\nCompass Automatic Gear',
                                  );
                                },
                                icon: Icon(
                                  Icons.share,
                                  color: mainColor,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  });
}
