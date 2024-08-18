import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mirra/src/app/controllers/home/home_page_model.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/components/loading_screen.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/home/home_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/map/google_places_api.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/map_model.dart';

class MapPage extends StatefulWidget {
  final String? address;
  final String? name; // Change businessName to name

  const MapPage({super.key, this.address, this.name}); // Modify this line

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapModel _model = MapModel();
  Location location = Location();
  LatLng? businessLocation;

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData; // Make this nullable

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.address != null) {
      // If address is provided, get its coordinates
      _getLatLngFromAddress(widget.address!);
    } else {
      // Else, use user's current location
      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled!) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled!) {
          // Show snackbar with a button to go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Location service is not enabled"),
              action: SnackBarAction(
                label: 'GO BACK',
                onPressed: () {
                  // Navigate back
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          // Show snackbar with a button to go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Location permission is not granted"),
              action: SnackBarAction(
                label: 'Return & enable device Location',
                onPressed: () {
                  // Navigate back
                  Navigator.of(context).pop();
                },
              ),
            ),
          );
          return;
        }
      }

      _locationData = await location.getLocation();
    }

    await _model.init(_locationData!);
    setState(() {});
  }

  void _getLatLngFromAddress(String address) async {
    List<geo.Location> locations = await geo.locationFromAddress(address);
    if (locations.isNotEmpty) {
      double latitude = locations[0].latitude;
      double longitude = locations[0].longitude;

      businessLocation = LatLng(latitude, longitude);

      _locationData = LocationData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
      });
    }
    setState(() {});
  }

  void _showAmenitiesSelector() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return ListView(
              children: supportedPlaceTypes.map((amenity) {
                return CheckboxListTile(
                  title: Text(amenity),
                  value: _model.selectedAmenities.contains(amenity),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _model.selectedAmenities.add(amenity);
                      } else {
                        _model.selectedAmenities.remove(amenity);
                      }
                    });
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );

    await _model.init(_locationData!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_locationData == null) {
      return const LoadingScreen();
    }

    return Scaffold(
        appBar: GradientAppBar(
          title: const Text("Map"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ChangeNotifierProvider<HomePageViewModel>(
                  create: (_) => HomePageViewModel(
                    authService:
                        Provider.of<AuthService>(context, listen: false),
                  ),
                  child: const HomePage(),
                ),
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<Business>>(
          future: fetchBusinessesForMap(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                // Handle the error by showing a message or just the map
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: businessLocation ??
                        LatLng(_locationData!.latitude!,
                            _locationData!.longitude!),
                    zoom: 18.0,
                  ),

                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: const <Marker>{}, // Empty set of markers
                );
              }

              Set<Marker> markers = _model.convertToMarkers(snapshot.data!);

              // Add the businessLocation marker to the set of markers.
              if (businessLocation != null) {
                markers.add(
                  Marker(
                    markerId: const MarkerId('businessLocation'),
                    position: businessLocation!,
                    infoWindow: InfoWindow(
                      title: widget.name ?? "Business",
                      snippet: widget.address ?? "Address",
                    ),
                  ),
                );
              }

              return Stack(
                children: <Widget>[
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                          _locationData!.latitude!, _locationData!.longitude!),
                      zoom: 18.0,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    markers:
                        markers, // This includes the businessLocation marker now
                  ),
                  Positioned(
                    top: 15.0,
                    left: 15.0,
                    child: FloatingActionButton(
                      backgroundColor: Colors.deepPurpleAccent,
                      onPressed: _showAmenitiesSelector,
                      child: const Icon(Icons.filter_list),
                    ),
                  ),
                ],
              );
            } else {
              return const LoadingScreen();
            }
          },
        ));
  }
}
