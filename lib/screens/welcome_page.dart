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
            // Logo and Text in a Row
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the row horizontally
              children: <Widget>[
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
                SizedBox(width: 20), // Space between logo and text
                Text(
                  'Luti',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white, // Set text color to white
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 40), // Space between the logo/text and the button
            // Get Started Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the Signup Page
                Navigator.pushNamed(context, '/signup');
                Navigator.pushNamed(context, '/login');
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
