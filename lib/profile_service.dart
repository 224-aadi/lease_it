import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save or update user profile
  Future<void> saveProfile(Map<String, dynamic> profileData) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Add user ID and email to profile data
    profileData['userId'] = user.uid;
    profileData['email'] = user.email;
    profileData['updatedAt'] = Timestamp.now();

    // If this is a new profile, add createdAt timestamp
    if (!profileData.containsKey('createdAt')) {
      profileData['createdAt'] = Timestamp.now();
    }

    await _firestore
        .collection('profiles')
        .doc(user.uid)
        .set(profileData, SetOptions(merge: true));
  }

  // Get user profile
  Future<Map<String, dynamic>?> getProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final doc = await _firestore
        .collection('profiles')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Check if user has a profile
  Future<bool> hasProfile() async {
    final profile = await getProfile();
    return profile != null;
  }

  // Update specific fields in profile
  Future<void> updateProfileFields(Map<String, dynamic> fields) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    fields['updatedAt'] = Timestamp.now();

    await _firestore
        .collection('profiles')
        .doc(user.uid)
        .update(fields);
  }

  // Delete user profile
  Future<void> deleteProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await _firestore
        .collection('profiles')
        .doc(user.uid)
        .delete();
  }

  // Get all profiles (for matching/searching)
  Stream<QuerySnapshot> getAllProfiles() {
    return _firestore
        .collection('profiles')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Search profiles by criteria
  Future<QuerySnapshot> searchProfiles({
    String? location,
    String? apartmentType,
    String? lookingFor,
    int? minAge,
    int? maxAge,
  }) async {
    Query query = _firestore.collection('profiles');

    if (location != null && location.isNotEmpty) {
      query = query.where('preferredLocation', isEqualTo: location);
    }

    if (apartmentType != null && apartmentType != 'Any') {
      query = query.where('apartmentType', isEqualTo: apartmentType);
    }

    if (lookingFor != null && lookingFor.isNotEmpty) {
      query = query.where('lookingFor', isEqualTo: lookingFor);
    }

    if (minAge != null) {
      query = query.where('minAge', isGreaterThanOrEqualTo: minAge);
    }

    if (maxAge != null) {
      query = query.where('maxAge', isLessThanOrEqualTo: maxAge);
    }

    return await query.get();
  }
} 