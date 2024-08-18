import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class User extends ChangeNotifier {
  // Existing attributes...
  late final String id;
  String? firstName;
  String? lastName;
  int? age;
  String? bio;
  String? mbtiType;
  String? profileImage;
  List<String>? otherImages;
  String? location;
  String? matchId;
  late String? city;
  late List<String>? connectWith;
  late List<String>? interests;
  String? subscriptionLevel;
  List<double>? oceanRawScores;

  // New attributes
  DateTime? chatSelectionsLockExpires;
  List<String> selectedChatUserIds = [];

  // Existing constructor with new parameters
  User({
    required this.id,
    this.firstName,
    this.lastName,
    this.age,
    this.bio,
    this.mbtiType,
    this.profileImage,
    this.otherImages,
    this.location,
    this.matchId,
    this.city,
    this.connectWith,
    this.interests,
    this.subscriptionLevel = 'Free',
    this.oceanRawScores,
    this.chatSelectionsLockExpires,
    List<String>? selectedChatUserIds,
  }) : this.selectedChatUserIds = selectedChatUserIds ?? [];

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    int? age,
    String? bio,
    String? mbtiType,
    String? profileImage,
    List<String>? otherImages,
    String? location,
    String? matchId,
    String? city,
    List<String>? connectWith,
    List<String>? interests,
    String? subscriptionLevel,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      mbtiType: mbtiType ?? this.mbtiType,
      profileImage: profileImage ?? this.profileImage,
      otherImages: otherImages ?? this.otherImages,
      location: location ?? this.location,
      matchId: matchId ?? this.matchId,
      city: city ?? this.city,
      connectWith: connectWith ?? this.connectWith,
      interests: interests ?? this.interests,
      subscriptionLevel: subscriptionLevel ?? this.subscriptionLevel,
    );
  }

  User.empty([this.matchId = ''])
      : id = '',
        firstName = '',
        lastName = '',
        age = 0,
        mbtiType = '',
        profileImage = '',
        otherImages = const [],
        bio = '',
        location = '',
        city = '',
        connectWith = [],
        interests = [],
        subscriptionLevel = '';

  void updateUser(User newUser) {
    firstName = newUser.firstName;
    lastName = newUser.lastName;
    age = newUser.age;
    bio = newUser.bio;
    mbtiType = newUser.mbtiType;
    profileImage = newUser.profileImage;
    otherImages = newUser.otherImages;
    location = newUser.location;
    city = newUser.city;
    connectWith = newUser.connectWith;
    interests = newUser.interests;
    subscriptionLevel = newUser.subscriptionLevel;

    notifyListeners(); // Notify listeners about the change
  }

  static List<double>? _parseOceanRawScores(dynamic rawScores) {
    if (rawScores is! List<dynamic>) return null;
    var parsedScores = rawScores.map((e) => (e as num).toDouble()).toList();
    if (kDebugMode) {
      print("Parsed Ocean Raw Scores: $parsedScores");
    }
    return parsedScores;
  }

  User.fromMap(Map<String, dynamic> map, [String? matchId])
      : id = map.containsKey('uid') ? map['uid'] : map['id'] ?? '',
        subscriptionLevel = (map['subscriptionLevel'] as String?) ?? 'Free',
        firstName = (map['firstName'] as String?) ?? '',
        lastName = map.containsKey('surname')
            ? map['surname']
            : (map['lastName'] as String?) ?? '',
        age = map.containsKey('dob')
            ? ageFromDob(map['dob'])
            : (map['age'] as int?) ?? 0,
        bio = (map['bio'] as String?) ?? '',
        mbtiType = (map['mbtiType'] as String?) ?? '',
        profileImage = (map['profileImage'] as String?) ?? '',
        otherImages = (map['otherImages'] as List<dynamic>?)
                ?.map((image) => image as String)
                .toList() ??
            [],
        location = (map['location'] as String?) ?? '',
        city = (map['city'] as String?) ?? '',
        connectWith = (map['connectWith'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        interests = (map['interests'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        matchId = matchId,
        oceanRawScores = _parseOceanRawScores(map['OCEAN_raw_scores']);

  static int ageFromDob(Timestamp? dob) {
    // Might need to double check these calculations...
    return dob == null
        ? 0
        : (DateTime.now()
                    .difference(DateTime.fromMillisecondsSinceEpoch(
                        dob.millisecondsSinceEpoch))
                    .inDays /
                365)
            .ceil();
  }

  factory User.fromDocumentWithMatchId(DocumentSnapshot doc, String matchId) {
    return User(
      id: doc.id,
      firstName: doc['firstName'],
      lastName: doc['lastName'],
      profileImage: doc['profileImage'],
      mbtiType: doc['mbtiType'],
      age: doc['age'],
      location: doc['location'],
      bio: doc['bio'] ?? '',
      otherImages: (doc['otherImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      connectWith: (doc['connectWith'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      interests: (doc['interests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      matchId: matchId,
      subscriptionLevel: doc['subscriptionLevel'] ?? 'Free',
    );
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String,
        dynamic>?; // This line was missing, making `data` available.

    return User(
      id: doc.id,
      firstName: data?['firstName'],
      lastName: data?['lastName'],
      profileImage: data?['profileImage'],
      mbtiType: data?['mbtiType'],
      age: data?['age'],
      location: data?['location'],
      bio: data?['bio'],
      otherImages: List<String>.from(data?['otherImages'] ?? []),
      city: data?['city'],
      connectWith: List<String>.from(data?['connectWith'] ?? []),
      interests: List<String>.from(data?['interests'] ?? []),
      matchId:
          null, // Assuming `matchId` needs to be handled separately or isn't stored directly in the document.
      subscriptionLevel: data?['subscriptionLevel'] ?? 'Free',
      chatSelectionsLockExpires: data?['chatSelectionsLockExpires'] != null
          ? (data?['chatSelectionsLockExpires'] as Timestamp).toDate()
          : null,
      selectedChatUserIds: data?['selectedChatUserIds'] != null
          ? List<String>.from(data?['selectedChatUserIds'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'bio': bio,
      'mbtiType': mbtiType,
      'profileImage': profileImage,
      'otherImages': otherImages,
      'location': location,
      'city': city,
      'connectWith': connectWith,
      'interests': interests,
      'subscriptionLevel': subscriptionLevel,
      'selectedChatUserIds': selectedChatUserIds,
    };

    if (chatSelectionsLockExpires != null) {
      data['chatSelectionsLockExpires'] =
          Timestamp.fromDate(chatSelectionsLockExpires!);
    }

    return data;
  }

  //  method to lock chat selections
  void lockChatSelections() {
    final now = DateTime.now();
    final duration = subscriptionLevel == 'Free'
        ? Duration(hours: 48)
        : subscriptionLevel == 'Subscriber'
            ? Duration(hours: 24)
            : Duration.zero; // Premium and VIP users have immediate access
    chatSelectionsLockExpires = now.add(duration);

    notifyListeners(); // Notify listeners about the change
  }

  //  method to check if the chat selection lock is active
  bool get isChatSelectionLocked {
    if (chatSelectionsLockExpires == null) return false;
    return DateTime.now().isBefore(chatSelectionsLockExpires!);
  }

  // Method to update user's selected chats
  void updateSelectedChats(List<String> newSelectedChatUserIds) {
    if (!isChatSelectionLocked ||
        subscriptionLevel == 'Premium' ||
        subscriptionLevel == 'VIP') {
      selectedChatUserIds = newSelectedChatUserIds;
      lockChatSelections(); // Re-lock the selections based on subscription
      notifyListeners(); // Notify listeners about the change
    } else {
      if (kDebugMode) {
        print("Cannot update chat selections. Currently locked.");
      }
    }
  }
}
