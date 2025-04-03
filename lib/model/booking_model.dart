import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luti/model/contact_model.dart';
import 'package:luti/model/posting_model.dart';

class RentingModel {
  String? id;
  PostingModel? posting;
  ContactModel? contact;
  List<DateTime>? dates;
  DateTime? createdAt;
  String status = 'pending';

  Future<void> getBookingInfoFromFirestoreFromPosting(
      PostingModel posting, DocumentSnapshot snapshot) async {
    try {
      this.posting = posting;
      id = snapshot.id;

      // Parse dates - handle missing or invalid fields
      final datesData = snapshot['dates'];
      if (datesData is List) {
        final timestamps = datesData.whereType<Timestamp>().toList();
        dates = timestamps.map((t) => t.toDate()).toList();
      } else {
        dates = [];
      }

      // Parse status with default value
      status = (snapshot['status'] as String?) ?? 'pending';

      // Load contact info with null checks
      final contactID = (snapshot['userID'] as String?) ?? '';
      final fullName = (snapshot['name'] as String?) ?? '';
      await _loadContactInfo(contactID, fullName);
    } catch (e) {
      print('Error loading booking info: $e');
      rethrow;
    }
  }

  Future<void> _loadContactInfo(String id, String fullName) async {
    try {
      final nameParts = fullName.split(' ');
      contact = ContactModel(
        id: id,
        firstName: nameParts.isNotEmpty ? nameParts[0] : '',
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      );
      await contact?.getContactInfoFromFirestore();
    } catch (e) {
      print('Error loading contact info: $e');
      contact ??= ContactModel(id: id);
    }
  }

  void createBooking(PostingModel postingM, ContactModel contactM, List<DateTime> datesM, {double? total}) {
    posting = postingM;
    contact = contactM;
    dates = List.from(datesM)..sort();
    createdAt = DateTime.now();
    status = 'confirmed';
  }

  String get dateRange {
    if (dates == null || dates!.isEmpty) return 'No dates selected';
    final start = dates!.first.toString().split(' ')[0];
    final end = dates!.last.toString().split(' ')[0];
    return start == end ? start : '$start to $end';
  }
}