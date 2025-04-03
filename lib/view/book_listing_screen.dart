import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luti/global.dart';
import 'package:luti/model/posting_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:luti/view/guest_home_screen.dart';
import 'package:luti/view/widgets/calendar_ui.dart';

class BookListingScreen extends StatefulWidget {
  final PostingModel posting;
  final String? hostID;

  const BookListingScreen({
    Key? key,
    required this.posting,
    this.hostID,
  }) : super(key: key);

  @override
  State<BookListingScreen> createState() => _BookListingScreenState();
}

class _BookListingScreenState extends State<BookListingScreen> {
  late PostingModel posting;
  List<DateTime> bookedDates = [];
  List<DateTime> selectedDates = [];
  List<CalendarUi> calendarWidgets = [];
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    posting = widget.posting;
    _loadBookedDates();
  }

  void _buildCalendarWidgets() {
    calendarWidgets = List.generate(12, (i) => CalendarUi(
      monthIndex: i,
      bookedDates: bookedDates,
      selectDate: _selectDate,
      getSelectedDates: _getSelectedDates,
    ));
    setState(() {});
  }

  List<DateTime> _getSelectedDates() => selectedDates;

  void _selectDate(DateTime date) {
    setState(() {
      if (selectedDates.contains(date)) {
        selectedDates.remove(date);
      } else {
        selectedDates.add(date);
      }
      selectedDates.sort();
    });
  }

  Future<void> _loadBookedDates() async {
    await posting.getAllBookingsFromFirestore();
    bookedDates = posting.getAllBookedDates();
    _buildCalendarWidgets();
  }

  Future<void> _makeBooking() async {
    if (selectedDates.isEmpty) {
      Get.snackbar('Error', 'Please select at least one date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isBooking = true);

    try {
      // Calculate total price
      double totalPrice = selectedDates.length * (posting.price ?? 0);

      // Get the effective host ID
      final effectiveHostID = widget.hostID ?? posting.host?.id;
      if (effectiveHostID == null) {
        throw Exception("Host information is missing");
      }

      // Create the booking
      await posting.makeNewBooking(
        selectedDates, 
        context, 
        effectiveHostID,
        totalPrice: totalPrice,
      );

      Get.offAll(() => const GuestHomeScreen());
      Get.snackbar('Success', 'Booking completed!',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete booking: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  Future<void> _launchEmail() async {
    final formattedDates = selectedDates
        .map((date) => date.toString().split(' ')[0])
        .join(', ');

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: posting.host?.email ?? '',
      queryParameters: {
        'subject': 'Booking Inquiry for ${posting.name}',
        'body': 'Hello,\n\nI would like to book ${posting.name} '
            'for these dates:\n$formattedDates\n\n'
            'Please confirm availability.\n\n'
            'Best regards,',
      },
    );

    if (!await launchUrl(emailUri)) {
      Get.snackbar('Error', 'Could not launch email app',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _launchPhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: posting.host?.phone ?? '',
    );

    if (!await launchUrl(phoneUri)) {
      Get.snackbar('Error', 'Could not launch phone app',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${posting.name}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Calendar Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text("Sun"),
                Text("Mon"),
                Text("Tue"),
                Text("Wed"),
                Text("Thu"),
                Text("Fri"),
                Text("Sat"),
              ],
            ),

            // Calendar View
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: calendarWidgets.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : PageView.builder(
                      itemCount: calendarWidgets.length,
                      itemBuilder: (context, index) => calendarWidgets[index],
                    ),
            ),

            // Selected Dates
            if (selectedDates.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Selected: ${selectedDates.length} days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                selectedDates.map((d) => d.toString().split(' ')[0]).join('\n'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            // Booking and Contact Buttons
            Column(
              children: [
                if (selectedDates.isNotEmpty)
                  ElevatedButton(
                    onPressed: _isBooking ? null : _makeBooking,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: _isBooking
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Book Now', style: TextStyle(fontSize: 18)),
                  ),
                const SizedBox(height: 16),
                if (selectedDates.isNotEmpty) ...[
                  const Text('Or contact host directly:'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.email),
                          label: const Text('Email'),
                          onPressed: _launchEmail,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          onPressed: _launchPhoneCall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}