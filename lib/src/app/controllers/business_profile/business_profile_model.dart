import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../presentation/screens/businesses/businesses.dart';

class BusinessProfileModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _email;
  String? _id;

  String? get email => _email;

  String? get id => _id;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setId(String id) {
    _id = id;
    notifyListeners();
  }

  Future<Business?> fetchBusiness(String id) async {
    final doc = await _firestore.collection('businesses').doc(id).get();
    if (doc.exists) {
      return Business.fromMap(doc.data()!);
    }
    return null;
  }

  Future<String> uploadImage(File imageFile, String id) async {
    try {
      final ref = _storage
          .ref()
          .child('business_images')
          .child(id)
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<void> addBusinessImage(Business business) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String imageUrl = await uploadImage(imageFile, business.id);
      List<String> currentImageUrls = business.imageUrls;
      currentImageUrls.add(imageUrl);
      business.imageUrls = currentImageUrls;
      await saveBusinessProfile(business);
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  Future<void> saveBusinessProfile(Business business) async {
    try {
      await _firestore
          .collection('businesses')
          .doc(business.id)
          .set(business.toMap());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }
}
