import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

class InAppReviewDemo extends StatelessWidget {
  const InAppReviewDemo({super.key});

  Future<void> _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      // Tries to open in-app review popup
      inAppReview.requestReview();
    } else {
      // If not available, open the store listing
      inAppReview.openStoreListing(
        appStoreId: 'YOUR_IOS_APPSTORE_ID', // Only for iOS
        microsoftStoreId: 'YOUR_WINDOWS_STORE_ID', // If needed
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Us'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rate_rounded,
                size: 100,
                color: Colors.amber,
              ),
              const SizedBox(height: 30),
              const Text(
                'Enjoying our App?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please take a moment to rate us in the store!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _rateApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Rate Us',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
