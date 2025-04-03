import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'; // Import for BuildContext
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../global.dart';
import 'app_constants.dart';
import 'review.model.dart';
import 'booking_model.dart';
import 'contact_model.dart';
import 'user_model.dart'; // Import UserModel

class PostingModel {
  String? id;
  String? name;
  String? type;
  double? price;
  String? description;
  String? address;
  String? city;
  double? rating;

  ContactModel? host;

  List<String>? imageNames;
  List<MemoryImage>? displayImages;
  List<String>? amenities;

  Map<String, int>? beds;
  Map<String, int>? bathrooms;

  Map<String, int>? kitchen;
  Map<String, int>? furniture;

  List<RentingModel>? rentals;
  List<ReviewModel>? reviews;

  PostingModel({
    this.id = "",
    this.name = "",
    this.type = "",
    this.price = 0,
    this.description = "",
    this.address = "",
    this.city = "",
    this.host,
  }) {
    displayImages = [];
    amenities = [];
    beds = {};
    bathrooms = {};
    kitchen = {};
    furniture = {};
    rating = 0;
    rentals = [];
    reviews = [];
  }

  setImagesNames() {
    imageNames = [];
    for (int i = 0; i < (displayImages?.length ?? 0); i++) {
      imageNames!.add('images$i.png');
    }
  }

  Future<void> contactHostViaEmail(List<DateTime> selectedDates) async {
    if (host == null || host!.email == null || host!.email!.isEmpty) {
      throw Exception("Host email not available");
    }

    final String formattedDates = selectedDates
        .map((date) => date.toString().split(' ')[0])
        .join(', ');

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: host!.email,
      queryParameters: {
        'subject': 'Booking Inquiry for $name',
        'body': 'Hello,\n\nI would like to inquire about booking your property "$name" '
            'for the following dates:\n\n$formattedDates\n\n'
            'Please let me know if these dates are available and the next steps to proceed.\n\n'
            'Looking forward to your response.\n\nBest regards,',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw Exception('Could not launch email client');
    }
  }

