import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FilterPageModel extends ChangeNotifier {
  final String userId;
  double _maxDistance = 50; // in kilometers
  RangeValues _ageRange = const RangeValues(18, 50);
  List<String> _selectedGenders = [];
  List<String> _selectedLookingFor = [];
  List<String> _selectedOrientations = [];
  List<String> _selectedReligions = [];
  List<String> _interests = [];
  bool isloading = false;

  // Getters for each property
  double get maxDistance => _maxDistance;

  RangeValues get ageRange => _ageRange;

  List<String> get selectedGenders => _selectedGenders;

  List<String> get selectedLookingFor => _selectedLookingFor;

  List<String> get selectedOrientations => _selectedOrientations;

  List<String> get selectedReligions => _selectedReligions;

  List<String> get interests => _interests;

  // Setters for each property
  set maxDistance(double value) {
    _maxDistance = value;
    notifyListeners();
  }

  set ageRange(RangeValues values) {
    _ageRange = values;
    notifyListeners();
  }

  set selectedGenders(List<String> values) {
    _selectedGenders = values;
    notifyListeners();
  }

  set selectedLookingFor(List<String> values) {
    _selectedLookingFor = values;
    notifyListeners();
  }

  set selectedOrientations(List<String> values) {
    _selectedOrientations = values;
    notifyListeners();
  }

  set selectedReligions(List<String> values) {
    _selectedReligions = values;
    notifyListeners();
  }

  set interests(List<String> values) {
    _interests = values;
    notifyListeners();
  }

  String? _currentGender;
  String? _currentLookingFor;
  String? _currentOrientation;
  String? _currentReligion;

  // Getters
  String? get currentGender => _currentGender;

  String? get currentLookingFor => _currentLookingFor;

  String? get currentOrientation => _currentOrientation;

  String? get currentReligion => _currentReligion;

  // Setters
  set currentGender(String? value) {
    _currentGender = value;
    notifyListeners();
  }

  set currentLookingFor(String? value) {
    _currentLookingFor = value;
    notifyListeners();
  }

  set currentOrientation(String? value) {
    _currentOrientation = value;
    notifyListeners();
  }

  set currentReligion(String? value) {
    _currentReligion = value;
    notifyListeners();
  }

  Map<String, bool> checkboxValues = {
    'Distance': false,
    'Age Range': false,
    'Gender': false,
    'Looking For': false,
    'Orientation': false,
    'Religion': false,
    'Interests': false,
  };

  void toggleCheckbox(String key) {
    checkboxValues[key] = !checkboxValues[key]!;
    notifyListeners();
    saveFiltersToFirestore();
  }

  void clearFilters() {
    _maxDistance = 50; // You might want to keep this default value
    _ageRange = const RangeValues(18, 50);
    _selectedGenders = [];
    _selectedLookingFor = [];
    _selectedOrientations = [];
    _selectedReligions = [];
    _interests = [];
    _currentGender = null;
    _currentLookingFor = null;
    _currentOrientation = null;
    _currentReligion = null;

    // Clear the checkbox values (assuming you want to unset all checkboxes on clearing filters)
    checkboxValues.forEach((key, value) {
      checkboxValues[key] = false;
    });

    notifyListeners();
    saveFiltersToFirestore();
  }

  // Add these properties for the dropdown options
  List<String> get genderOptions => ['Male', 'Female', 'Other'];

  List<String> get lookingForOptions =>
      ['Casual', 'Dating', 'Friendship', 'Social'];

  List<String> get orientationOptions => [
        'Straight',
        'Bisexual',
        'Curious',
        'Gay',
        'Pansexual',
        'Queer',
        'Questioning',
        'Poly',
        'Fluid'
      ];

  List<String> get religionOptions => [
        'Christianity',
        'Islam',
        'Hinduism',
        'Buddhism',
        'Sikhism',
        'Judaism',
        'Atheism',
        'Other'
      ];

  List<String> get allInterests =>
      ['Music', 'Sports', 'Travel', 'Reading', 'Cooking'];

  // Add these methods for adding and removing options and interests
  void addOption(String title, String option) {
    switch (title) {
      case 'Gender':
        _selectedGenders.add(option);
        break;
      case 'Looking For':
        _selectedLookingFor.add(option);
        break;
      case 'Orientation':
        _selectedOrientations.add(option);
        break;
      case 'Religion':
        _selectedReligions.add(option);
        break;
    }
    notifyListeners();
    saveFiltersToFirestore();
  }

  void removeOption(String title, String option) {
    switch (title) {
      case 'Gender':
        _selectedGenders.remove(option);
        break;
      case 'Looking For':
        _selectedLookingFor.remove(option);
        break;
      case 'Orientation':
        _selectedOrientations.remove(option);
        break;
      case 'Religion':
        _selectedReligions.remove(option);
        break;
    }
    notifyListeners();
    saveFiltersToFirestore();
  }

  void addInterest(String interest) {
    _interests.add(interest);
    notifyListeners();
    saveFiltersToFirestore();
  }

  void removeInterest(String interest) {
    _interests.remove(interest);
    notifyListeners();
    saveFiltersToFirestore();
  }

  FilterPageModel({required this.userId});

  Future<void> saveFiltersToFirestore() async {
    isloading = true;
    notifyListeners();
    final userFiltersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('filters')
        .doc('userFilters');

    Map<String, dynamic> dataToSave = {};

    // Save or remove the data based on the checkbox status
    if (checkboxValues['Distance']!) {
      dataToSave['maxDistance'] = maxDistance;
    } else {
      dataToSave['maxDistance'] = FieldValue.delete();
    }

    if (checkboxValues['Age Range']!) {
      dataToSave['ageRangeStart'] = ageRange.start;
      dataToSave['ageRangeEnd'] = ageRange.end;
    } else {
      dataToSave['ageRangeStart'] = FieldValue.delete();
      dataToSave['ageRangeEnd'] = FieldValue.delete();
    }

    if (checkboxValues['Gender']!) {
      dataToSave['genders'] = selectedGenders;
    } else {
      dataToSave['genders'] = FieldValue.delete();
    }

    if (checkboxValues['Looking For']!) {
      dataToSave['lookingFor'] = selectedLookingFor;
    } else {
      dataToSave['lookingFor'] = FieldValue.delete();
    }

    if (checkboxValues['Orientation']!) {
      dataToSave['orientation'] = selectedOrientations;
    } else {
      dataToSave['orientation'] = FieldValue.delete();
    }

    if (checkboxValues['Religion']!) {
      dataToSave['religions'] = selectedReligions;
    } else {
      dataToSave['religions'] = FieldValue.delete();
    }

    if (checkboxValues['Interests']!) {
      dataToSave['interests'] = interests;
    } else {
      dataToSave['interests'] = FieldValue.delete();
    }

    await userFiltersRef.set(dataToSave, SetOptions(merge: true));
    isloading = false;
    notifyListeners();
  }

  Future<void> retrieveFiltersFromFirestore() async {
    isloading = true;
    notifyListeners();
    final userFiltersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('filters')
        .doc('userFilters');

    DocumentSnapshot doc = await userFiltersRef.get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;

      // Using the `containsKey` method to check for each field
      if (data.containsKey('maxDistance')) {
        maxDistance = double.tryParse((data['maxDistance'] ?? '').toString())!;
      } // You can set a default value elsewise, if needed

      if (data.containsKey('ageRangeStart') &&
          data.containsKey('ageRangeEnd')) {
        ageRange = RangeValues(data['ageRangeStart'], data['ageRangeEnd']);
      }

      if (data.containsKey('genders')) {
        selectedGenders = List<String>.from(data['genders']);
      }

      if (data.containsKey('lookingFor')) {
        selectedLookingFor = List<String>.from(data['lookingFor']);
      }

      if (data.containsKey('orientation')) {
        selectedOrientations = List<String>.from(data['orientation']);
      }

      if (data.containsKey('religions')) {
        selectedReligions = List<String>.from(data['religions']);
      }

      if (data.containsKey('interests')) {
        interests = List<String>.from(data['interests']);
      }

      // Update the checkbox values based on whether the corresponding fields are present
      checkboxValues['Distance'] = data.containsKey('maxDistance');
      checkboxValues['Age Range'] =
          data.containsKey('ageRangeStart') && data.containsKey('ageRangeEnd');
      checkboxValues['Gender'] = data.containsKey('genders');
      checkboxValues['Looking For'] = data.containsKey('lookingFor');
      checkboxValues['Orientation'] = data.containsKey('orientation');
      checkboxValues['Religion'] = data.containsKey('religions');
      checkboxValues['Interests'] = data.containsKey('interests');
    }
    isloading = false;
    notifyListeners(); // Notify the listeners after updating the state
  }
}

