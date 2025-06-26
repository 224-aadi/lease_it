import 'package:flutter/material.dart';
import 'package:lease_it/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSearch extends StatefulWidget {
  const ProfileSearch({Key? key}) : super(key: key);

  @override
  _ProfileSearchState createState() => _ProfileSearchState();
}

class _ProfileSearchState extends State<ProfileSearch> {
  final ProfileService _profileService = ProfileService();
  List<DocumentSnapshot> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  // Search filters
  String _selectedLocation = '';
  String _selectedApartmentType = 'Any';
  String _selectedLookingFor = 'Roommate';
  RangeValues _ageRange = const RangeValues(18, 30);

  final List<String> _locations = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'];
  final List<String> _apartmentTypes = ['Any', 'Studio', '1BHK', '2BHK', 'Shared', 'Private'];
  final List<String> _lookingForOptions = ['Roommate', 'Subletter', 'Both'];

  @override
  void initState() {
    super.initState();
    _searchProfiles();
  }

  Future<void> _searchProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _profileService.searchProfiles(
        location: _selectedLocation.isEmpty ? null : _selectedLocation,
        apartmentType: _selectedApartmentType == 'Any' ? null : _selectedApartmentType,
        lookingFor: _selectedLookingFor,
        minAge: _ageRange.start.round(),
        maxAge: _ageRange.end.round(),
      );

      if (mounted) {
        setState(() {
          _searchResults = results.docs;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Roommates'),
        backgroundColor: const Color.fromARGB(255, 123, 255, 7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _searchProfiles,
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 123, 255, 7),
      body: Column(
        children: [
          _buildSearchFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: $_error'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _searchProfiles,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _searchResults.isEmpty
                        ? const Center(
                            child: Text('No profiles found matching your criteria.'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final profile = _searchResults[index].data() as Map<String, dynamic>;
                              return _buildProfileCard(profile);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Search Filters',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            
            // Location filter
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
              value: _selectedLocation.isEmpty ? null : _selectedLocation,
              items: [
                const DropdownMenuItem(value: '', child: Text('Any Location')),
                ..._locations.map((location) => DropdownMenuItem(
                  value: location,
                  child: Text(location),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value ?? '';
                });
                _searchProfiles();
              },
            ),
            const SizedBox(height: 16),

            // Apartment type filter
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Apartment Type',
                border: OutlineInputBorder(),
              ),
              value: _selectedApartmentType,
              items: _apartmentTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedApartmentType = value!;
                });
                _searchProfiles();
              },
            ),
            const SizedBox(height: 16),

            // Looking for filter
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Looking For',
                border: OutlineInputBorder(),
              ),
              value: _selectedLookingFor,
              items: _lookingForOptions.map((option) => DropdownMenuItem(
                value: option,
                child: Text(option),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLookingFor = value!;
                });
                _searchProfiles();
              },
            ),
            const SizedBox(height: 16),

            // Age range filter
            Text('Age Range: ${_ageRange.start.round()} - ${_ageRange.end.round()}'),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 60,
              divisions: 42,
              onChanged: (values) {
                setState(() {
                  _ageRange = values;
                });
              },
              onChangeEnd: (values) {
                _searchProfiles();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                    (profile['name'] as String?)?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile['name'] ?? 'Anonymous',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Looking for: ${profile['lookingFor'] ?? 'Not specified'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (profile['bio'] != null && profile['bio'].isNotEmpty)
              Text(
                profile['bio'],
                style: const TextStyle(fontSize: 14),
              ),
            
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              children: [
                if (profile['preferredLocation'] != null && profile['preferredLocation'].isNotEmpty)
                  Chip(
                    label: Text('📍 ${profile['preferredLocation']}'),
                    backgroundColor: Colors.blue[100],
                  ),
                if (profile['apartmentType'] != null && profile['apartmentType'] != 'Any')
                  Chip(
                    label: Text('🏠 ${profile['apartmentType']}'),
                    backgroundColor: Colors.green[100],
                  ),
                if (profile['minAge'] != null && profile['maxAge'] != null)
                  Chip(
                    label: Text('👤 ${profile['minAge']}-${profile['maxAge']} years'),
                    backgroundColor: Colors.orange[100],
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement contact functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Contact'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement view full profile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Full profile view coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('View Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 