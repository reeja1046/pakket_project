import 'package:flutter/material.dart';
import 'package:pakket/core/constants/color.dart';
import 'package:pakket/view/profile/widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffoldBgClr,
      appBar: AppBar(
        backgroundColor: CustomColors.scaffoldBgClr,
        title: Text(
          'Back to Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Profile details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '+91-9895124725',
                      style: TextStyle(color: Color(0xFF636260)),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    Text(
                      'Your information',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 0),
              HelpCenterList(),
              SizedBox(height: 80),
              Center(child: Text('Logout')),
            ],
          ),
        ),
      ),
    );
  }
}
