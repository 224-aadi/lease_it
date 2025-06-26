import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SampleData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static List<Map<String, dynamic>> sampleListings = [
    {
      'title': 'Cozy Studio in Downtown',
      'description': 'Beautiful studio apartment in the heart of downtown. Perfect for students or young professionals. Recently renovated with modern amenities.',
      'rent': 1200,
      'location': 'Downtown',
      'startDate': '2024-01-15',
      'endDate': '2024-08-15',
      'bedrooms': 0,
      'bathrooms': 1,
      'amenities': ['WiFi', 'Gym', 'Laundry', 'Parking'],
      'imageUrl': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_1',
    },
    {
      'title': 'Modern 2BR Near University',
      'description': 'Spacious 2-bedroom apartment just 5 minutes from campus. Great for roommates or small families. Includes all utilities.',
      'rent': 1800,
      'location': 'University District',
      'startDate': '2024-02-01',
      'endDate': '2024-12-31',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['WiFi', 'Dishwasher', 'Balcony', 'Storage'],
      'imageUrl': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_2',
    },
    {
      'title': 'Luxury 1BR with City View',
      'description': 'High-end 1-bedroom apartment with stunning city views. Perfect for professionals who want luxury living.',
      'rent': 2200,
      'location': 'City Center',
      'startDate': '2024-01-20',
      'endDate': '2024-06-20',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['WiFi', 'Pool', 'Gym', 'Concierge', 'Parking'],
      'imageUrl': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=2073&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_3',
    },
    {
      'title': 'Charming Garden Apartment',
      'description': 'Quiet garden apartment with private outdoor space. Perfect for nature lovers who want peace and tranquility.',
      'rent': 1400,
      'location': 'Suburbs',
      'startDate': '2024-03-01',
      'endDate': '2024-09-01',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['Garden', 'WiFi', 'Laundry', 'Parking'],
      'imageUrl': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_4',
    },
    {
      'title': 'Spacious 3BR Family Home',
      'description': 'Large family home with plenty of space for everyone. Great neighborhood with excellent schools nearby.',
      'rent': 2800,
      'location': 'Family District',
      'startDate': '2024-02-15',
      'endDate': '2024-08-15',
      'bedrooms': 3,
      'bathrooms': 2,
      'amenities': ['WiFi', 'Backyard', 'Garage', 'Fireplace'],
      'imageUrl': 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_5',
    },
    {
      'title': 'Artist Loft in Creative District',
      'description': 'Unique loft space perfect for artists and creatives. High ceilings, natural light, and inspiring atmosphere.',
      'rent': 1600,
      'location': 'Arts District',
      'startDate': '2024-01-10',
      'endDate': '2024-07-10',
      'bedrooms': 1,
      'bathrooms': 1,
      'amenities': ['High Ceilings', 'Natural Light', 'WiFi', 'Studio Space'],
      'imageUrl': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?ixlib=rb-4.0.3&auto=format&fit=crop&w=2074&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_6',
    },
    {
      'title': 'Efficient Studio for Students',
      'description': 'Compact and efficient studio perfect for students. Close to campus and public transportation.',
      'rent': 900,
      'location': 'Student Area',
      'startDate': '2024-02-01',
      'endDate': '2024-05-31',
      'bedrooms': 0,
      'bathrooms': 1,
      'amenities': ['WiFi', 'Study Desk', 'Laundry', 'Bike Storage'],
      'imageUrl': 'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_7',
    },
    {
      'title': 'Penthouse with Rooftop Access',
      'description': 'Exclusive penthouse apartment with private rooftop terrace. Breathtaking views and luxury amenities.',
      'rent': 3500,
      'location': 'Luxury District',
      'startDate': '2024-01-25',
      'endDate': '2024-12-25',
      'bedrooms': 2,
      'bathrooms': 2,
      'amenities': ['Rooftop Terrace', 'WiFi', 'Gym', 'Pool', 'Concierge'],
      'imageUrl': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
      'createdAt': Timestamp.now(),
      'userId': 'sample_user_8',
    },
  ];

  static Future<void> populateSampleListings() async {
    try {
      // Check if sample data already exists
      final existingSnapshot = await _firestore.collection('listings').limit(1).get();
      if (existingSnapshot.docs.isNotEmpty) {
        print('Sample data already exists. Skipping population.');
        return;
      }

      // Add sample listings
      for (final listing in sampleListings) {
        await _firestore.collection('listings').add(listing);
      }

      print('Successfully populated ${sampleListings.length} sample listings');
    } catch (e) {
      print('Error populating sample data: $e');
    }
  }

  static Future<void> clearAllListings() async {
    try {
      final snapshot = await _firestore.collection('listings').get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Successfully cleared all listings');
    } catch (e) {
      print('Error clearing listings: $e');
    }
  }

  static Future<void> addSingleListing(Map<String, dynamic> listing) async {
    try {
      await _firestore.collection('listings').add({
        ...listing,
        'createdAt': Timestamp.now(),
      });
      print('Successfully added new listing');
    } catch (e) {
      print('Error adding listing: $e');
    }
  }
} 