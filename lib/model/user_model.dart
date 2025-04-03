import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luti/model/booking_model.dart';
import 'package:luti/model/contact_model.dart';
import 'package:luti/model/conversation_model.dart';
import 'package:luti/model/posting_model.dart';
import 'package:luti/model/review_model.dart';

class UserModel extends ContactModel {
  // User Profile Data
  @override
  String? email;
  String? password;
  String? bio;
  String? city;
  String? country;
  @override
  String? phone;
  bool? isMost;
  bool? isCurrentlyHosting;
  double earnings = 0;
  DocumentSnapshot? snapshot;

  // Collections
  List<RentingModel> rentals = [];
  List<ReviewModel> reviews = [];
  List<PostingModel> savedPostings = [];
  List<PostingModel> myPostings = [];
  List<String> myPostingIDs = [];
  List<String> savedPostingIDs = [];

  UserModel({
    super.id,
    super.firstName,
    super.lastName,
    this.email,
    this.bio,
    this.city,
    this.country,
    this.phone,
    this.isMost = false,
    this.isCurrentlyHosting = false,
  });

  /* ------------------------- Authentication Methods ------------------------- */

  Future<void> initializeFromAuth(User firebaseUser) async {
    try {
      id = firebaseUser.uid;
      email = firebaseUser.email;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();

      if (userDoc.exists) {
        await loadUserData(userDoc);
      } else {
        await _createNewUser(firebaseUser);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Initialization failed: ${e.toString()}');
    }
  }

  Future<void> _createNewUser(User firebaseUser) async {
    try {
      if (firebaseUser.displayName != null) {
        final nameParts = firebaseUser.displayName!.split(' ');
        firstName = nameParts.first;
        if (nameParts.length > 1) {
          lastName = nameParts.sublist(1).join(' ');
        }
      }

      await saveUserToFirestore();
    } catch (e) {
      throw Exception('Failed to create new user: ${e.toString()}');
    }
  }

  /* --------------------------- Data Load Methods --------------------------- */

  Future<void> loadUserData(DocumentSnapshot snapshot) async {
    try {
      if (!snapshot.exists) throw Exception('User document not found');

      this.snapshot = snapshot;
      final data = snapshot.data() as Map<String, dynamic>;

      // Required fields
      id = snapshot.id;
      firstName = data['firstName']?.toString() ?? '';
      lastName = data['lastName']?.toString() ?? '';
      email = data['email']?.toString() ?? '';

      // Optional fields
      bio = data['bio']?.toString();
      city = data['city']?.toString();
      country = data['country']?.toString();
      phone = data['phone']?.toString();
      isMost = data['isMost'] as bool? ?? false;
      earnings = (data['earnings'] as num?)?.toDouble() ?? 0;

      // Initialize collections
      savedPostingIDs = List<String>.from(data['savedPostingIDs'] ?? []);
      myPostingIDs = List<String>.from(data['myPostingIDs'] ?? []);

      await _loadAllRelatedData();
    } catch (e) {
      throw Exception('Failed to load user data: ${e.toString()}');
    }
  }

  Future<void> _loadAllRelatedData() async {
    try {
      await Future.wait([
        getSavedPostingsFromFirestore(),
        getMyPostingsFromFirestore(),
        _loadRentals(),
      ]);
    } catch (e) {
      debugPrint('Non-critical error loading related data: $e');
    }
  }

  Future<void> getSavedPostingsFromFirestore() async {
    try {
      savedPostings = [];
      if (savedPostingIDs.isEmpty) return;

      await Future.wait(savedPostingIDs.map((postingID) async {
        try {
          final posting = PostingModel(id: postingID);
          await posting.getPostingInfoFromFirestore();
          if (posting.imageNames != null && posting.imageNames!.isNotEmpty) {
            await posting.getAllImagesFromStorage();
          }
          savedPostings.add(posting);
        } catch (e) {
          debugPrint('Error loading saved posting $postingID: $e');
        }
      }));

      savedPostings.sort((a, b) => b.id!.compareTo(a.id!));
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to load saved postings: ${e.toString()}');
    }
  }

  Future<void> getMyPostingsFromFirestore() async {
    try {
      myPostings = [];
      if (myPostingIDs.isEmpty) return;

      await Future.wait(myPostingIDs.map((postingID) async {
        try {
          final posting = PostingModel(id: postingID);
          await posting.getPostingInfoFromFirestore();
          await posting.getAllBookingsFromFirestore();
          if (posting.imageNames != null && posting.imageNames!.isNotEmpty) {
            await posting.getAllImagesFromStorage();
          }
          myPostings.add(posting);
        } catch (e) {
          debugPrint('Error loading my posting $postingID: $e');
        }
      }));
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to load my postings: ${e.toString()}');
    }
  }

  Future<void> _loadRentals() async {
    try {
      rentals = [];
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('rentals')
          .get();

      for (final doc in snapshot.docs) {
        try {
          final rental = RentingModel();
          await rental.getBookingInfoFromFirestoreFromPosting(PostingModel(), doc);
          rentals.add(rental);
        } catch (e) {
          debugPrint('Error loading rental ${doc.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('Error loading rentals: $e');
    }
  }

  /* --------------------------- Data Save Methods --------------------------- */

  Future<void> saveUserToFirestore() async {
    try {
      if (id == null || id!.isEmpty) {
        throw Exception('Cannot save user without ID');
      }

      final data = {
        'firstName': firstName ?? '',
        'lastName': lastName ?? '',
        'email': email ?? '',
        'bio': bio ?? '',
        'city': city ?? '',
        'country': country ?? '',
        'phone': phone ?? '',
        'isMost': isMost ?? false,
        'earnings': earnings,
        'myPostingIDs': myPostingIDs,
        'savedPostingIDs': savedPostingIDs,
        'updatedAt': FieldValue.serverTimestamp(),
        if (snapshot == null) 'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .set(data, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to save user: ${e.toString()}');
    }
  }

  /* ------------------------- Booking System Methods ------------------------ */

  Future<void> addBookingToFirestore(
    RentingModel rental,
    double totalPrice,
    String hostID,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      // 1. Add to user's rentals
      final userBookingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('rentals')
          .doc(rental.id);

      batch.set(userBookingRef, {
        'dates': rental.dates?.map((d) => Timestamp.fromDate(d)).toList(),
        'postingID': rental.posting?.id,
        'hostID': hostID,
        'totalPrice': totalPrice,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Update host's earnings
      final hostRef = FirebaseFirestore.instance.collection('users').doc(hostID);
      batch.update(hostRef, {
        'earnings': FieldValue.increment(totalPrice),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      await _createBookingConversation(rental, hostID);
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Booking failed: ${e.toString()}');
    }
  }

  Future<void> _createBookingConversation(RentingModel rental, String hostID) async {
    try {
      final conversation = await _getOrCreateConversation(hostID);
      await _sendBookingMessage(conversation, rental);
    } catch (e) {
      debugPrint('Booking conversation failed: $e');
      Get.snackbar(
        'Notice',
        'Booking successful but failed to notify host',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<ConversationModel> _getOrCreateConversation(String hostID) async {
    try {
      // Check for existing conversation
      final query = await FirebaseFirestore.instance
          .collection('conversations')
          .where('userIDs', arrayContains: id)
          .where('userIDs', arrayContains: hostID)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final existing = ConversationModel();
        existing.id = query.docs.first.id;
        existing.otherContact = ContactModel(id: hostID);
        return existing;
      }

      // Create new conversation
      final hostDoc = await FirebaseFirestore.instance.collection('users').doc(hostID).get();
      final hostName = '${hostDoc['firstName']} ${hostDoc['lastName']}';
      
      final newConvRef = await FirebaseFirestore.instance.collection('conversations').add({
        'userIDs': [id!, hostID],
        'userNames': [getFullNameOfUser(), hostName],
        'lastMessageText': '',
        'lastMessageDateTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      final newConversation = ConversationModel();
      newConversation.id = newConvRef.id;
      newConversation.otherContact = ContactModel(
        id: hostID,
        firstName: hostDoc['firstName'],
        lastName: hostDoc['lastName'],
      );
      
      return newConversation;
    } catch (e) {
      debugPrint('Error in getOrCreateConversation: $e');
      throw Exception('Failed to setup conversation');
    }
  }

  Future<void> _sendBookingMessage(ConversationModel conversation, RentingModel rental) async {
    try {
      final dateRange = rental.dates?.isNotEmpty ?? false
          ? '${rental.dates!.first.toString().split(' ')[0]} to ${rental.dates!.last.toString().split(' ')[0]}'
          : 'selected dates';

      final messageText = 'Hi, I\'m ${firstName ?? 'Guest'} and I\'ve booked '
          '${rental.posting?.name ?? 'your property'} for $dateRange. '
          'Looking forward to my stay!';

      // Add message to subcollection
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversation.id)
          .collection('messages')
          .add({
            'senderID': id,
            'text': messageText,
            'dateTime': FieldValue.serverTimestamp(),
            'read': false,
          });

      // Update conversation last message
      await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversation.id)
          .update({
            'lastMessageText': messageText,
            'lastMessageDateTime': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Failed to send booking confirmation');
    }
  }

  /* ------------------------- Listing Management ------------------------- */

  Future<void> addSavedPosting(PostingModel posting) async {
    try {
      if (savedPostingIDs.contains(posting.id)) return;

      savedPostingIDs.add(posting.id!);
      savedPostings.add(posting);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'savedPostingIDs': savedPostingIDs});

      Get.snackbar(
        'Saved',
        'Added to your favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to save posting: ${e.toString()}');
    }
  }

  Future<void> removeSavedPosting(PostingModel posting) async {
    try {
      savedPostingIDs.remove(posting.id);
      savedPostings.removeWhere((p) => p.id == posting.id);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'savedPostingIDs': savedPostingIDs});

      Get.snackbar(
        'Removed',
        'Removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to remove saved posting: ${e.toString()}');
    }
  }

  Future<void> addPostingToMyPostings(PostingModel posting) async {
    try {
      if (myPostingIDs.contains(posting.id)) return;

      myPostingIDs.add(posting.id!);
      myPostings.add(posting);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'myPostingIDs': myPostingIDs});
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    } catch (e) {
      throw Exception('Failed to add posting: ${e.toString()}');
    }
  }

  /* ------------------------- Utility Methods ------------------------- */

  ContactModel createContactFromUser() {
    return ContactModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
  }

  List<DateTime> getAllBookedDates() {
    final allBookedDates = <DateTime>[];
    if (myPostings != null) {
      for (final posting in myPostings) {
        if (posting.rentals != null) {
          for (final rental in posting.rentals!) {
            if (rental.dates != null) {
              allBookedDates.addAll(rental.dates!);
            }
          }
        }
      }
    }
    return allBookedDates;
  }

  /* ------------------------- Error Handlers ------------------------- */

  Exception _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found with this email');
      case 'wrong-password':
        return Exception('Incorrect password');
      case 'network-request-failed':
        return Exception('Network error. Please check your connection');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }

  Exception _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('You don\'t have permission for this action');
      case 'not-found':
        return Exception('Requested data not found');
      case 'unavailable':
        return Exception('Service unavailable. Please try again later');
      default:
        return Exception('Database error: ${e.message}');
    }
  }
}