import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:luti/model/posting_model.dart';

class PostingGridTileUI extends StatefulWidget {
  PostingModel? posting;
  PostingGridTileUI({
    super.key,
    this.posting,
  });

  @override
  State<PostingGridTileUI> createState() => _PostingGridTileUIState();
}

class _PostingGridTileUIState extends State<PostingGridTileUI> {
  PostingModel? posting;

  updateUI() async {
    await posting!.getFirstImageFromStorage();

    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    posting = widget.posting;

    updateUI();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 3/2,
          child: (posting!.displayImages!.isEmpty) ? Container() : Container(
            decoration:BoxDecoration(
              image: DecorationImage(
                image:posting!.displayImages!.first,
                fit: BoxFit.fill,
              ),
            ) , 
            
            
          ),
          

        ),


        Text(
          "${posting!.type} - ${posting!.city}, ${posting!.country}",
          maxLines: 2,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,

          ),
        ),

        Text(
          posting!.name!,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w200,
          ),
        ), 

        Text(
          '₦ ${posting!.price!} / night',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),

        Row(
          children: [

            RatingBar.readOnly(
              size: 20.0,
              maxRating: 5,
              initialRating: posting!.getCurrentRating(),
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              filledColor: Colors.yellow,


            ),


          ],
        ),






      ],
    );
  }
}
