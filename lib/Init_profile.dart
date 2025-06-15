import 'dart:ui';

import 'package:flutter/material.dart';

class InitProfile extends StatefulWidget {
  _initProfile createState() => _initProfile();
}

class _initProfile extends State<InitProfile> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String school = '';
  String bio = '';
  DateTime? moveInDate;
  DateTime? moveOutDate;

  void _saveProfile() async {
    // final isValid = _formKey.currentState!.validate();
    // if (!isValid || moveInDate == null || moveOutDate == null) return;

    // _formKey.currentState!.save();

    // final uid = FirebaseAuth.instance.currentUser?.uid;
    // await FirebaseFirestore.instance.collection('profiles').doc(uid).set({
    //   'name': name,
    //   'school': school,
    //   'bio': bio,
    //   'moveInDate': moveInDate!.toIso8601String(),
    //   'moveOutDate': moveOutDate!.toIso8601String(),
    //   'createdAt': Timestamp.now(),
    // });

    // Navigator.pushReplacementNamed(context, '/home');
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
          child: ClipRRect(
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
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSaved: (val) => name = val!,
                        validator: (val) =>
                            val!.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'School / University',
                          prefixIcon: Icon(Icons.school_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSaved: (val) => school = val!,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Short Bio',
                          prefixIcon: Icon(Icons.edit_note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSaved: (val) => bio = val!,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),

                      // Move-in / out dates
                      _buildDateSelector(
                          label: "Move-in Date",
                          date: moveInDate,
                          onTap: () => _pickDate(true)),
                      const SizedBox(height: 12),
                      _buildDateSelector(
                          label: "Move-out Date",
                          date: moveOutDate,
                          onTap: () => _pickDate(false)),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Profile & Continue",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                Icon(Icons.calendar_today, size: 20, color: Colors.indigo),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
