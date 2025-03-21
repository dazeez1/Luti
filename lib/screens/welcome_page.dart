import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C3E50), // Set the background color to #2C3E50
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the column vertically
          children: <Widget>[
            // Logo
            Image.asset(
              'assets/logo.png', // Path to your logo image
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 100,
                ); // Display an error icon if the image fails to load
              },
            ),
            SizedBox(height: 20), // Reduced space between logo and button
            // Get Started Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the Signup Page
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 50, 48, 48),
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
