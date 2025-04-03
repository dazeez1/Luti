import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luti/model/app_constants.dart';
import 'package:luti/model/posting_model.dart';
import 'package:luti/view/view_posting_screen.dart';
import 'package:luti/view/widgets/posting_grid_tile_ui.dart';

class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  List<PostingModel> _savedPostings = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPostings();
  }

  Future<void> _loadSavedPostings() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Ensure user data is properly loaded
      if (AppConstants.currentUser.savedPostings == null ||
          AppConstants.currentUser.savedPostingIDs.isEmpty) {
        await AppConstants.currentUser.getSavedPostingsFromFirestore();
      }

      setState(() {
        _savedPostings = List.from(AppConstants.currentUser.savedPostings ?? []);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      Get.snackbar(
        'Error',
        'Failed to load saved listings',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _removePosting(PostingModel posting) async {
    try {
      setState(() => _isLoading = true);

      await AppConstants.currentUser.removeSavedPosting(posting);

      setState(() {
        _savedPostings.removeWhere((p) => p.id == posting.id);
        _isLoading = false;
      });

      Get.snackbar(
        'Removed',
        'Listing removed from favorites',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to remove listing',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load saved listings',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSavedPostings,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No saved listings yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Browse listings'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostingGrid() {
    return RefreshIndicator(
      onRefresh: _loadSavedPostings,
      color: Colors.blue,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _savedPostings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.75, // Adjusted for better proportions
        ),
        itemBuilder: (context, index) {
          final posting = _savedPostings[index];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => Get.to(
                      () => ViewPostingScreen(posting: posting),
                  transition: Transition.fadeIn,
                ),
                child: PostingGridTileUI(posting: posting),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _removePosting(posting),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          if (!_isLoading && _savedPostings.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadSavedPostings,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : _hasError
          ? _buildErrorState()
          : _savedPostings.isEmpty
          ? _buildEmptyState()
          : _buildPostingGrid(),
    );
  }
}