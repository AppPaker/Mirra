import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/components/mirror_button.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/track_a_date/pref.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

import '../users/user.dart';
import '../../../controllers/users/user_service.dart';
import 'class.dart'; // Assuming this contains DateTracker definitions
import '../../../../data/models/date_tracker_model.dart'; // Assuming this contains DateTracker model

class TrackADatePage extends StatefulWidget {
  const TrackADatePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TrackADatePageState createState() => _TrackADatePageState();
}

class _TrackADatePageState extends State<TrackADatePage> {
  final viewModel =
      DateTrackerViewModel(DateTracker(startTime: DateTime.now()));
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _trustedEmailController = TextEditingController();

  Business? selectedBusiness;
  String selectedBusinessName = '';
  String selectedBusinessAddress = '';
  String updatedLocationAddress = '';
  bool isTracking = false;
  Location location = Location();
  User? selectedMatch;
  UserService userService = UserService();
  Timer? _debounce;
  double currentLatitude = 0.0;
  double currentLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    restoreTrackingState().then((savedState) {
      if (savedState['isTracking']) {
        setState(() {
          selectedBusinessName = savedState['businessName'];
          selectedBusinessAddress = savedState['businessAddress'];
          _trustedEmailController.text = savedState['trustedEmail'];
          isTracking = true;
          viewModel.setDateDocId(savedState['dateDocId']);
          String matchedUserId = savedState['matchedUserId'];

          // and set it to selectedMatch
          if (matchedUserId.isNotEmpty) {
            userService.fetchUserById(matchedUserId).then((matchedUser) {
              setState(() {
                selectedMatch = matchedUser;
              });
            });
          }
        });
      }
    });
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    var permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    var currentLocation = await location.getLocation();
    setState(() {
      currentLatitude = currentLocation.latitude!;
      currentLongitude = currentLocation.longitude!;
    });
  }

  void _startTracking() {
    if (selectedBusiness != null) {
      viewModel.setTrustedContactEmail(_trustedEmailController.text);
      viewModel
          .startTracking(DateTime.now(), selectedBusiness!, selectedMatch)
          .then((docRef) {
        setState(() {
          isTracking = true;
        });
        saveTrackingState(selectedBusiness!.name, selectedBusiness!.address,
            _trustedEmailController.text, isTracking, docRef.id, selectedMatch);
      });
    }
  }

  void _stopTracking() {
    viewModel.stopTracking(DateTime.now()).then((_) {
      setState(() {
        isTracking = false;
      });
      clearTrackingState();
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isNotEmpty) {
        LocationData currentLocation = await location.getLocation();
        setState(() {
          viewModel.searchBusinesses(
              query, currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    });
  }

  void _updateCurrentLocation() async {
    PermissionStatus permissionGranted = await location.requestPermission();
    if (permissionGranted == PermissionStatus.granted) {
      LocationData currentLocation = await location.getLocation();

      // Convert latitude and longitude to a human-readable address

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          currentLocation.latitude!, currentLocation.longitude!);

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        String address = "${place.street}, ${place.locality}, ${place.country}";

        // Update the UI
        setState(() {
          updatedLocationAddress = address;
        });

        viewModel.updateLocationInFirestore(address);
      }
    }
  }

  void _showMatchSelectionDialog(BuildContext context) async {
    var selectedUser = await showDialog<User?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Your Match"),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<User>>(
              future: viewModel.fetchMatchedUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No matches found");
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    User match = snapshot.data![index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: match.profileImage != null
                            ? NetworkImage(match.profileImage!)
                            : null,
                      ),
                      title: Text(match.firstName ?? 'Unknown Name'),
                      subtitle: Text("${match.location} ${match.mbtiType}"),
                      onTap: () => Navigator.of(context).pop(match),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedUser != null) {
      setState(() {
        selectedMatch = selectedUser;
      });
    }
  }

  void _clearSelectedMatch() {
    setState(() {
      selectedMatch = null;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const GradientAppBar(title: Text("Track-A-Date")),
        body: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [kPurpleColor, kPrimaryAccentColor],
                center: Alignment(0, 0.3),
                radius: 3,
              ),
            ),
            child: Stack(children: [
              Opacity(
                opacity: 0.3,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: Icon(
                      Icons.safety_check,
                      size: 200,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 0.0),
                      child: Text(
                        '1. Select a location by searching for a business or address.\n'
                        '2. Pick your match by tapping the "Select Match" button.\n'
                        '3. Enter a trusted contact\'s email (optional).\n'
                        '4. Press the start button to begin tracking.\n'
                        '5. Update your location if needed by pressing the "Update Location" button.\n'
                        '6. Press the stop button when you finish tracking.\n',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: Text(
                              'Date Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              labelText:
                                  'Search for a business or address here',
                            ),
                            onChanged: _onSearchChanged,
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 8, 0, 10),
                          ),
                          MirrorElevatedButton(
                            onPressed: () => _showMatchSelectionDialog(context),
                            child: const Text('Select Match'),
                          ),
                          if (selectedMatch != null)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          selectedMatch!.profileImage ?? ''),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(selectedMatch!.firstName ??
                                              'Unknown Name'),
                                          Text(
                                              "${selectedMatch!.location} ${selectedMatch!.mbtiType}"),
                                        ],
                                      ),
                                    ),
                                    if (!isTracking)
                                      IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: _clearSelectedMatch,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          if (selectedBusinessName.isNotEmpty &&
                              selectedBusinessAddress.isNotEmpty)
                            Card(
                              child: ListTile(
                                title: Text(selectedBusinessName),
                                subtitle: Text(selectedBusinessAddress),
                              ),
                            ),
                          if (updatedLocationAddress.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "Updated Location: $updatedLocationAddress"),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: TextField(
                              controller: _trustedEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Trusted Contact Email (Optional)',
                                hintText: 'Enter email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          SizedBox(
                            height: 300, // Adjust height as needed
                            child: _searchController.text.isNotEmpty
                                ? StreamBuilder<List<Business>>(
                                    stream: viewModel.searchBusinesses(
                                      _searchController.text,
                                      currentLatitude, // State variable for current latitude
                                      currentLongitude, // State variable for current longitude
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      }
                                      if (snapshot.hasError) {
                                        if (kDebugMode) {
                                          print(
                                              'StreamBuilder error: ${snapshot.error}');
                                        } // Debug log
                                        return Text('Error: ${snapshot.error}');
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        if (kDebugMode) {
                                          print('StreamBuilder no data');
                                        } // Debug log

                                        return const Text("No results found");
                                      }
                                      if (kDebugMode) {
                                        print(
                                            'Businesses to display: ${snapshot.data}');
                                      } // Debug log

                                      return ListView.builder(
                                        itemCount: snapshot.data!.length,
                                        itemBuilder: (context, index) {
                                          Business business =
                                              snapshot.data![index];
                                          return ListTile(
                                            title: Text(business.name),
                                            subtitle: Text(business.address),
                                            // You can add more details here
                                            onTap: () {
                                              setState(() {
                                                selectedBusiness = business;
                                                selectedBusinessName =
                                                    business.name;
                                                selectedBusinessAddress =
                                                    business.address;
                                              });
                                              _searchController.clear();
                                            },
                                          );
                                        },
                                      );
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
              Positioned(
                  bottom: 50,
                  left: 50,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                      'Tracker',
                      style: TextStyle(
                        color: Colors.grey, // Adjust the color as needed
                        fontSize: 12, // Adjust the font size as needed
                      ),
                    ),
                    const SizedBox(height: 5),
                    FloatingActionButton(
                      onPressed: () {
                        if (selectedBusinessName.isNotEmpty && !isTracking) {
                          _startTracking();
                        } else if (isTracking) {
                          _stopTracking();
                        } else {
                          if (kDebugMode) {
                            print("Button pressed but no action taken.");
                          }
                        }
                      },
                      backgroundColor: isTracking
                          ? Colors.red
                          : Colors.green, // Red when tracking, green otherwise
                      shape: const StadiumBorder(),
                      child: Icon(isTracking ? Icons.stop : Icons.play_arrow),
                    ),
                  ])),
              Positioned(
                bottom: 50,
                right: 30,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    'Update Location',
                    style: TextStyle(
                      color: Colors.grey, // Adjust the color as needed
                      fontSize: 12, // Adjust the font size as needed
                    ),
                  ),
                  const SizedBox(height: 5),
                  FloatingActionButton(
                    onPressed: isTracking ? _updateCurrentLocation : null,
                    backgroundColor: Colors.orange, // Blue color for the button
                    shape: const StadiumBorder(),
                    child: const Icon(Icons.location_on),
                  ),
                ]),
              ),
            ])));
  }
}