  Future<void> contactHostViaPhone() async {
    if (host == null || host!.phone == null || host!.phone!.isEmpty) {
      throw Exception("Host phone number not available");
    }

    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: host!.phone,
    );

    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    } else {
      throw Exception('Could not launch phone app');
    }
  }

  Future<void> getPostingInfoFromFirestore() async {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("postings").doc(id).get();
    getPostingInfoFromSnapshot(snapshot);
  }

  getPostingInfoFromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    address = data['address']?.toString() ?? "";
    amenities =
        data.containsKey('amenities') ? List<String>.from(data['amenities']) : [];
    bathrooms =
        data.containsKey('bathrooms') ? Map<String, int>.from(data['bathrooms']) : {};
    beds = data.containsKey('beds') ? Map<String, int>.from(data['beds']) : {};
    city = data['city']?.toString() ?? "";
    description = data['description']?.toString() ?? "";
    String hostID = data['hostID']?.toString() ?? "";
    host = ContactModel(id: hostID);
    imageNames =
        data.containsKey('imageNames') ? List<String>.from(data['imageNames']) : [];
    name = data['name']?.toString() ?? "";
    price = data['price'] is num ? (data['price'] as num).toDouble() : 0.0;
    rating = data['rating'] is num ? (data['rating'] as num).toDouble() : 2.5;
    type = data['type']?.toString() ?? "";

    // Handle kitchen field
    kitchen = (data.containsKey('kitchen') && data['kitchen'] is Map)
        ? Map<String, int>.from(data['kitchen'])
        : {};

    // Handle furniture field
    furniture = (data.containsKey('furniture') && data['furniture'] is Map)
        ? Map<String, int>.from(data['furniture'])
        : {};
  }

  Future<List<MemoryImage>> getAllImagesFromStorage() async {
    displayImages = [];
    for (int i = 0; i < (imageNames?.length ?? 0); i++) {
      final imagePath = "postingImages/$id/${imageNames![i]}"; // Construct path
      print("Attempting to download image from: $imagePath"); // Log the path
      try {
        final imageData = await FirebaseStorage.instance
            .ref()
            .child(imagePath)
            .getData(1048576);
        displayImages!.add(MemoryImage(imageData!));
      } catch (e) {
        print("Error downloading image from $imagePath: $e"); // Log error
        // Handle the error appropriately.
        // 1. Show a user-friendly message.
        // 2. Use a placeholder image.
        // 3. Remove the invalid image name from the list.
      }
    }
    return displayImages!;
  }

  Future<MemoryImage?> getFirstImageFromStorage() async {
    if (displayImages != null && displayImages!.isNotEmpty) {
      return displayImages!.first;
    }
    if (imageNames == null || imageNames!.isEmpty) {
      return null; // return null if there are no images.
    }

    try {
      final imageData = await FirebaseStorage.instance
          .ref()
          .child("postingImages") // Use actual name here for where images are stored.
          .child(id!)
          .child(imageNames!.first)
          .getData(1048576);

      final memoryImage = MemoryImage(imageData!); // Create MemoryImage
      displayImages ??= [];
      displayImages!.add(memoryImage); // Add to the list
      return memoryImage; // Return the MemoryImage
    } catch (e) {
      print("Error loading first image: $e");
      return null; // Return null in case of error.
    }
  }

  String getAmenitiesString() {
    if (amenities == null || amenities!.isEmpty) {
      return "";
    }
    String amenitiesString = amenities.toString();
    return amenitiesString.substring(1, amenitiesString.length - 1);
  }

  double getCurrentRating() {
    if (reviews == null || reviews!.isEmpty) {
      return 4;
    }
    double rating = 0;
    for (var review in reviews!) {
      rating += review.rating!;
    }
    rating /= reviews!.length;
    return rating;
  }

  Future<void> getHostFromFirestore() async {
    if (host != null) {
      await host!.getContactInfoFromFirestore();
    }
  }

  int getGuestsNumber() {
    int numGuests = 0;
    numGuests = numGuests + (beds?['small'] ?? 0);
    numGuests = numGuests + (beds?['medium'] ?? 0) * 2;
    numGuests = numGuests + (beds?['large'] ?? 0) * 2;
    return numGuests;
  }

  String getBedroomText() {
    String text = "";
    if (beds?['small'] != null && beds!['small'] != 0) {
      text = "$text${beds?['small']?.toString() ?? "0"} single/twin";
    }
    if (beds?['medium'] != null && beds!['medium'] != 0) {
      text = "$text${beds?['medium']?.toString() ?? "0"} double";
    }
    if (beds?['large'] != null && beds!['large'] != 0) {
      text = "$text${beds?['large']?.toString() ?? "0"} queen/king";
    }
    return text;
  }

  String getBathroomText() {
    String text = "";
    if (bathrooms?['small'] != null && bathrooms!['small'] != 0) {
      text = "$text${bathrooms?['small']?.toString() ?? "0"} Bathroom";
    }
    if (bathrooms?['medium'] != null && bathrooms!['medium'] != 0) {
      text = "$text${bathrooms?['medium']?.toString() ?? "0"} Bathrooms";
    }
    if (bathrooms?['large'] != null && bathrooms!['large'] != 0) {
      text = "$text${bathrooms?['large']?.toString() ?? "0"} Bathrooms";
    }
    return text;
  }

  String getFullAddress() {
    return "${address ?? ""}, ${city ?? ""}";
  }

  // New methods to get Kitchen and Furniture text.
  String getKitchenText() {
    String text = "";
    if (kitchen?['full'] != null && kitchen!['full'] != 0) {
      text = "$text${kitchen?['full']?.toString() ?? "0"} Fully-Furnished";
    }
    if (kitchen?['half'] != null && kitchen!['half'] != 0) {
      text = "$text${kitchen?['half']?.toString() ?? "0"} Semi-Furnished";
    }
    if (kitchen?['None'] != null && kitchen!['None'] != 0) {
      text = "$text${kitchen?['None']?.toString() ?? "0"} Not-Furnished";
    }
    return text;
  }

  String getFurnitureText() {
    String text = "";
    if (furniture?['full'] != null && furniture!['full'] != 0) {
      text = "$text${furniture?['full']?.toString() ?? "0"} Fully-Furnished";
    }
    if (furniture?['half'] != null && furniture!['half'] != 0) {
      text = "$text${furniture?['half']?.toString() ?? "0"} Semi-Furnished";
    }
    if (furniture?['None'] != null && furniture!['None'] != 0) {
      text = "$text${furniture?['None']?.toString() ?? "0"} Not-Furnished";
    }
    return text;
  }

  Future<void> getAllBookingsFromFirestore() async {
    rentals = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('postings')
          .doc(id)
          .collection('rentals')
          .get();

      for (var doc in snapshot.docs) {
        try {
          RentingModel newRental = RentingModel();
          await newRental.getBookingInfoFromFirestoreFromPosting(this, doc);
          rentals!.add(newRental);
        } catch (e) {
          print('Error loading rental ${doc.id}: $e');
        }
      }
    } catch (e) {
      print('Error loading bookings: $e');
      rethrow;
    }
  }

  List<DateTime> getAllBookedDates() {
    List<DateTime> dates = [];
    if (rentals != null) {
      for (var rental in rentals!) {
        if (rental.dates != null) {
          dates.addAll(rental.dates!);
        }
      }
    }
    return dates;
  }

  Future<void> makeNewBooking(
    List<DateTime> dates,
    BuildContext context,
    String hostID, {
    double? totalPrice,
  }) async {
    try {
      // Validate input
      if (dates.isEmpty) throw Exception("No dates selected for booking");
      if (hostID.isEmpty) throw Exception("Host ID is required");

      // Create complete booking data with all required fields
      Map<String, dynamic> bookingData = {
        'dates': dates.map((d) => Timestamp.fromDate(d)).toList(),
        'name': AppConstants.currentUser.getFullNameOfUser(),
        'userID': AppConstants.currentUser.id,
        'payment': totalPrice ?? (dates.length * (price ?? 0)),
        'status': 'confirmed', // Ensure status is always included
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add booking to Firestore under the posting
      DocumentReference reference = await FirebaseFirestore.instance
          .collection('postings')
          .doc(id)
          .collection('rentals')
          .add(bookingData);

      // Create and store rental model
      RentingModel newRental = RentingModel();
      newRental.createBooking(
        this,
        AppConstants.currentUser.createUserFromContact(),
        dates,
        total: totalPrice,
      );
      newRental.id = reference.id;

      rentals ??= [];
      rentals!.add(newRental);

      // Update user's bookings and host earnings
      await AppConstants.currentUser.addBookingToFirestore(
        newRental,
        totalPrice ?? (dates.length * (price ?? 0)),
        hostID,
    // Pass the posting ID here
      );

      Get.snackbar("Success", "Booking Successful");
    } catch (e) {
      print('Error making booking: $e');
      Get.snackbar("Error", "Failed to complete booking: ${e.toString()}");
      rethrow;
    }
  }
}

