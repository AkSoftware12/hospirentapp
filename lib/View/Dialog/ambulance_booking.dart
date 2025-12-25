import 'package:flutter/material.dart';

import '../Purchase/imports.dart';

class AmbulanceBookingForm extends StatefulWidget {
  const AmbulanceBookingForm({super.key});

  @override
  _AmbulanceBookingFormState createState() => _AmbulanceBookingFormState();
}

class _AmbulanceBookingFormState extends State<AmbulanceBookingForm> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _contactNumber;
  String? _pickupLocation;
  String? _emergencyType;

  // Method to send form data to WhatsApp
  Future<void> _sendToWhatsApp() async {
    final String phoneNumber = "+916397199758"; // Replace with your WhatsApp number
    final String message = "Ambulance Booking Details:\n"
        "Name: $_name\n"
        "Contact Number: $_contactNumber\n"
        "Pickup Location: $_pickupLocation\n"
        "Emergency Type: $_emergencyType";

    final String encodedMessage = Uri.encodeComponent(message);
    final String whatsappUrl = "https://wa.me/$phoneNumber?text=$encodedMessage";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp is not installed or URL is invalid.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Book Ambulance',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Name Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value,
                ),
                const SizedBox(height: 16),
                // Contact Number Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    hintText: 'Enter your phone number',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your contact number';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  onSaved: (value) => _contactNumber = value,
                ),
                const SizedBox(height: 16),
                // Pickup Location Field
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Pickup Location',
                    hintText: 'Enter pickup address',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.location_on, color: Colors.blueAccent),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the pickup location';
                    }
                    return null;
                  },
                  onSaved: (value) => _pickupLocation = value,
                ),
                const SizedBox(height: 16),
                // Emergency Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Emergency Type',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.medical_services, color: Colors.blueAccent),
                  ),
                  items: ['General', 'Cardiac', 'Accident', 'Maternity', 'Other']
                      .map((String type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an emergency type';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _emergencyType = value;
                    });
                  },
                  onSaved: (value) => _emergencyType = value,
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          Navigator.pop(context);
                          _sendToWhatsApp();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Booking sent to WhatsApp for $_name!',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blueAccent,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}