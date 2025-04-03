import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';


class ContactModel {
  String? id;
  String? firstName;
  String? lastName;
  String? fullName;
  String? email;       // Add this
  String? phone; // Add this

  ContactModel({
    this.id = "",
    this.firstName = "",
    this.lastName = "",
    this.email = "",       // Initialize
    this.phone = "", // Initialize
  });

  String getFullNameOfUser() {
    return fullName = "${firstName ?? ''} ${lastName ?? ''}";
  }

  UserModel createUserFromContact() {
    return UserModel(
      id: id ?? "",
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      email: email ?? "",       // Pass email
      phone: phone ?? "", // Pass phoneNumber
    );
  }

  Future<void> getContactInfoFromFirestore() async {
    try {
      DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        firstName = data['firstName'] as String? ?? "";
        lastName = data['lastName'] as String? ?? "";
        email = data['email'] as String?;  // Will be null if field doesn't exist
        phone = data['phoneNumber'] as String?;  // Will be null if field doesn't exist

        // Alternative field names if needed
        email ??= data['userEmail'] as String?;
        phone ??= data['mobile'] as String?;
      }
    } catch (e) {
      print('Error getting contact info: $e');
      // Don't throw exception here - handle missing fields gracefully
    }
  }

}