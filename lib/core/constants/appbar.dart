import 'package:flutter/material.dart';
import 'package:pakket/core/constants/color.dart';

AppBar buildGroceryAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: CustomColors.scaffoldBgClr,
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.pop(context),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // Navigator.of(context).push(
          //   MaterialPageRoute(builder: (context) => SearchDetails()),
          // );
        },
      ),
      const SizedBox(width: 10),
    ],
  );
}
