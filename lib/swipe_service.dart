import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SwipeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Record a swipe action
  Future<void> recordSwipe({
    required String listingId,
    required bool isLiked,
    Map<String, dynamic>? listingData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final swipeData = {
      'userId': user.uid,
      'listingId': listingId,
      'isLiked': isLiked,
      'timestamp': Timestamp.now(),
      'listingData': listingData,
    };

    // Store the swipe action
    await _firestore
        .collection('swipes')
        .doc('${user.uid}_$listingId')
        .set(swipeData, SetOptions(merge: true));

    // If liked, check for potential matches
    if (isLiked) {
      await _checkForMatches(listingId, user.uid);
    }
  }

  // Check for potential matches
  Future<void> _checkForMatches(String listingId, String userId) async {
    try {
      // Get the listing details
      final listingDoc = await _firestore.collection('listings').doc(listingId).get();
      if (!listingDoc.exists) return;

      final listingData = listingDoc.data()!;
      final listingOwnerId = listingData['userId'];

      // Check if the listing owner has also liked the current user's profile
      final userProfileDoc = await _firestore.collection('profiles').doc(userId).get();
      if (!userProfileDoc.exists) return;

      // For now, we'll just store potential matches
      // In a real app, you'd implement more sophisticated matching logic
      await _firestore.collection('potential_matches').add({
        'userId1': userId,
        'userId2': listingOwnerId,
        'listingId': listingId,
        'timestamp': Timestamp.now(),
        'status': 'pending', // pending, accepted, rejected
      });
    } catch (e) {
      print('Error checking for matches: $e');
    }
  }

  // Get user's swipe history
  Future<List<Map<String, dynamic>>> getSwipeHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await _firestore
        .collection('swipes')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Check if user has already swiped on a listing
  Future<bool> hasSwipedOnListing(String listingId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore
        .collection('swipes')
        .doc('${user.uid}_$listingId')
        .get();

    return doc.exists;
  }

  // Get user's matches
  Future<List<Map<String, dynamic>>> getMatches() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await _firestore
        .collection('potential_matches')
        .where('userId1', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .get();

    final matches = <Map<String, dynamic>>[];
    
    for (final doc in snapshot.docs) {
      final matchData = doc.data();
      final otherUserId = matchData['userId2'];
      
      // Get the other user's profile
      final profileDoc = await _firestore
          .collection('profiles')
          .doc(otherUserId)
          .get();
      
      if (profileDoc.exists) {
        matches.add({
          ...matchData,
          'otherUserProfile': profileDoc.data(),
        });
      }
    }

    return matches;
  }

  // Get potential matches (pending)
  Future<List<Map<String, dynamic>>> getPotentialMatches() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final snapshot = await _firestore
        .collection('potential_matches')
        .where('userId1', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Accept or reject a potential match
  Future<void> respondToMatch(String matchId, bool accept) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('potential_matches')
        .doc(matchId)
        .update({
          'status': accept ? 'accepted' : 'rejected',
          'respondedAt': Timestamp.now(),
        });
  }

  // Get analytics for the user
  Future<Map<String, dynamic>> getSwipeAnalytics() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final swipesSnapshot = await _firestore
        .collection('swipes')
        .where('userId', isEqualTo: user.uid)
        .get();

    final totalSwipes = swipesSnapshot.docs.length;
    final likedSwipes = swipesSnapshot.docs
        .where((doc) => doc.data()['isLiked'] == true)
        .length;

    final matchesSnapshot = await _firestore
        .collection('potential_matches')
        .where('userId1', isEqualTo: user.uid)
        .where('status', isEqualTo: 'accepted')
        .get();

    return {
      'totalSwipes': totalSwipes,
      'likedSwipes': likedSwipes,
      'rejectedSwipes': totalSwipes - likedSwipes,
      'matches': matchesSnapshot.docs.length,
      'likePercentage': totalSwipes > 0 ? (likedSwipes / totalSwipes * 100).round() : 0,
    };
  }
} 