import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensure the screen resizes to avoid the keyboard
      appBar: AppBar(
        title: Center(
          child: Text('Login'),
        ),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Email Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  TextInputType.emailAddress, // Set keyboard type to email
            ),
            SizedBox(height: 20),
            Text(
              'Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter your password',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Hide password text
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle login
              },
              child: Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xFF2C3E50), // Set button color to #2C3E50
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(5), // Set border radius to 5
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  // Navigate to signup page
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Don\'t have an account? Sign Up'),
              ),
            ),
            SizedBox(
                height: 20), // Add space before the "or continue with" section
            Center(
              child: Text(
                'or continue with',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Image.asset('assets/google.png',
                      width: 40, height: 40), // Add Google logo
                  onPressed: () {
                    // Handle Google login
                  },
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Image.asset('assets/apple.png',
                      width: 40, height: 40), // Add Apple logo
                  onPressed: () {
                    // Handle Apple login
                  },
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Image.asset('assets/facebook.png',
                      width: 40, height: 40), // Add Facebook logo
                  onPressed: () {
                    // Handle Facebook login
                  },
                ),
              ],
            ),
            SizedBox(height: 40), // Add extra space at the bottom
          ],
        ),
      ),
    );
  }
}
