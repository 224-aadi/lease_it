import 'package:flutter/material.dart';
import 'package:lease_it/profile_service.dart';
import 'package:lease_it/Init_profile.dart';

class ProfileViewer extends StatefulWidget {
  const ProfileViewer({Key? key}) : super(key: key);

  @override
  _ProfileViewerState createState() => _ProfileViewerState();
}

class _ProfileViewerState extends State<ProfileViewer> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final profile = await _profileService.getProfile();
      
      if (mounted) {
        setState(() {
          _profileData = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InitProfile()),
    ).then((_) {
      // Reload profile when returning from edit
      _loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 123, 255, 7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadProfile,
                        tooltip: 'Refresh',
                      ),
                      if (_profileData != null)
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _navigateToEditProfile,
                          tooltip: 'Edit Profile',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error: $_error',
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color.fromARGB(255, 123, 255, 7),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _profileData == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_add,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No profile found',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Please create your profile first',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _navigateToEditProfile,
                                    icon: const Icon(Icons.person_add),
                                    label: const Text('Create Profile'),
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
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildProfileCard(),
                                    const SizedBox(height: 16),
                                    _buildPreferencesCard(),
                                    const SizedBox(height: 16),
                                    _buildDatesCard(),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color.fromARGB(255, 123, 255, 7)),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', _profileData!['name'] ?? 'Not provided'),
            _buildInfoRow('Bio', _profileData!['bio'] ?? 'Not provided'),
            _buildInfoRow('Email', _profileData!['email'] ?? 'Not provided'),
            _buildInfoRow('Looking For', _profileData!['lookingFor'] ?? 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Color.fromARGB(255, 123, 255, 7)),
                const SizedBox(width: 8),
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Preferred Gender', _profileData!['preferredGender'] ?? 'Not specified'),
            _buildInfoRow('Apartment Type', _profileData!['apartmentType'] ?? 'Not specified'),
            _buildInfoRow('Furnishing', _profileData!['furnishing'] ?? 'Not specified'),
            _buildInfoRow('Age Range', '${_profileData!['minAge'] ?? 'N/A'} - ${_profileData!['maxAge'] ?? 'N/A'}'),
            _buildInfoRow('Location', _profileData!['preferredLocation'] ?? 'Not specified'),
            _buildInfoRow('Cleanliness Level', _profileData!['cleanlinessLevel'] ?? 'Not specified'),
            if (_profileData!['lifestyle'] != null && (_profileData!['lifestyle'] as List).isNotEmpty)
              _buildInfoRow('Lifestyle', (_profileData!['lifestyle'] as List).join(', ')),
            if (_profileData!['languages'] != null && (_profileData!['languages'] as List).isNotEmpty)
              _buildInfoRow('Languages', (_profileData!['languages'] as List).join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color.fromARGB(255, 123, 255, 7)),
                const SizedBox(width: 8),
                Text(
                  'Move-in/out Dates',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Move-in Date', _formatDate(_profileData!['moveInDate'])),
            _buildInfoRow('Move-out Date', _formatDate(_profileData!['moveOutDate'])),
            if (_profileData!['notes'] != null && _profileData!['notes'].isNotEmpty)
              _buildInfoRow('Additional Notes', _profileData!['notes']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Not specified';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }
} 