import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:luti/model/contact_model.dart';

class UserModel extends ContactModel
{
  String? email;
  String? password;
  String? bio;
  String? city;
  String? country;
  String? phoneNumber;
  bool? isMost;
  bool? isCurrentlyHosting;
  DocumentSnapshot? snapshot;

  UserModel({
    String id = "",
    String firstName = "",
    String lastName = "",
    MemoryImage? displayImage,
    this.email = "",
    this.bio = "",
    this.city = "",
    this.country = "",
    this.phoneNumber = "",
}):super (id: id, firstName: firstName, lastName:lastName, displayImage: displayImage)
  {
    isMost = false;
    isCurrentlyHosting = false;
  }

  Future<void> saveUserToFirestore() async
  {
    Map<String, dynamic> dataMap =
    {
      "bio": bio,
      "city": city,
      "country": country,
      "email": email,
      "firstName": firstName,
      "lastName":lastName,
      "isMost": false,
      "myPostingIDs": [],
      "savedPostingIDs": [],
      "earnings": 0,
    };

    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }
}