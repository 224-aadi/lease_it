# Cloud Firestore Integration Guide

This guide explains how to store and retrieve init_profile data using Cloud Firestore in your LeaseIT app.

## Overview

The app uses Cloud Firestore to store user profile information, including personal details, preferences, and search criteria. The integration includes:

- **ProfileService**: A service class that handles all Firestore operations
- **InitProfile**: Form to create/update user profiles
- **ProfileViewer**: Display user's own profile
- **ProfileSearch**: Search and browse other user profiles

## Database Structure

### Collection: `profiles`
Each user profile is stored as a document with the user's UID as the document ID.

#### Document Fields:
```json
{
  "name": "string",
  "bio": "string",
  "moveInDate": "ISO8601 string",
  "moveOutDate": "ISO8601 string",
  "preferredGender": "string",
  "apartmentType": "string",
  "furnishing": "string",
  "minAge": "number",
  "maxAge": "number",
  "preferredLocation": "string",
  "lifestyle": ["array of strings"],
  "cleanlinessLevel": "string",
  "lookingFor": "string",
  "languages": ["array of strings"],
  "notes": "string",
  "userId": "string",
  "email": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Key Components

### 1. ProfileService (`lib/profile_service.dart`)

This service class provides methods for all Firestore operations:

#### Methods:
- `saveProfile(Map<String, dynamic> profileData)`: Save or update user profile
- `getProfile()`: Retrieve current user's profile
- `hasProfile()`: Check if user has a profile
- `updateProfileFields(Map<String, dynamic> fields)`: Update specific fields
- `deleteProfile()`: Delete user profile
- `getAllProfiles()`: Get all profiles (for admin/matching)
- `searchProfiles({...})`: Search profiles by criteria

#### Usage Example:
```dart
final profileService = ProfileService();

// Save profile
await profileService.saveProfile({
  'name': 'John Doe',
  'bio': 'Looking for a roommate',
  // ... other fields
});

// Get profile
final profile = await profileService.getProfile();

// Search profiles
final results = await profileService.searchProfiles(
  location: 'New York',
  apartmentType: 'Studio',
  lookingFor: 'Roommate',
);
```

### 2. InitProfile (`lib/Init_profile.dart`)

The profile creation/editing form with improved features:

#### Features:
- Form validation
- Loading states
- Error handling
- Success feedback
- Automatic navigation after save

#### Key Improvements:
- Uses ProfileService for data operations
- Shows loading spinner during save
- Displays success/error messages
- Validates required fields
- Checks date logic (move-in before move-out)

### 3. ProfileViewer (`lib/profile_viewer.dart`)

Displays the current user's profile in a clean, organized format.

#### Features:
- Loads profile data from Firestore
- Displays information in organized cards
- Handles loading and error states
- Refresh functionality

### 4. ProfileSearch (`lib/profile_search.dart`)

Search and browse other user profiles with filtering capabilities.

#### Features:
- Search by location, apartment type, preferences
- Age range filtering
- Real-time search results
- Profile cards with contact options

## Usage Examples

### Creating a Profile
```dart
// Navigate to profile creation
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => InitProfile()),
);
```

### Viewing Your Profile
```dart
// Navigate to profile viewer
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProfileViewer()),
);
```

### Searching Profiles
```dart
// Navigate to profile search
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ProfileSearch()),
);
```

### Checking if User Has Profile
```dart
final profileService = ProfileService();
final hasProfile = await profileService.hasProfile();

if (hasProfile) {
  // User has profile, show profile viewer
  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileViewer()));
} else {
  // User needs to create profile
  Navigator.push(context, MaterialPageRoute(builder: (context) => InitProfile()));
}
```

## Security Rules

Make sure to set up proper Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own profile
    match /profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can read other profiles for searching
    match /profiles/{userId} {
      allow read: if request.auth != null;
    }
  }
}
```

## Error Handling

The integration includes comprehensive error handling:

- Network connectivity issues
- Authentication errors
- Invalid data validation
- Firestore permission errors

All errors are displayed to users via SnackBar messages.

## Performance Considerations

- Uses `SetOptions(merge: true)` to avoid overwriting existing data
- Implements proper loading states to prevent UI blocking
- Uses streams for real-time updates where needed
- Implements pagination for large result sets (can be added)

## Future Enhancements

1. **Real-time Updates**: Use Firestore streams for live profile updates
2. **Image Upload**: Add profile picture support with Firebase Storage
3. **Push Notifications**: Notify users of new matches
4. **Chat System**: In-app messaging between users
5. **Profile Verification**: Add verification badges
6. **Advanced Search**: Add more search filters and sorting options

## Testing

To test the integration:

1. Create a new profile using the InitProfile form
2. Verify data is saved to Firestore console
3. View your profile using ProfileViewer
4. Search for other profiles using ProfileSearch
5. Test error scenarios (no internet, invalid data, etc.)

## Troubleshooting

### Common Issues:

1. **"User not authenticated"**: Make sure user is logged in before accessing profile features
2. **"Permission denied"**: Check Firestore security rules
3. **"Network error"**: Check internet connectivity
4. **"Invalid data"**: Ensure all required fields are filled

### Debug Tips:

- Check Firestore console for data
- Use `print()` statements in ProfileService methods
- Verify Firebase configuration in `main.dart`
- Check authentication state before profile operations 