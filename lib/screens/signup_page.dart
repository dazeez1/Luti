import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _phoneNumberController =
      TextEditingController(); // Controller for phone number

  @override
  void dispose() {
    _phoneNumberController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, // Ensure the screen resizes to avoid the keyboard
      appBar: AppBar(
        title: Center(
          child: Text('Get Started'),
        ),
        backgroundColor: Colors.transparent, // Make app bar transparent
        elevation: 0, // Remove shadow
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Country/Region',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: 'Rwanda (+250)',
                items: <String>[
                  'Rwanda (+250)',
                  'Nigeria (+234)',
                  'Other Country'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  // Handle the change
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Phone number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _phoneNumberController, // Assign the controller
                decoration: InputDecoration(
                  hintText: 'phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone, // Set keyboard type to phone
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'We will contact you via call or text to verify your number.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              Text(
                'Please note that standard message and data rates apply.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (_formKey.currentState!.validate()) {
                    // Navigate to the AdditionalDetailsPage
                    Navigator.pushNamed(context, '/additional-details');
                  }
                },
                child: Text('Sign Up'),
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
                    // Navigate to login page
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text('Have an account? Login'),
                ),
              ),
              SizedBox(
                  height:
                      20), // Add space before the "or continue with" section
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
      ),
    );
  }
}
