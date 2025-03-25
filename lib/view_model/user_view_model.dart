import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/user_model.dart';
import 'package:luti/view/guestScreens/account_screen.dart';
import 'package:luti/view/guest_home_screen.dart';

class UserViewModel
{
  UserModel userModel = UserModel();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUp(
      String email,
      String password,
      String firstName,
      String lastName,
      String city,
      String country,
      String bio,
      ) async {
    try {
      Get.snackbar(
        "Please wait",
        "Your account is being created",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      final UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String currentUserID = result.user!.uid;
      AppConstants.currentUser.id = currentUserID;
      AppConstants.currentUser.firstName = firstName;
      AppConstants.currentUser.lastName = lastName;
      AppConstants.currentUser.city = city;
      AppConstants.currentUser.country = country;
      AppConstants.currentUser.bio = bio;
      AppConstants.currentUser.email = email;
      AppConstants.currentUser.password = password;

      await _saveUserToFirestore(
        bio: bio,
        city: city,
        country: country,
        email: email,
        firstName: firstName,
        lastName: lastName,
        id: currentUserID,
      );

      Get.snackbar(
        "Congratulations!",
        "Your account has been created successfully",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );

      Get.offAll(() => const AccountScreen());

    } on FirebaseAuthException catch (e) {
      String errorMessage = "Signup failed";
      if (e.code == 'weak-password') {
        errorMessage = "Password is too weak";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email is already in use";
      }

      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "An unexpected error occurred",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _saveUserToFirestore({
    required String bio,
    required String city,
    required String country,
    required String email,
    required String firstName,
    required String lastName,
    required String id,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        "bio": bio,
        "city": city,
        "country": country,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "isMost": false,
        "myPostingIDs": [],
        "savedPostingIDs": [],
        "earnings": 0,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await _firestore.collection("users").doc(id).set(dataMap);
    } catch (e) {
      throw Exception("Failed to save user data: $e");
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Show loading snackbar
      Get.snackbar(
        "Please wait",
        "Checking your credentials...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // 1. Authenticate with Firebase Auth
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Set basic user info
      String currentUserID = result.user!.uid;
      AppConstants.currentUser.id = currentUserID;
      AppConstants.currentUser.email = email;

      // 3. Fetch additional user data from Firestore
      await _getUserInfoFromFirestore(currentUserID);

      // 4. Only navigate after all data is loaded
      Get.offAll(() => const GuestHomeScreen());

      // 5. Show success message
      Get.snackbar(
        "Success",
        "You are logged in successfully",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );

    } on FirebaseAuthException catch (e) {
      // Handle auth errors
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      }
      throw errorMessage; // Throw specific error

    } catch (e) {
      // Handle other errors
      throw "Failed to complete login: ${e.toString()}";
    }
  }

  Future<void> _getUserInfoFromFirestore(String userID) async {
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection("users").doc(userID).get();

      if (!snapshot.exists) {
        throw "User data not found in database";
      }

      // Update all user properties
      AppConstants.currentUser.snapshot = snapshot;
      AppConstants.currentUser.firstName = snapshot["firstName"] ?? "";
      AppConstants.currentUser.lastName = snapshot["lastName"] ?? "";
      AppConstants.currentUser.bio = snapshot["bio"] ?? "";
      AppConstants.currentUser.city = snapshot["city"] ?? "";
      AppConstants.currentUser.country = snapshot["country"] ?? "";

    } catch (e) {
      throw "Failed to load user data: ${e.toString()}";
    }
  }

  becomeHost(String userID) async
  {

    userModel.isMost = true;

    Map<String, dynamic> dataMap =
    {
      "isMost": true
    };
    await _firestore.collection("users").doc(userID).update(dataMap);
  }

  modifyCurrentlyHosting(bool isHosting)
  {
    userModel.isCurrentlyHosting = isHosting;
  }
}