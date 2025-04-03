import 'package:flutter/material.dart';

class PostingListTileButton extends StatefulWidget {
  const PostingListTileButton({super.key});

  @override
  State<PostingListTileButton> createState() => _PostingListTileButtonState();
}

class _PostingListTileButtonState extends State<PostingListTileButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 15.0,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add),
          Text(
            'Create a listing',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }
}
