import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../chat/chat_widget.dart';
import '../business_profile_widget.dart';
import '../businesses.dart';
import '../../../../controllers/business_profile/business_profile_model.dart';

class BusinessProfileEditPage extends StatefulWidget {
  final String initialEmail;
  final String id;

  const BusinessProfileEditPage(
      {super.key, required this.initialEmail, required this.id});

  @override
  _BusinessProfileEditPageState createState() =>
      _BusinessProfileEditPageState();
}

class _BusinessProfileEditPageState extends State<BusinessProfileEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amenityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cuisineController = TextEditingController();

  final List<File> _imageFiles = [];
  List<String> _imageUrls = [];
  Business? _business;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
    _fetchBusinessData();
  }

  Future<void> _fetchBusinessData() async {
    final businessData =
        await Provider.of<BusinessProfileModel>(context, listen: false)
            .fetchBusiness(widget.id);

    setState(() {
      _business = businessData;

      // Check if the businessData is not null and then populate the controllers
      if (businessData != null) {
        _nameController.text = businessData.name;
        _descriptionController.text = businessData.description;
        _amenityController.text = businessData.amenity;
        _addressController.text = businessData.address;
        _websiteController.text = businessData.website;
        _emailController.text = businessData.email;
        _cuisineController.text = businessData.cuisine ?? '';
        _imageUrls = businessData.imageUrls;
      }
    });
  }

  Future<void> _pickAndUploadImage() async {
    // This will now pick, upload, and update the business object all in one go.
    await Provider.of<BusinessProfileModel>(context, listen: false)
        .addBusinessImage(_business!);
    _fetchBusinessData(); // Refresh business data to get updated image URLs
  }

  @override
  Widget build(BuildContext context) {
    if (_business == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_business!.isVerified) {
      return const Scaffold(
        body: Center(child: Text('Your business is not verified yet.')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Business Name'),
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Images
          ElevatedButton.icon(
            onPressed: _pickAndUploadImage,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Photo'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageFiles.length + _imageUrls.length,
              itemBuilder: (context, index) {
                if (index < _imageFiles.length) {
                  // Display local files
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.file(_imageFiles[index]),
                  );
                } else {
                  // Display images from Firestore URLs
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child:
                        Image.network(_imageUrls[index - _imageFiles.length]),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amenityController,
            decoration: const InputDecoration(labelText: 'Type of Business'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cuisineController,
            decoration: const InputDecoration(labelText: 'What do you offer'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Address'),
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _websiteController,
            decoration: const InputDecoration(labelText: 'Website'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            enabled: false, // Disable editing
          ),
          const SizedBox(height: 16),

          // Save Profile Button
          ElevatedButton(
            onPressed: () async {
              final business = Business(
                id: widget.id,
                name: _nameController.text,
                amenity: _amenityController.text,
                description: _descriptionController.text,
                address: _addressController.text,
                imageUrls:
                    _imageUrls, // Use the _imageUrls which has already updated URLs
                website: _websiteController.text,
                email: _emailController.text,
                cuisine: _cuisineController.text,
                isVerified: _business!.isVerified,
              );

              try {
                await Provider.of<BusinessProfileModel>(context, listen: false)
                    .saveBusinessProfile(business);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile saved successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving profile: $e')),
                );
              }
            },
            child: const Text('Save Profile'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessProfilePage(
                    business: _business!,
                    authService: authService,
                  ),
                ),
              );
            },
            child: const Text("View Business Profile Page"),
          )
        ],
      ),
    );
  }
}
