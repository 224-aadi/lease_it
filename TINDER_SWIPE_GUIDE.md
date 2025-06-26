# Tinder-like Swiping Feature Guide

This guide explains the implementation of a modern, Tinder-like swiping interface for your LeaseIT app.

## 🎯 Features Implemented

### 1. **Smooth Swipe Animations**
- Drag to swipe left/right
- Rotation and scaling animations
- Visual feedback with LIKE/NOPE indicators
- Smooth card transitions

### 2. **Beautiful Card Design**
- Modern gradient backgrounds
- High-quality images from Unsplash
- Detailed listing information
- Price and location badges
- Amenities display

### 3. **Firestore Integration**
- Swipe actions stored in database
- User interaction tracking
- Potential matching system
- Analytics and statistics

### 4. **Dynamic Content**
- Real-time data loading
- Infinite scrolling
- Progress indicators
- Empty state handling

## 🏗️ Architecture

### Core Components

#### 1. **SwipeableCard** (`lib/swipeable_card.dart`)
- Custom widget for swipe gestures
- Animation controllers for smooth transitions
- Visual feedback during swipes
- Programmatic swipe control

#### 2. **ListingCard** (`lib/listing_card.dart`)
- Beautiful card design with gradients
- Image display with fallbacks
- Detailed listing information
- Responsive layout

#### 3. **SwipeService** (`lib/swipe_service.dart`)
- Firestore operations for swipes
- Match detection and management
- Analytics and statistics
- User interaction tracking

#### 4. **SampleData** (`lib/sample_data.dart`)
- Sample listings for testing
- Database population utilities
- Data management functions

## 🎨 Visual Design

### Card Layout
```
┌─────────────────────────────────┐
│  [Image with Gradient Overlay]  │
│  [Price Badge]    [Location]    │
├─────────────────────────────────┤
│  Title                          │
│  [Date] [Bed] [Bath]           │
│  Description...                 │
│  [Amenities]                    │
└─────────────────────────────────┘
```

### Color Scheme
- **Primary**: `Color.fromARGB(255, 123, 255, 7)` (Green)
- **Background**: Gradient from white to light grey
- **Accents**: Blue, Orange, Green for different amenities
- **Text**: Black87 for titles, Grey600 for descriptions

### Animations
- **Swipe Threshold**: 40% of screen width
- **Rotation**: Up to 30 degrees based on drag distance
- **Scale**: Cards scale down to 0.8 when swiped
- **Duration**: 300ms for smooth transitions

## 🔄 Swipe Mechanics

### Gesture Detection
```dart
// Swipe threshold calculation
final threshold = screenWidth * 0.4;

// Rotation based on drag
final rotation = _dragOffset.dx / screenWidth * 0.3;

// Visual feedback opacity
final likeOpacity = _dragOffset.dx > 0 ? 
    (_dragOffset.dx / screenWidth * 2).clamp(0.0, 1.0) : 0.0;
```

### Animation States
1. **Idle**: Card centered, no rotation
2. **Dragging**: Card follows finger with rotation
3. **Threshold Reached**: LIKE/NOPE indicators appear
4. **Swipe Complete**: Card animates off-screen
5. **Next Card**: New card slides into position

## 📊 Firestore Data Structure

### Collections

#### `listings`
```json
{
  "title": "Cozy Studio in Downtown",
  "description": "Beautiful studio apartment...",
  "rent": 1200,
  "location": "Downtown",
  "startDate": "2024-01-15",
  "endDate": "2024-08-15",
  "bedrooms": 0,
  "bathrooms": 1,
  "amenities": ["WiFi", "Gym", "Laundry"],
  "imageUrl": "https://...",
  "createdAt": "timestamp",
  "userId": "user_id"
}
```

#### `swipes`
```json
{
  "userId": "user_id",
  "listingId": "listing_id",
  "isLiked": true,
  "timestamp": "timestamp",
  "listingData": {...}
}
```

#### `potential_matches`
```json
{
  "userId1": "user_id",
  "userId2": "listing_owner_id",
  "listingId": "listing_id",
  "timestamp": "timestamp",
  "status": "pending"
}
```

