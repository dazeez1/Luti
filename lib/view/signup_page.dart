import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // For dropdown selections
  String? _selectedCountry;
  String? _selectedCity;
  final List<String> _countries = ['Rwanda', 'Nigeria', 'Kenya', 'South Africa'];
  final Map<String, List<String>> _citiesByCountry = {
    'Rwanda': ['Kigali', 'Butare', 'Gisenyi', 'Ruhengeri'],
    'Nigeria': ['Lagos', 'Abuja', 'Kano', 'Port Harcourt'],
    'Kenya': ['Nairobi', 'Mombasa', 'Kisumu', 'Nakuru'],
    'South Africa': ['Cape Town', 'Johannesburg', 'Durban', 'Pretoria'],
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // 1. Create user in Firebase Authentication
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Save additional user data to Firestore
      await _saveUserDataToFirestore(userCredential.user?.uid);

      if (!mounted) return;
      Navigator.pushNamed(context, '/additional-details');
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(context, "Sign up failed: ${e.message}");
    } catch (e) {
      _showErrorSnackbar(context, "Error saving user data");
    }
  }

  Future<void> _saveUserDataToFirestore(String? userId) async {
    if (userId == null) return;

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'email': _emailController.text.trim(),
      'phone': _phoneNumberController.text.trim(),
      'bio': _bioController.text.trim(),
      'city': _selectedCity,
      'country': _selectedCountry,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Center(child: Text('Get Started')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionTitle('Email'),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Password'),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Create a password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Bio'),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  hintText: 'Tell us about yourself',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _buildSectionTitle('Country'),
              DropdownButtonFormField<String>(
                value: _selectedCountry,
                hint: const Text('Select your country'),
                items: _countries.map((String country) {
                  return DropdownMenuItem<String>(
                    value: country,
                    child: Text(country),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue;
                    _selectedCity = null;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              if (_selectedCountry != null) ...[
                _buildSectionTitle('City'),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  hint: const Text('Select your city'),
                  items: _citiesByCountry[_selectedCountry]!.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCity = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your city';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              _buildSectionTitle('Phone number'),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'We will contact you via call or text to verify your number.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Text(
                'Please note that standard message and data rates apply.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _signUpWithEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C3E50),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Have an account? Login'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}