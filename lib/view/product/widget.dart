 import 'package:flutter/material.dart';
import 'package:pakket/core/constants/color.dart';

PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColors.scaffoldBgClr,
      title: const Text(
        'Product detail',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
  