import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:mirra/src/app/controllers/users/profile_page_viewmodel.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';

List<String> interests = [
  'Arts',
  'Sports',
  'Exercise',
  'R&R',
  'Other',
  // ... add more interests as needed
];

Future<List<String>> getCities(String pattern) async {
  final response = await http.get(Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$pattern&types=(cities)&key=AIzaSyC-RQS9nE4yVQLyYjNeq6zoBDd4JtpKHdg'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final predictions = data['predictions'] as List;
    return predictions.map((city) => city['description'] as String).toList();
  } else {
    throw Exception('Failed to load cities');
  }
}

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({super.key, required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _bioController;
  String? selectedCity;
  List<String> selectedConnectWith = [];
  List<String> selectedInterests = [];
  final TextEditingController _cityController = TextEditingController();

  bool _isDataLoaded = false; // Flag to check if data is loaded

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController();
    _initializeUserData(); // Only initialize, don't load data here
  }

  Future<void> _initializeUserData() async {
    if (!_isDataLoaded) {
      // Load data only if it's not already loaded
      await _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final model = Provider.of<ProfilePageViewModel>(context, listen: false);
      await model.fetchUserData();
      setState(() {
        _bioController.text = model.user.bio!;
        selectedCity = model.user.city;
        selectedConnectWith = model.user.connectWith ?? [];
        selectedInterests = model.user.interests ?? [];
        _cityController.text = selectedCity ?? '';
        _isDataLoaded = true; // Set flag to true after data is loaded
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isDataLoaded = false; // Reset flag to allow reloading
              });
              _loadUserData();
            },
          ),
        ],
      ),
      body: _isDataLoaded
          ? _buildProfileForm(context) // If data is loaded, build form
          : FutureBuilder(
              future: _initializeUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return _buildProfileForm(context); // Build form after data load
              },
            ),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    final model = Provider.of<ProfilePageViewModel>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: model.updateProfileImage,
              child: model.user.profileImage?.isNotEmpty ?? false
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(360),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(360),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: model.user.profileImage ?? '',
                          fit: BoxFit.fill,
                          height: kPadding13,
                          width: kPadding13,
                        ),
                      ),
                    )
                  : const Icon(Icons.add_a_photo,
                      size: 50.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            GestureDetector(
              onTap: model.addOtherImage,
              child:
                  const Icon(Icons.add_a_photo, size: 50.0, color: Colors.grey),
            ),
            Wrap(
              children: model.user.otherImages?.map((imageUrl) {
                    return _buildImageItem(imageUrl, model);
                  }).toList() ??
                  [],
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kPadding3)),
                  contentPadding: const EdgeInsets.all(kPadding3)),
              scrollPadding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: kPadding4),
            const Text("City",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return getCities(textEditingValue.text);
              },
              onSelected: (String selection) {
                setState(() {
                  selectedCity = selection;
                });
              },
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Select your city',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kPadding3),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                40,
                0,
                3,
              ),
              child: Text(
                "Who do you want to connect with:",
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ),
            MultiSelectDialogField(
              items: [
                'Male',
                'Female',
                'Non-Binary',
                'Other'
              ] //TODO: ADD Typable Gender
                  .map((e) => MultiSelectItem(e, e))
                  .toList(),
              title: Text("Connect With",
                  style: Theme.of(context).textTheme.titleMedium),
              selectedColor: Colors.blue,
              onConfirm: (values) {
                setState(() {
                  selectedConnectWith = values.cast<String>();
                });
              },
            ),
            const SizedBox(height: kPadding1),
            Text("Connect with: ${selectedConnectWith.join(', ')}",
                style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            const SizedBox(height: kPadding4), //TODO: ADD religion selector
            const Text("Add your interests"),
            Row(
              children: [
                Expanded(
                  flex: 2, // 2/3 of the space for the TypeAheadField
                  child: TypeAheadField<String>(
                    hideOnSelect:
                        true, // Automatically hide suggestions on selection
                    suggestionsCallback: (pattern) async {
                      return interests.any((interest) =>
                              interest.toLowerCase() == pattern.toLowerCase())
                          ? [pattern]
                          : ["Add '$pattern' to your interests"];
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSelected: (suggestion) {
                      String interestToAdd = suggestion;
                      if (suggestion.startsWith("Add '") &&
                          suggestion.endsWith("' to your interests")) {
                        interestToAdd = suggestion.substring(
                            5,
                            suggestion.length -
                                19); // Corrected substring extraction
                      }

                      if (!selectedInterests.contains(interestToAdd)) {
                        setState(() {
                          selectedInterests.add(interestToAdd);
                        });
                      }
                      model.suggestionController.clear();
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Search Interests',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(kPadding3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8.0, // Horizontal space between chips
              runSpacing: 8.0, // Vertical space between chips
              children: selectedInterests.map((interest) {
                return Chip(
                  label: Text(
                    interest,
                    style: const TextStyle(
                        fontSize: 12), // Smaller font size for chip labels
                  ),
                  onDeleted: () {
                    setState(() {
                      selectedInterests.remove(interest);
                    });
                  },
                  deleteIcon: const Icon(Icons.close, size: 10),
                  backgroundColor: kPrimaryAccentColor, // Change chip color
                  shape: const StadiumBorder(), // Change chip shape
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4), // Adjust chip padding
                );
              }).toList(),
            ),
            const SizedBox(height: 45.0),
            Row(
              children: [
                Expanded(
                  child: MirrorElevatedButton(
                    onPressed: () async {
                      try {
                        await model.fetchAndUpdateUserData(model.user.id);

                        // Use the ViewModel's method to update the user data
                        await model.updateUserData(
                            bio: _bioController.text,
                            city: selectedCity!,
                            connectWith: selectedConnectWith,
                            interests: selectedInterests);

                        Navigator.pop(context);
                      } catch (e) {
                        if (kDebugMode) {
                          print("Error updating user data: $e");
                        }
                      }
                    },
                    child: const Text("Save"),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom)
          ],
        ),
      ),
    );
  }
}

Widget _buildImageItem(String imageUrl, ProfilePageViewModel model) {
  return Stack(
    alignment: Alignment.topRight,
    children: [
      Image.network(imageUrl, width: 100, height: 100),
      IconButton(
        icon: const Icon(Icons.remove_circle),
        onPressed: () => model.removeImage(imageUrl),
      ),
    ],
  );
}
