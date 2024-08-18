import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String userId, File image) async {
    final storageRef =
        _storage.ref().child('allUserImages/$userId/profileImage.png');

    final uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() => null);

    final imageUrl = await storageRef.getDownloadURL();
    return imageUrl;
  }

  Future<String> uploadImageToFirebase(
      String userId, File image, int index) async {
    if (kDebugMode) {
      print('uploadImageToFirebase called');
    }

    try {
      if (kDebugMode) {
        print('Image is not null');
      }

      Reference storageReference = _storage.ref().child(
          'allUserImages/$userId/images/${DateTime.now().millisecondsSinceEpoch}_image$index.jpg');

      final UploadTask uploadTask = storageReference.putFile(image);

      final TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to upload image to Firebase Storage. Error: $e');
      }
      return 'error';
    }
  }

  Future<List<String>> fetchImageUrls(String userId) async {
    List<String> imageUrls = [];
    try {
      final ListResult result =
          await _storage.ref('allUserImages/$userId/images').listAll();

      for (var ref in result.items) {
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch images from Firebase Storage. Error: $e');
      }
      // You may want to handle the error more gracefully
    }
    return imageUrls;
  }

  Future<void> removeImage(String imageUrl) async {
    try {
      // Create a reference to the file to be deleted
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.refFromURL(imageUrl);

      // Delete the file
      await ref.delete();

      // Note: If there's any other related data in Firestore or another database,
      // you should update or delete that data here as well.
    } catch (e) {
      if (kDebugMode) {
        print('Error removing image from Firebase Storage: $e');
      }
      // Handle any errors here, such as showing an error message to the user.
    }
  }
}
