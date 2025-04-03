import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:luti/model/posting_model.dart';

class PostingGridTileUI extends StatefulWidget {
  final PostingModel? posting;

  const PostingGridTileUI({
    super.key,
    required this.posting,
  });

  @override
  State<PostingGridTileUI> createState() => _PostingGridTileUIState();
}

class _PostingGridTileUIState extends State<PostingGridTileUI> {
  late PostingModel _posting;
  bool _isImageLoading = true;
  bool _hasImageError = false;

  @override
  void initState() {
    super.initState();
    _posting = widget.posting!;
    _loadPostingImage();
  }

  Future<void> _loadPostingImage() async {
    try {
      if (_posting.displayImages == null || _posting.displayImages!.isEmpty) {
        await _posting.getFirstImageFromStorage();
      }
    } catch (e) {
      debugPrint('Error loading posting image: $e');
      if (mounted) {
        setState(() {
          _hasImageError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          AspectRatio(
            aspectRatio: 3 / 2,
            child: _buildImageContainer(),
          ),
          const SizedBox(height: 8),
          // Property Type and Location
          Text(
            '${_posting.type} • ${_posting.city}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Property Name
          Text(
            _posting.name ?? 'No name',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 4),
          // Price
          Text(
            '₦${_posting.price?.toStringAsFixed(0) ?? '0'} / month',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Rating
          _buildRatingBar(),
        ],
      ),
    );
  }

  Widget _buildImageContainer() {
    if (_isImageLoading) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      );
    }

    if (_hasImageError || _posting.displayImages == null || _posting.displayImages!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image(
        image: _posting.displayImages!.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        RatingBar.builder(
          itemSize: 16,
          initialRating: _posting.getCurrentRating(),
          minRating: 1,
          maxRating: 5,
          allowHalfRating: true,
          ignoreGestures: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 1),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {},
        ),
        const SizedBox(width: 4),
        Text(
          _posting.getCurrentRating().toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}