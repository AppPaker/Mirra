import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../controllers/home/home_page_model.dart';
import '../../../controllers/feed/feed_model.dart';

class CreatePostWidget extends StatefulWidget {
  final FeedModel feedModel;

  const CreatePostWidget({super.key, required this.feedModel});

  @override
  _CreatePostWidgetState createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends State<CreatePostWidget> {
  final TextEditingController _contentController = TextEditingController();
  String? _imageURL;

  void _showImageSourceChoice() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      _pickImage(source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Post'),
      content: SingleChildScrollView(
        // Wrap content in SingleChildScrollView
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'What\'s on your mind?',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showImageSourceChoice,
              child: const Text('Select Image'),
            ),
            if (_imageURL != null) Image.network(_imageURL!),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitPost,
          child: const Text('Post'),
        ),
      ],
    );
  }

  void _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      File file = File(image.path);
      // Obtain the current user's ID from the authentication service
      String userDocId =
          FirebaseAuth.instance.currentUser?.uid ?? 'default_user_id';

      String fileName =
          '/users/$userDocId/uploads/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      try {
        // Upload the file
        UploadTask uploadTask =
            FirebaseStorage.instance.ref(fileName).putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        // Get the URL of the uploaded image
        String uploadedImageUrl = await snapshot.ref.getDownloadURL();

        // Update the state with the new image URL
        setState(() => _imageURL = uploadedImageUrl);
      } catch (e) {
        // Handle any errors
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  void _submitPost() async {
    if (_contentController.text.isNotEmpty) {
      try {
        // Assuming you have access to an instance of HomePageViewModel or similar
        final homePageViewModel =
            Provider.of<HomePageViewModel>(context, listen: false);
        await homePageViewModel.fetchUserData(); // Fetch user data

        String userId =
            homePageViewModel.user.id; // Provide a default value if null
        String userName = homePageViewModel.user.firstName ??
            'Unknown'; // Provide a default value if null

        await widget.feedModel.addPost(
          userId, // User ID
          userName, // User first name
          _contentController.text,
          _imageURL,
        );
        Navigator.of(context).pop();
      } catch (e) {
        // Handle errors, possibly show a SnackBar or Toast
        if (kDebugMode) {
          print('Error submitting post: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
