import 'package:flutter/material.dart';

class PostingListTile extends StatefulWidget {
  const PostingListTile({super.key});

  @override
  State<PostingListTile> createState() => _PostingListTileState();
}

class _PostingListTileState extends State<PostingListTile> {
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
