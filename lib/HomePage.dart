import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lease_it/profile_service.dart';
import 'package:lease_it/profile_viewer.dart';
import 'package:lease_it/Init_profile.dart';
import 'package:lease_it/swipeable_card.dart';
import 'package:lease_it/listing_card.dart';
import 'package:lease_it/swipe_service.dart';
import 'package:lease_it/sample_data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<DocumentSnapshot> listings = [];
  int currentIndex = 0;
  bool isLoading = true;
  bool isRefreshing = false;
  
  final ProfileService _profileService = ProfileService();
  final SwipeService _swipeService = SwipeService();
  bool hasProfile = false;

  // Animation controllers
  late AnimationController _cardAnimationController;
  late AnimationController _buttonAnimationController;
  Animation<double>? _buttonScaleAnimation;

  // Swipe card keys for programmatic control
  final List<GlobalKey<SwipeableCardState>> _cardKeys = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkProfileAndLoadListings();
  }

  void _initializeAnimations() {
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkProfileAndLoadListings() async {
    try {
      // Check if user has a profile
      final profileExists = await _profileService.hasProfile();
      
      if (mounted) {
        setState(() {
          hasProfile = profileExists;
        });
      }

      // Load listings
      await _loadListings();
    } catch (e) {
      print('Error checking profile: $e');
      await _loadListings();
    }
  }

  Future<void> _loadListings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      if (mounted) {
        setState(() {
          listings = snapshot.docs;
          isLoading = false;
          // Initialize card keys
          _cardKeys.clear();
          for (int i = 0; i < listings.length; i++) {
            _cardKeys.add(GlobalKey<SwipeableCardState>());
          }
        });
      }
    } catch (e) {
      print('Error loading listings: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshListings() async {
    setState(() {
      isRefreshing = true;
    });

    await _loadListings();

    setState(() {
      isRefreshing = false;
    });
  }

  void _onSwipeLeft() async {
    await _handleSwipe(false);
  }

  void _onSwipeRight() async {
    await _handleSwipe(true);
  }

  Future<void> _handleSwipe(bool isLiked) async {
    if (currentIndex >= listings.length) return;

    final listing = listings[currentIndex];
    final listingData = listing.data() as Map<String, dynamic>;

    try {
      // Record the swipe in Firestore
      await _swipeService.recordSwipe(
        listingId: listing.id,
        isLiked: isLiked,
        listingData: listingData,
      );

      // Show feedback
      _showSwipeFeedback(isLiked);

      // Move to next card
      setState(() {
        currentIndex++;
      });

      // If we're running low on cards, load more
      if (currentIndex >= listings.length - 3) {
        _loadMoreListings();
      }
    } catch (e) {
      print('Error recording swipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording swipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSwipeFeedback(bool isLiked) {
    final message = isLiked ? 'Liked!' : 'Passed';
    final color = isLiked ? Colors.green : Colors.red;
    final icon = isLiked ? Icons.favorite : Icons.close;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _loadMoreListings() async {
    try {
      final lastListing = listings.last;
      final snapshot = await FirebaseFirestore.instance
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastListing)
          .limit(10)
          .get();

      if (snapshot.docs.isNotEmpty && mounted) {
        setState(() {
          listings.addAll(snapshot.docs);
          // Add keys for new cards
          for (int i = 0; i < snapshot.docs.length; i++) {
            _cardKeys.add(GlobalKey<SwipeableCardState>());
          }
        });
      }
    } catch (e) {
      print('Error loading more listings: $e');
    }
  }

  void _swipeLeft() {
    if (currentIndex < listings.length && currentIndex < _cardKeys.length) {
      _cardKeys[currentIndex].currentState?.swipeLeft();
    }
  }

  void _swipeRight() {
    if (currentIndex < listings.length && currentIndex < _cardKeys.length) {
      _cardKeys[currentIndex].currentState?.swipeRight();
    }
  }

  void _navigateToCreateProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InitProfile()),
    );
  }

  Future<void> _populateSampleData() async {
    try {
      await SampleData.populateSampleListings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample data populated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh listings
      await _loadListings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error populating data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 123, 255, 7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Finding amazing places...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (currentIndex >= listings.length) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 123, 255, 7),
        body: SafeArea(
          child: Column(
            children: [
              // Header with actions
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Discover Sublets",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (!hasProfile)
                          IconButton(
                            icon: const Icon(Icons.person_add, color: Colors.white),
                            onPressed: _navigateToCreateProfile,
                            tooltip: 'Create Profile',
                          ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: _populateSampleData,
                          tooltip: 'Add Sample Data',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No more listings!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new places',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshListings,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(255, 123, 255, 7),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 123, 255, 7),
      body: SafeArea(
        child: Column(
          children: [
            // Header with actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Discover Sublets",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (!hasProfile)
                        IconButton(
                          icon: const Icon(Icons.person_add, color: Colors.white),
                          onPressed: _navigateToCreateProfile,
                          tooltip: 'Create Profile',
                        ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _populateSampleData,
                        tooltip: 'Add Sample Data',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Text(
                    '${currentIndex + 1} of ${listings.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / listings.length,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            // Cards stack
            Expanded(
              child: Stack(
                children: [
                  // Background cards
                  for (int i = currentIndex + 1; i < listings.length && i < currentIndex + 3; i++)
                    Positioned(
                      top: (i - currentIndex) * 10.0,
                      left: (i - currentIndex) * 5.0,
                      right: (i - currentIndex) * 5.0,
                      child: Transform.scale(
                        scale: 1.0 - (i - currentIndex) * 0.05,
                        child: Opacity(
                          opacity: 1.0 - (i - currentIndex) * 0.3,
                          child: SwipeableCard(
                            key: _cardKeys[i],
                            onSwipeLeft: _onSwipeLeft,
                            onSwipeRight: _onSwipeRight,
                            child: ListingCard(
                              listing: listings[i].data() as Map<String, dynamic>,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Current card
                  if (currentIndex < listings.length)
                    SwipeableCard(
                      key: _cardKeys[currentIndex],
                      onSwipeLeft: _onSwipeLeft,
                      onSwipeRight: _onSwipeRight,
                      child: ListingCard(
                        listing: listings[currentIndex].data() as Map<String, dynamic>,
                      ),
                    ),
                ],
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pass button
                  _buttonScaleAnimation != null
                      ? AnimatedBuilder(
                          animation: _buttonScaleAnimation!,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonScaleAnimation!.value,
                              child: GestureDetector(
                                onTapDown: (_) => _buttonAnimationController.forward(),
                                onTapUp: (_) => _buttonAnimationController.reverse(),
                                onTapCancel: () => _buttonAnimationController.reverse(),
                                onTap: _swipeLeft,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: _swipeLeft,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 30,
                            ),
                          ),
                        ),
                  
                  // Like button
                  _buttonScaleAnimation != null
                      ? AnimatedBuilder(
                          animation: _buttonScaleAnimation!,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _buttonScaleAnimation!.value,
                              child: GestureDetector(
                                onTapDown: (_) => _buttonAnimationController.forward(),
                                onTapUp: (_) => _buttonAnimationController.reverse(),
                                onTapCancel: () => _buttonAnimationController.reverse(),
                                onTap: _swipeRight,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: _swipeRight,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

