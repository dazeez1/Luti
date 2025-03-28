import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luti/model/booking_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:luti/model/contact_model.dart';
import 'package:luti/model/posting_model.dart';
import 'package:luti/model/review_model.dart';

class UserModel extends ContactModel {
  String? email;
  String? password;
  String? bio;
  String? city;
  String? country;
  String? phoneNumber;
  bool? isMost;
  bool? isCurrentlyHosting;
  DocumentSnapshot? snapshot;

  List<BookingModel>? bookings;
  List<ReviewModel>? reviews;

  List<PostingModel>? myPostings;

  UserModel({
    String super.id,
    String super.firstName,
    String super.lastName,
    super.displayImage,
    this.email = "",
    this.bio = "",
    this.city = "",
    this.country = "",
    this.phoneNumber = "",
  }) {
    isMost = false;
    isCurrentlyHosting = false;

    bookings = [];
    reviews = [];
    myPostings = [];
  }

  addPostingToMyPostings(PostingModel posting) async {
    myPostings!.add(posting);

    List<String> myPostingIDsList = [];

    for (var element in myPostings!) {
      myPostingIDsList.add(element.id!);
    }

    await FirebaseFirestore.instance.collection("users").doc(id).update({
      'myPostingIDs': myPostingIDsList,
    });
  }

  getMyPostingsFromFirestore() async {
    List<String> myPostingIDs =
        List<String>.from(snapshot!["myPostingIDs"]) ?? [];

    for (String postingID in myPostingIDs) {
      PostingModel posting = PostingModel(id: postingID);
      await posting.getPostingInfoFromFirestore();
      await posting.getAllImagesFromStorage();

      myPostings!.add(posting);
    }
  }

  Future<void> saveUserToFirestore() async {
    Map<String, dynamic> dataMap = {
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
    };

    await FirebaseFirestore.instance.collection("users").doc(id).set(dataMap);
  }
}