## 🚀 Usage Instructions

### 1. **Setup Sample Data**
- Tap the "+" button in the app bar
- Sample listings will be populated in Firestore
- 8 different listings with various styles and prices

### 2. **Swipe Interactions**
- **Swipe Right**: Like the listing (green heart)
- **Swipe Left**: Pass on the listing (red X)
- **Tap Buttons**: Use the circular buttons at the bottom
- **Drag**: Interactive dragging with visual feedback

### 3. **Navigation**
- **Profile Icon**: View/edit your profile
- **Heart Icon**: View matches (coming soon)
- **Progress Bar**: Shows current position in stack

## 🎯 Key Features

### Visual Feedback
- **Like Indicator**: Green "LIKE" text appears when swiping right
- **Nope Indicator**: Red "NOPE" text appears when swiping left
- **Progress Bar**: Shows current position in the stack
- **SnackBar**: Confirmation messages for actions

### Performance Optimizations
- **Lazy Loading**: Cards load as needed
- **Image Caching**: Network images with error handling
- **Animation Optimization**: Efficient animation controllers
- **Memory Management**: Proper disposal of controllers

### Error Handling
- **Network Errors**: Graceful fallbacks for image loading
- **Firestore Errors**: User-friendly error messages
- **Empty States**: Helpful messages when no data available
- **Loading States**: Smooth loading animations

## 🔧 Customization

### Adding New Listings
```dart
await SampleData.addSingleListing({
  'title': 'Your Listing Title',
  'description': 'Your description',
  'rent': 1500,
  'location': 'Your Location',
  'startDate': '2024-01-01',
  'endDate': '2024-12-31',
  'bedrooms': 2,
  'bathrooms': 1,
  'amenities': ['WiFi', 'Parking'],
  'imageUrl': 'https://your-image-url.com',
});
```

### Customizing Animations
```dart
// In SwipeableCard
_animationController = AnimationController(
  duration: const Duration(milliseconds: 300), // Adjust timing
  vsync: this,
);
```

### Styling Cards
```dart
// In ListingCard
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(20), // Adjust corner radius
  gradient: LinearGradient(
    colors: [Colors.white, Colors.grey.shade50], // Custom colors
  ),
),
```

## 🚀 Future Enhancements

### Planned Features
1. **Matches Screen**: View and chat with matches
2. **Advanced Filters**: Filter by price, location, amenities
3. **Push Notifications**: Notify users of new matches
4. **Image Upload**: Allow users to upload listing photos
5. **Chat System**: In-app messaging between users
6. **Profile Verification**: Add verification badges
7. **Advanced Analytics**: Detailed swipe statistics

### Technical Improvements
1. **Real-time Updates**: Live updates using Firestore streams
2. **Offline Support**: Cache data for offline viewing
3. **Image Optimization**: Compress and optimize images
4. **Performance Monitoring**: Track app performance metrics
5. **A/B Testing**: Test different card designs

## 🐛 Troubleshooting

### Common Issues

1. **Cards Not Loading**
   - Check Firestore permissions
   - Verify internet connection
   - Check console for errors

2. **Swipe Not Working**
   - Ensure user is authenticated
   - Check Firestore security rules
   - Verify swipe service initialization

3. **Images Not Displaying**
   - Check image URLs are valid
   - Verify network permissions
   - Check image loading errors

4. **Animations Lagging**
   - Reduce animation complexity
   - Check device performance
   - Optimize image sizes

### Debug Tips
- Use `print()` statements in swipe methods
- Check Firestore console for data
- Monitor network requests
- Test on different devices

## 📱 Testing

### Test Scenarios
1. **Swipe Right**: Verify like is recorded
2. **Swipe Left**: Verify pass is recorded
3. **Button Taps**: Test circular buttons
4. **Empty State**: Test when no listings available
5. **Network Errors**: Test offline behavior
6. **Performance**: Test with many listings

### Sample Data
The app includes 8 sample listings with:
- Different price ranges ($900 - $3500)
- Various locations and amenities
- High-quality images from Unsplash
- Realistic descriptions and details

This implementation provides a solid foundation for a modern, engaging swiping interface that users will love! 