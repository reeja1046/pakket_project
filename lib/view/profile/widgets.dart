import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool?> showBlurDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String actionText,
  required IconData icon,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder: (context, _, __) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CustomColors.baseColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: CustomColors.baseColor),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        actionText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void launchPhone(String phoneNumber) async {
  final Uri url = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    Get.snackbar('Error', 'Could not launch $url');
  }
}

void launchWhatsApp(String phoneNumber) async {
  final Uri url = Uri.parse('https://wa.me/${phoneNumber.replaceAll('+', '')}');
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    Get.snackbar('Error', 'Could not launch $url');
  }
}

void launchEmail(String email) async {
  final Uri url = Uri(
    scheme: 'mailto',
    path: email,
    // You can also add subject/body if needed:
    // query: Uri.encodeFull('subject=Help&body=Hi, I need assistance...')
  );

  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error!!', 'Cannot launch email: $url');
    }
  } catch (e) {
    Get.snackbar('Error!!', 'Error launching email: $e');
  }
}

Future<void> launchExternalLink(String urlString) async {
  try {
    final Uri url = Uri.parse(urlString);

    // Validate URL scheme
    if (!['http', 'https'].contains(url.scheme)) {
      Get.snackbar('Error!!', 'Invalid URL scheme: $urlString');
      return;
    }

    final bool canLaunch = await canLaunchUrl(url);
    if (canLaunch) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error!!', 'Could not launch URL: $urlString');
      // Optional: Show a snackbar or dialog if needed
    }
  } catch (e) {
    Get.snackbar('Error!!', 'Error launching URL: $e');
  }
}
