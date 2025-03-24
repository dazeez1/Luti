import 'package:flutter/material.dart';
import 'package:luti/model/app_constants.dart';


class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 50, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //user info
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Center(
                child: Column(
                  children: [

                    //name and email
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
                         style: const TextStyle(
                           fontSize: 15,
                         ),
                       ),
                     ],
                   )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
