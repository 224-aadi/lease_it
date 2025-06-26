import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lease_it/main_navigation.dart';
import 'package:lease_it/profile_service.dart';

class InitProfile extends StatefulWidget {
  const InitProfile({Key? key}) : super(key: key);

  @override
  _initProfile createState() => _initProfile();
}

class _initProfile extends State<InitProfile> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();
  bool _isLoading = false;

  String name = '';
  String school = '';
  String bio = '';
  DateTime? moveInDate;
  DateTime? moveOutDate;
  String preferredGender = 'Anyone';
  String apartmentType = 'Any';
  String furnishing = 'Any';
  RangeValues ageRange = const RangeValues(18, 30);
  String preferredLocation = '';
  List<String> lifestylePreferences = [];
  String cleanlinessLevel = '3';
  String lookingFor = 'Roommate';
  List<String> selectedLanguages = [];
  final List<String> allLanguages = ['English', 'Spanish', 'Hindi', 'Chinese', 'Other'];
  String additionalNotes = '';

  void _saveProfile() async {
    // Validate form
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      _showSnackBar('Please fill in all required fields correctly.');
      return;
    }

    // Check if dates are selected
    if (moveInDate == null || moveOutDate == null) {
      _showSnackBar('Please select both move-in and move-out dates.');
      return;
    }

    // Check if move-in date is before move-out date
    if (moveInDate!.isAfter(moveOutDate!)) {
      _showSnackBar('Move-in date must be before move-out date.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _formKey.currentState!.save();

      // Create profile data
      final profileData = {
        'name': name,
        'bio': bio,
        'moveInDate': moveInDate!.toIso8601String(),
        'moveOutDate': moveOutDate!.toIso8601String(),
        'preferredGender': preferredGender,
        'apartmentType': apartmentType,
        'furnishing': furnishing,
        'minAge': ageRange.start.round(),
        'maxAge': ageRange.end.round(),
        'preferredLocation': preferredLocation,
        'lifestyle': lifestylePreferences,
        'cleanlinessLevel': cleanlinessLevel,
        'lookingFor': lookingFor,
        'languages': selectedLanguages,
        'notes': additionalNotes,
      };

      // Save to Firestore using ProfileService
      await _profileService.saveProfile(profileData);

      // Show success message
      if (mounted) {
        _showSnackBar('Profile saved successfully!', isError: false);
        
        // Navigate to main navigation after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const MainNavigation()));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error saving profile: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          moveInDate = picked;
        } else {
          moveOutDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    return date == null ? 'Not selected' : '${date.toLocal()}'.split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 123, 255, 7),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children:[
              Container(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                "Build Your Profile",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      _buildTextField('Full Name', Icons.person, (val) => name = val!),
                      const SizedBox(height: 16),
                      // _buildTextField('School / University', Icons.school, (val) => school = val!),
                      const SizedBox(height: 16),
                      _buildTextField('Short Bio', Icons.edit_note, (val) => bio = val!, maxLines: 2),
                      const SizedBox(height: 16),
                      _buildDateSelector('Move-in Date', moveInDate, () => _pickDate(true)),
                      const SizedBox(height: 12),
                      _buildDateSelector('Move-out Date', moveOutDate, () => _pickDate(false)),
                      const SizedBox(height: 16),
                      _buildDropdown('Preferred Gender', ['Anyone', 'Men', 'Women'], preferredGender, (val) => setState(() => preferredGender = val!)),
                      const SizedBox(height: 16),
                      _buildDropdown('Apartment Type', ['Any', 'Studio', '1BHK', '2BHK', 'Shared', 'Private'], apartmentType, (val) => setState(() => apartmentType = val!)),
                      const SizedBox(height: 16),
                      _buildDropdown('Furnishing', ['Any', 'Furnished', 'Semi-Furnished', 'Unfurnished'], furnishing, (val) => setState(() => furnishing = val!)),
                      const SizedBox(height: 16),
                      Text('Preferred Age Range: ${ageRange.start.round()} - ${ageRange.end.round()}', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                      RangeSlider(
                        values: ageRange,
                        min: 18,
                        max: 60,
                        divisions: 42,
                        onChanged: (val) => setState(() => ageRange = val),
                        labels: RangeLabels('${ageRange.start.round()}', '${ageRange.end.round()}'),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Preferred Location / Zip Code', Icons.location_on, (val) => preferredLocation = val!),
                      const SizedBox(height: 16),
                      Text('Lifestyle Preferences:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Wrap(
                        spacing: 8,
                        children: ['Smoker', 'Non-smoker', 'Early bird', 'Night owl', 'Quiet', 'Social', 'Pets', 'No pets']
                            .map((item) => FilterChip(
                                  label: Text(item),
                                  selected: lifestylePreferences.contains(item),
                                  onSelected: (val) => setState(() {
                                    val ? lifestylePreferences.add(item) : lifestylePreferences.remove(item);
                                  }),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown('Cleanliness Level (1-5)', ['1', '2', '3', '4', '5'], cleanlinessLevel, (val) => setState(() => cleanlinessLevel = val!)),
                      const SizedBox(height: 16),
                      _buildDropdown('Looking For', ['Roommate', 'Subletter', 'Both'], lookingFor, (val) => setState(() => lookingFor = val!)),
                      const SizedBox(height: 16),
                      Text('Languages Spoken:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Wrap(
                        spacing: 8,
                        children: allLanguages.map((lang) => FilterChip(
                          label: Text(lang),
                          selected: selectedLanguages.contains(lang),
                          onSelected: (val) => setState(() {
                            val ? selectedLanguages.add(lang) : selectedLanguages.remove(lang);
                          }),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('Any other notes or preferences?', Icons.notes, (val) => additionalNotes = val!, maxLines: 3),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50), 
                          backgroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isLoading 
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text('Saving...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            )
                          : Text('Save Profile & Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, FormFieldSetter<String> onSave, {int maxLines = 1}) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
      onSaved: onSave,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown(String label, List<String> options, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      value: value,
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[100],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(date),
                  style: TextStyle(
                    fontSize: 15,
                    color: date == null ? Colors.grey : Colors.black,
                  ),
                ),
                Icon(Icons.calendar_today, size: 20, color: Colors.black),
              ],
            ),
          ),
        ),
      ],
    );
  }
}