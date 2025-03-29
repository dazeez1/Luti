import 'package:flutter/material.dart';
import 'package:luti/view/guestScreens/account_screen.dart';
import 'package:luti/view/guestScreens/chat_screen.dart';
import 'package:luti/view/hostScreens/my_postings_screen.dart';
import 'package:luti/view/hostScreens/purchases_screen.dart';

class HostHomeScreen extends StatefulWidget {
  int? index;
  HostHomeScreen({super.key, this.index});

  @override
  State<HostHomeScreen> createState() => _HostHomeScreenState();
}

class _HostHomeScreenState extends State<HostHomeScreen> {
  int selectedIndex = 0;

  final List<String> screenTitles = [
    'Purchases',
    'My Postings',
    'Messages',
    'Profile',
  ];

  final List<Widget> screens = [
    PurchasesScreen(),
    MyPostingsScreen(),
    ChatScreen(),
    AccountScreen(),
  ];

  BottomNavigationBarItem customNavigationBarItem(
      int index, IconData iconData, String title) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: Colors.grey),
          Text(
            title,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
      activeIcon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: Colors.black),
          Text(
            title,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      label: '', // Set to empty string since we're handling it manually
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    selectedIndex = widget.index ?? 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2C3E50),
          ),
        ),
        title: Text(
          screenTitles[selectedIndex],
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          customNavigationBarItem(0, Icons.calendar_today, screenTitles[0]),
          customNavigationBarItem(1, Icons.home, screenTitles[1]),
          customNavigationBarItem(2, Icons.message, screenTitles[2]),
          customNavigationBarItem(3, Icons.person_outline, screenTitles[3]),
        ],
      ),
    );
  }
}
