import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/posting_model.dart';
import 'package:luti/view/guestScreens/book_listing_screen.dart';
import 'package:luti/view/widgets/posting_info_tile_ui.dart';

class ViewPostingScreen extends StatefulWidget {
  final PostingModel? posting;

  const ViewPostingScreen({
    super.key,
    this.posting,
  });

  @override
  State<ViewPostingScreen> createState() => _ViewPostingScreenState();
}

class _ViewPostingScreenState extends State<ViewPostingScreen> {
  late PostingModel posting;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    posting = widget.posting ?? PostingModel();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await posting.getAllImagesFromStorage();
      await posting.getHostFromFirestore();
    } catch (e) {
      debugPrint("Error loading posting data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF2C3E50),
        title: const Text(
          "Posting Information",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: ()
            {
              AppConstants.currentUser.addSavedPosting(posting);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image Carousel
          AspectRatio(
            aspectRatio: 3 / 2,
            child: PageView.builder(
              itemCount: posting.displayImages?.length ?? 0,
              itemBuilder: (context, index) {
                return Image(
                  image: posting.displayImages![index],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        posting.name?.toUpperCase() ?? "No Name",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.grey],
                              stops: [0.0, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              Get.to(BookListingScreen(posting: posting, hostID: posting.host!.id!));
                            },
                            child: const Text(
                              'Book Now',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₦ ${posting.price?.toStringAsFixed(2) ?? "0"}/month',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description and Host
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        posting.description ?? "No description available",
                        style: const TextStyle(
                          fontSize: 16.0,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          posting.host?.getFullNameOfUser() ?? "Host",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Property Details
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        PostingInfoTileUI(
                          iconData: Icons.home,
                          category: posting.type ?? "Property",
                          categoryInfo: '${posting.getGuestsNumber()} guests',
                        ),
                        const Divider(height: 16),
                        PostingInfoTileUI(
                          iconData: Icons.bed,
                          category: 'Beds',
                          categoryInfo: posting.getBedroomText(),
                        ),
                        const Divider(height: 16),
                        PostingInfoTileUI(
                          iconData: Icons.bathtub,
                          category: 'Bathrooms',
                          categoryInfo: posting.getBathroomText(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Amenities
                const Text(
                  'Amenities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (posting.amenities ?? [])
                      .map((amenity) => Chip(
                    label: Text(amenity),
                    backgroundColor: Colors.grey[200],
                  ))
                      .toList(),
                ),

                const SizedBox(height: 24),

                // Location
                const Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            posting.getFullAddress(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}