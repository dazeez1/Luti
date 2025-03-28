import 'package:luti/model/contact_model.dart';
import 'package:luti/model/posting_model.dart';

class BookingModel {
  String id = "";
  PostingModel? posting;
  ContactModel? contact;
  List<DateTime>? dates;

  BookingModel();
}
