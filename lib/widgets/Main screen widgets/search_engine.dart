import 'package:flutter/material.dart';

import '../../const.dart';

Center searchEngine({
  required TextEditingController controller,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(15.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: 60,
            width: constraints.maxWidth / 1.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: mainColorForWeb,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
              child: Row(
                children: [
                 const Expanded(
                  flex: 1,
                    child:  Icon(
                      Icons.search,
                      color: iconColor,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 13),
                      child: SizedBox(
                        width: constraints.maxWidth / 2,
                        child: TextFormField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: iconColor),
                            hintText:
                                'Search for cars by brand, model, plate number, date or customer name',
                          ),
                          style: const TextStyle(color: iconColor),
                        ),
                      ),
                    ),
                  ),
                  // const Spacer(),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () {
                        controller.clear();
                      },
                      icon: const Icon(
                        Icons.close,
                        color: iconColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
