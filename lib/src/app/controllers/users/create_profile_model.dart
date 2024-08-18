import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirra/src/app/presentation/config/asset_paths.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart'as appUser;
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../presentation/screens/intro_slides/intro_slide_widget.dart';
// import '../../presentation/users/user.dart' as appUser;

class CreateProfileModel extends ChangeNotifier {
  final StorageService storageService; // inject StorageService
  final _picker = ImagePicker();

  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  String? relationshipStatus;
  DateTime? dob; // Date of Birth
  String? gender;
  File? profileImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  CreateProfileModel({
    required this.storageService,
    String? userId,
  });

  Future<void> pickImage(FormFieldState? state) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setProfileImage(pickedFile.path);
      state?.validate();
    }
  }

  void setProfileImage(String path) {
    profileImage = File(path);
    notifyListeners();
  }

  void setRelationshipStatus(String? status) {
    relationshipStatus = status;
    notifyListeners();
  }

  void setDob(DateTime? date) {
    dob = date;
    notifyListeners();
  }

  void setGender(String? gender) {
    this.gender = gender;
    notifyListeners();
  }

  Future<void> saveProfileAndNavigate(
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (formKey.currentState?.validate() == true) {
      await saveProfile(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const IntroSlideWidget()),
      );
    }
  }

  String? validateProfilePicture() {
    if (profileImage != null) {
      return null;
    }
    return 'Please select a profile picture';
  }

  Future<void> saveProfile(BuildContext context) async {
    // Access the user ID directly from the getter
    final userId = this.userId;

    // Check if userId is null or empty
    if (userId == null || userId.isEmpty) {
      // Handle this scenario gracefully. For now, I'm just printing an error.
      if (kDebugMode) {
        print('Error: User ID is null or empty');
      }
      return;
    }

    if (profileImage != null) {
      final imageURL =
          await storageService.uploadProfileImage(userId, profileImage!);
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'firstName': firstNameController.text,
        'surname': surnameController.text,
        'relationshipStatus': relationshipStatus,
        'dob': dob,
        'gender': gender,
        'profileImage': imageURL,
      }, SetOptions(merge: true));

      Provider.of<appUser.User>(context, listen: false).updateUser(
        appUser.User(
          id: _auth.currentUser!.uid,
          firstName: firstNameController.text,
          lastName: surnameController.text,
          profileImage: imageURL,
        ),
      );
      if (kDebugMode) {
      }
    } else {
      if (kDebugMode) {
        print('Profile image is null');
      }
    }
  }

  Future<String> uploadImageToFirebase(
      BuildContext context, File? image) async {
    if (kDebugMode) {
      print('uploadImageToFirebase called');
    }

    if (image == null) {
      if (kDebugMode) {
        print('Image is null');
      }
      // Return the path of your placeholder image
      return AssetPaths.avatarPlaceholder;
    }

    // Access the global user state to get the user's ID
    final userId = Provider.of<appUser.User>(context, listen: false).id;

    final storageReference =
        FirebaseStorage.instance.ref().child('users/$userId/profile_image.png');

    // Upload the file
    final uploadTask = storageReference.putFile(image);

    // Get the downloadable URL of the uploaded file
    final taskSnapshot = await uploadTask.whenComplete(() => null);
    final imageUrl = await taskSnapshot.ref.getDownloadURL();

    if (kDebugMode) {
      print('Image uploaded, URL: $imageUrl');
    }

    return imageUrl;
  }

  Future<void> pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
    );

    if (date != null) {
      setDob(date); // Update the dob variable
      final age = calculateAge(date);
      dateOfBirthController.text = age.toString(); // Update to store only age
    }
  }

  int calculateAge(DateTime birthDate) {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    final month1 = currentDate.month;
    final month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      final day1 = currentDate.day;
      final day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }
}
