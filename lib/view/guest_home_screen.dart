import 'package:flutter/material.dart';
import 'package:luti/view/guestScreens/account_screen.dart';
import 'package:luti/view/guestScreens/chat_screen.dart';
import 'package:luti/view/guestScreens/explore_screen.dart';
import 'package:luti/view/guestScreens/saved_listings_screen.dart';
import 'package:luti/view/guestScreens/trips_screen.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}




class _GuestHomeScreenState extends State<GuestHomeScreen>
{
  int selectedIndex = 0;

  final List<String> screenTitles = [
    'Explore',
    'Saved',
    'Homes',
    'Messages',
    'Profile',
  ];

  final List<Widget> screens = [
    ExploreScreen(),
    SavedListingsScreen(),
    TripsScreen(),
    ChatScreen(),
    AccountScreen(),
  ];

  BottomNavigationBarItem customNavigationBarItem(int index, IconData iconData, String title) {
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
        onTap: (i)
        {
          setState(() {
            selectedIndex = i;
          });
        },
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>
        [
          customNavigationBarItem(0, Icons.search, screenTitles[0]),
          customNavigationBarItem(1, Icons.favorite_border, screenTitles[1]),
          customNavigationBarItem(2, Icons.hotel, screenTitles[2]),
          customNavigationBarItem(3, Icons.message, screenTitles[3]),
          customNavigationBarItem(4, Icons.person_outline, screenTitles[4]),
        ],
      ),
    );
  }
}
