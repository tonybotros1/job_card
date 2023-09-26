import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:job_card/const.dart';
import 'package:job_card/controllers/all_works_screen_controller.dart';

import '../models/job_card_model.dart';
import 'edit_card_screen.dart';
import 'job_card_screen.dart';

class AllWorksScreen extends StatelessWidget {
  AllWorksScreen({super.key});
  final AllWorksController allWorksController = Get.put(AllWorksController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('All Cards'),
          centerTitle: true,
          backgroundColor: mainColor,
        ),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: mainColor,
          onPressed: () {},
          child: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => JobCardScreen());
            },
          ),
        ),
        body: GetX(
            init: AllWorksController(),
            builder: (controller) {
              if (controller.carCards.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: mainColor,
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: controller.carCards.length,
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      var carCard = controller.carCards[i];
                      return Card(
                        elevation: 20,
                        child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => EditCardScreen(),
                                    arguments: JobCardModel(
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
                                      plateNumber: carCard['phone_number'],
                                    ));
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(5),
                                title: Text(
                                  '${carCard['customer_name']}',
                                  style: fontStyle,
                                ),
                                subtitle: Text('${carCard['date']}'),
                                trailing: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    FittedBox(
                                      child: SizedBox(
                                        child: Text(
                                          '${carCard['car_brand']}  ${carCard['car_model']}',
                                          style: fontStyle,
                                        ),
                                      ),
                                    ),
                                    FittedBox(
                                      child: SizedBox(
                                        child: Text(
                                          '${carCard['plate_number']}',
                                          style: fontStyle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      );
                    });
              }
            }));
  }
}
