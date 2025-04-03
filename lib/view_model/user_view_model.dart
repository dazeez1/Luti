import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/user_model.dart';
import 'package:luti/view/guestScreens/account_screen.dart';
import 'package:luti/view/guest_home_screen.dart';

class UserViewModel extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String city,
    required String country,
    required String bio,
    String? phone,
  }) async {
    try {
      Get.snackbar(
        "Please wait",
        "Creating your account...",
        snackPosition: SnackPosition.TOP,
      );

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      final String userId = result.user!.uid;

      AppConstants.currentUser = UserModel(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        city: city,
        country: country,
        bio: bio,
        phone: phone,
      );

      await AppConstants.currentUser.saveUserToFirestore().catchError((error) {
        // Catch any errors during Firestore write
        print("Error saving user to Firestore during signup: $error");
        Get.snackbar("Error", "Failed to save user data. Please try again.");
        throw error; // Re-throw the error to be caught by the outer catch
      });

      await _initializeCurrentUser(userId);

      Get.offAll(() => const AccountScreen());
      Get.snackbar("Success", "Account created successfully");
    } on FirebaseAuthException catch (e) {
      String error = "Signup failed";
      if (e.code == 'weak-password') error = "Password is too weak";
      if (e.code == 'email-already-in-use') error = "Email already in use";
      Get.snackbar("Error", error);
    } catch (e) {
      print("Unexpected error during signup: $e");
      Get.snackbar("Error", "An unexpected error occurred: ${e.toString()}");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Get.snackbar(
        "Please wait",
        "Signing you in...",
        snackPosition: SnackPosition.TOP,
      );

      final UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      final String userId = result.user!.uid;
      await _initializeCurrentUser(userId);

      Get.offAll(() => const GuestHomeScreen());
      Get.snackbar("Success", "Logged in successfully");
    } on FirebaseAuthException catch (e) {
      String error = "Login failed";
      if (e.code == 'user-not-found') error = "User not found";
      if (e.code == 'wrong-password') error = "Incorrect password";
      Get.snackbar("Error", error);
    } catch (e) {
      print("Error during login: ${e.toString()}");
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    }
  }

  Future<void> _initializeCurrentUser(String userId) async {
    try {
      print("Attempting to fetch user document for ID: $userId");
      DocumentSnapshot snapshot =
          await _firestore.collection("users").doc(userId).get();

      if (!snapshot.exists) {
        print("User document not found for ID: $userId");
        throw Exception("User document not found");
      }

      print("User document found. Attempting to load data.");
      AppConstants.currentUser = UserModel(
        id: userId,
        email: snapshot['email'] ,
        firstName: snapshot['firstName'],
        lastName: snapshot['lastName'],
        city: snapshot['city'],
        country: snapshot['country'],
        bio: snapshot['bio'],
        phone: snapshot['phone'],
      )..snapshot = snapshot;

      try {
        print("Attempting to load additional user data (loadUserData)");
        await AppConstants.currentUser.loadUserData(snapshot);
        print("Additional user data (loadUserData) loaded successfully");
      } catch (e) {
        print("Error loading additional user data (loadUserData): $e");
        throw Exception("Failed to load additional user data: $e");
      }

      try {
        print("Attempting to load my postings");
        await AppConstants.currentUser.getMyPostingsFromFirestore();
        print("My postings loaded successfully");
      } catch (e) {
        print("Error loading my postings: $e");
      }

      try {
        print("Attempting to load saved postings");
        await AppConstants.currentUser.getSavedPostingsFromFirestore();
        print("Saved postings loaded successfully");
      } catch (e) {
        print("Error loading saved postings: $e");
      }
    } catch (e) {
      print("Error initializing current user: $e");
      throw Exception("Failed to initialize user: $e");
    }
  }

  Future<void> becomeHost(String userId) async {
    try {
      await _firestore.collection("users").doc(userId).update({
        "isMost": true,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      AppConstants.currentUser.isMost = true;
      Get.snackbar("Success", "You are now a host");
    } catch (e) {
      Get.snackbar("Error", "Failed to update host status");
    }
  }

  void modifyCurrentlyHosting(bool isHosting) {
    AppConstants.currentUser.isCurrentlyHosting = isHosting;
  }

  // Add this method to handle user persistence
  Future<void> checkAuthState() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _initializeCurrentUser(user.uid);
    }
  }
}