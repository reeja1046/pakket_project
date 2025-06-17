import 'package:flutter/material.dart';
import 'package:pakket/controller/herobanner.dart';
import 'package:pakket/model/herobanner.dart';

Widget buildHeader(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      Row(
        children: [
          Image.asset(
            'assets/logo.png',
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          SizedBox(width: MediaQuery.of(context).size.height * 0.045),
          Image.asset(
            'assets/logo_text.png',
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Spacer(),
          Image.asset('assets/home/profileicon.png'),
        ],
      ),
      SizedBox(height: 10),
      Text(
        'Your Location',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      Row(
        children: [
          const Text(
            'PVS Green Valley, Chalakunnu, Kannur',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          SizedBox(width: 5),
          Image.asset('assets/home/location.png'),
        ],
      ),
      const SizedBox(height: 10),
    ],
  );
}

Widget showScrollCard() {
  return FutureBuilder<List<HeroBanner>>(
    future: fetchHeroBanners(),
    builder: (context, snapshot) {
      print(snapshot);
      if (snapshot.connectionState == ConnectionState.waiting) {
        return SizedBox(
          height: 240,
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (snapshot.hasError) {
        return SizedBox(
          height: 240,
          child: Center(child: Text('Failed to load banners')),
        );
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return SizedBox(
          height: 240,
          child: Center(child: Text('No banners available')),
        );
      }

      return scrollCard(context, snapshot.data!);
    },
  );
}

Widget scrollCard(BuildContext context, List<HeroBanner> banners) {
  final PageController controller = PageController(
    initialPage: 1,
    viewportFraction: 0.85,
  );

  return SizedBox(
    height: 240,
    child: PageView.builder(
      controller: controller,
      itemCount: banners.length,
      itemBuilder: (context, index) {
        final banner = banners[index];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              banner.url,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Icon(Icons.error)),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    ),
  );
}

Widget buildCategoryHeader(
  BuildContext context,
  String title,
  VoidCallback onSeeAllPressed,
) {
  double screenWidth = MediaQuery.of(context).size.width;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.045, // Responsive font size
          fontWeight: FontWeight.bold,
        ),
      ),
      GestureDetector(
        onTap: onSeeAllPressed,
        child: Text(
          'See All',
          style: TextStyle(
            fontSize: screenWidth * 0.035, // Responsive font size
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