/*class FilterPageModel extends ChangeNotifier {
  final String userId;
  double _maxDistance = 50; // in kilometers
  RangeValues _ageRange = const RangeValues(18, 50);
  List<String> _selectedGenders = [];
  List<String> _selectedLookingFor = [];
  List<String> _selectedOrientations = [];
  List<String> _selectedReligions = [];
  List<String> _interests = [];

  // Getters for each property
  double get maxDistance => _maxDistance;

  RangeValues get ageRange => _ageRange;

  List<String> get selectedGenders => _selectedGenders;

  List<String> get selectedLookingFor => _selectedLookingFor;

  List<String> get selectedOrientations => _selectedOrientations;

  List<String> get selectedReligions => _selectedReligions;

  List<String> get interests => _interests;

  // Setters for each property
  set maxDistance(double value) {
    _maxDistance = value;
    notifyListeners();
  }

  set ageRange(RangeValues values) {
    _ageRange = values;
    notifyListeners();
  }

  set selectedGenders(List<String> values) {
    _selectedGenders = values;
    notifyListeners();
  }

  set selectedLookingFor(List<String> values) {
    _selectedLookingFor = values;
    notifyListeners();
  }

  set selectedOrientations(List<String> values) {
    _selectedOrientations = values;
    notifyListeners();
  }

  set selectedReligions(List<String> values) {
    _selectedReligions = values;
    notifyListeners();
  }

  set interests(List<String> values) {
    _interests = values;
    notifyListeners();
  }

  String? _currentGender;
  String? _currentLookingFor;
  String? _currentOrientation;
  String? _currentReligion;

  // Getters
  String? get currentGender => _currentGender;

  String? get currentLookingFor => _currentLookingFor;

  String? get currentOrientation => _currentOrientation;

  String? get currentReligion => _currentReligion;

  // Setters
  set currentGender(String? value) {
    _currentGender = value;
    notifyListeners();
  }

  set currentLookingFor(String? value) {
    _currentLookingFor = value;
    notifyListeners();
  }

  set currentOrientation(String? value) {
    _currentOrientation = value;
    notifyListeners();
  }

  set currentReligion(String? value) {
    _currentReligion = value;
    notifyListeners();
  }

  Map<String, bool> checkboxValues = {
    'Distance': false,
    'Age Range': false,
    'Gender': false,
    'Looking For': false,
    'Orientation': false,
    'Religion': false,
    'Interests': false,
  };

  void toggleCheckbox(String key) {
    checkboxValues[key] = !checkboxValues[key]!;
    notifyListeners();
    saveFiltersToFirestore();
  }

  void clearFilters() {
    _maxDistance = 50; // You might want to keep this default value
    _ageRange = const RangeValues(18, 50);
    _selectedGenders = [];
    _selectedLookingFor = [];
    _selectedOrientations = [];
    _selectedReligions = [];
    _interests = [];
    _currentGender = null;
    _currentLookingFor = null;
    _currentOrientation = null;
    _currentReligion = null;

    // Clear the checkbox values (assuming you want to unset all checkboxes on clearing filters)
    checkboxValues.forEach((key, value) {
      checkboxValues[key] = false;
    });

    notifyListeners();
    saveFiltersToFirestore();
  }

  // Add these properties for the dropdown options
  List<String> get genderOptions => ['Male', 'Female', 'Other'];

  List<String> get lookingForOptions =>
      ['Casual', 'Dating', 'Friendship', 'Social'];

  List<String> get orientationOptions => [
        'Straight',
        'Bisexual',
        'Curious',
        'Gay',
        'Pansexual',
        'Queer',
        'Questioning',
        'Poly',
        'Fluid'
      ];

  List<String> get religionOptions => [
        'Christianity',
        'Islam',
        'Hinduism',
        'Buddhism',
        'Sikhism',
        'Judaism',
        'Atheism',
        'Other'
      ];

  List<String> get allInterests =>
      ['Music', 'Sports', 'Travel', 'Reading', 'Cooking'];

  // Add these methods for adding and removing options and interests
  void addOption(String title, String option) {
    switch (title) {
      case 'Gender':
        _selectedGenders.add(option);
        break;
      case 'Looking For':
        _selectedLookingFor.add(option);
        break;
      case 'Orientation':
        _selectedOrientations.add(option);
        break;
      case 'Religion':
        _selectedReligions.add(option);
        break;
    }
    notifyListeners();
    saveFiltersToFirestore();
  }

  void removeOption(String title, String option) {
    switch (title) {
      case 'Gender':
        _selectedGenders.remove(option);
        break;
      case 'Looking For':
        _selectedLookingFor.remove(option);
        break;
      case 'Orientation':
        _selectedOrientations.remove(option);
        break;
      case 'Religion':
        _selectedReligions.remove(option);
        break;
    }
    notifyListeners();
    saveFiltersToFirestore();
  }

  void addInterest(String interest) {
    _interests.add(interest);
    notifyListeners();
    saveFiltersToFirestore();
  }

  void removeInterest(String interest) {
    _interests.remove(interest);
    notifyListeners();
    saveFiltersToFirestore();
  }

  FilterPageModel({required this.userId});

  Future<void> saveFiltersToFirestore() async {
    final userFiltersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('filters')
        .doc('userFilters');

    Map<String, dynamic> dataToSave = {};

    // Save or remove the data based on the checkbox status
    if (checkboxValues['Distance']!) {
      dataToSave['maxDistance'] = maxDistance;
    } else {
      dataToSave['maxDistance'] = FieldValue.delete();
    }

    if (checkboxValues['Age Range']!) {
      dataToSave['ageRangeStart'] = ageRange.start;
      dataToSave['ageRangeEnd'] = ageRange.end;
    } else {
      dataToSave['ageRangeStart'] = FieldValue.delete();
      dataToSave['ageRangeEnd'] = FieldValue.delete();
    }

    if (checkboxValues['Gender']!) {
      dataToSave['genders'] = selectedGenders;
    } else {
      dataToSave['genders'] = FieldValue.delete();
    }

    if (checkboxValues['Looking For']!) {
      dataToSave['lookingFor'] = selectedLookingFor;
    } else {
      dataToSave['lookingFor'] = FieldValue.delete();
    }

    if (checkboxValues['Orientation']!) {
      dataToSave['orientation'] = selectedOrientations;
    } else {
      dataToSave['orientation'] = FieldValue.delete();
    }

    if (checkboxValues['Religion']!) {
      dataToSave['religions'] = selectedReligions;
    } else {
      dataToSave['religions'] = FieldValue.delete();
    }

    if (checkboxValues['Interests']!) {
      dataToSave['interests'] = interests;
    } else {
      dataToSave['interests'] = FieldValue.delete();
    }

    await userFiltersRef.set(dataToSave, SetOptions(merge: true));
  }

  Future<void> retrieveFiltersFromFirestore() async {
    final userFiltersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('filters')
        .doc('userFilters');

    DocumentSnapshot doc = await userFiltersRef.get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;

      // Using the `containsKey` method to check for each field
      if (data.containsKey('maxDistance')) {
        maxDistance = data['maxDistance'];
      } // You can set a default value elsewise, if needed

      if (data.containsKey('ageRangeStart') &&
          data.containsKey('ageRangeEnd')) {
        ageRange = RangeValues(data['ageRangeStart'], data['ageRangeEnd']);
      }

      if (data.containsKey('genders')) {
        selectedGenders = List<String>.from(data['genders']);
      }

      if (data.containsKey('lookingFor')) {
        selectedLookingFor = List<String>.from(data['lookingFor']);
      }

      if (data.containsKey('orientation')) {
        selectedOrientations = List<String>.from(data['orientation']);
      }

      if (data.containsKey('religions')) {
        selectedReligions = List<String>.from(data['religions']);
      }

      if (data.containsKey('interests')) {
        interests = List<String>.from(data['interests']);
      }

      // Update the checkbox values based on whether the corresponding fields are present
      checkboxValues['Distance'] = data.containsKey('maxDistance');
      checkboxValues['Age Range'] =
          data.containsKey('ageRangeStart') && data.containsKey('ageRangeEnd');
      checkboxValues['Gender'] = data.containsKey('genders');
      checkboxValues['Looking For'] = data.containsKey('lookingFor');
      checkboxValues['Orientation'] = data.containsKey('orientation');
      checkboxValues['Religion'] = data.containsKey('religions');
      checkboxValues['Interests'] = data.containsKey('interests');
    }

    notifyListeners(); // Notify the listeners after updating the state
  }
}
*/
