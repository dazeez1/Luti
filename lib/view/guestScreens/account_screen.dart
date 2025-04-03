import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luti/global.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/view/guest_home_screen.dart';
import 'package:luti/view/host_home_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _hostingTitle = 'Show my Host Dashboard';

  @override
  void initState() {
    super.initState();
    _updateHostingTitle();
  }

  void _updateHostingTitle() {
    setState(() {
      if (AppConstants.currentUser.isMost!) {
        _hostingTitle = AppConstants.currentUser.isCurrentlyHosting!
            ? 'Show my Guest Dashboard'
            : 'Show my Host Dashboard';
      } else {
        _hostingTitle = 'Become a host';
      }
    });
  }

  Future<void> modifyHostingMode() async {
    try {
      if (AppConstants.currentUser.isMost!) {
        // Toggle hosting mode for existing hosts
        AppConstants.currentUser.isCurrentlyHosting =
        !AppConstants.currentUser.isCurrentlyHosting!;

      } else {
        // Convert to host
        await userViewModel.becomeHost(FirebaseAuth.instance.currentUser!.uid);
        AppConstants.currentUser.isMost = true;
        AppConstants.currentUser.isCurrentlyHosting = true;
      }

      // Navigate to appropriate screen
      if (AppConstants.currentUser.isCurrentlyHosting!) {
        Get.offAll(() => HostHomeScreen());
      } else {
        Get.offAll(() => GuestHomeScreen());
      }

      // Update UI
      _updateHostingTitle();

    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to switch mode: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint("Error modifying hosting mode: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 50, 20, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info section
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Center(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.currentUser.getFullNameOfUser(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            AppConstants.currentUser.email.toString(),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Buttons section
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Personal information button
                  _buildListButton(
                    context: context,
                    title: "Personal Information",
                    icon: Icons.person_2,
                    onPressed: () {
                      // Handle personal info
                    },
                  ),

                  const SizedBox(height: 30),

                  // Hosting mode toggle button
                  _buildListButton(
                    context: context,
                    title: _hostingTitle,
                    icon: Icons.hotel_outlined,
                    onPressed: modifyHostingMode,
                  ),

                  const SizedBox(height: 30),

                  // Logout button
                  _buildListButton(
                    context: context,
                    title: "Logout",
                    icon: Icons.logout_outlined,
                    onPressed: () {
                      // Handle logout
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: MaterialButton(
        height: MediaQuery.of(context).size.height / 9.1,
        onPressed: onPressed,
        child: ListTile(
          contentPadding: const EdgeInsets.all(0.0),
          leading: Text(
            title,
            style: const TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.normal,
            ),
          ),
          trailing: Icon(icon, size: 34),
        ),
      ),
    );
  }
}