import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pakket/core/constants/color.dart';

void showBlurAlertDialog(
  BuildContext context,
  String text1,
  String text2,
  VoidCallback onRetry,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    pageBuilder:
        (
          BuildContext buildContext,
          Animation animation,
          Animation secondaryAnimation,
        ) {
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
                    text1 == "Deliverable"
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: CustomColors.baseColor,
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: CustomColors.baseColor,
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 10),
                    Text(
                      text1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      text2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 20),

                    /// Enable Location Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: CustomColors.baseColor,
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await Geolocator.openLocationSettings();
                        onRetry(); // Trigger location fetch again
                      },
                      child: const Text('Enable Location'),
                    ),

                    const SizedBox(height: 20),

                    /// Close Button
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
  );
}
