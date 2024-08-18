import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/controllers/users/user_service.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:mirra/src/domain/firebase/cloud_firestore/real_firestore_service.dart';

import '../chat/chat_widget.dart';
import '../../../controllers/business_profile/business_profile_bloc.dart';
import 'business_profile_widget.dart';
import 'businesses.dart';
import '../../../../data/models/nearby_model.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  _NearbyPageState createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  Future<NearbyModel> modelFuture =
      Future.value(NearbyModel()); // Default state

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        modelFuture = NearbyModel.createInstance(userPosition);
      });
    } catch (e) {
      // Handle location permission error or other exceptions
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      // Optionally set modelFuture to a default state or handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: Center(child: Text('Nearby Businesses')),
      ),
      body: FutureBuilder<NearbyModel>(
        future: modelFuture,
        builder: (context, snapshot) {
          if (kDebugMode) {
            print('FutureBuilder state: ${snapshot.connectionState}');
          }

          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final model = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    // Commented out the filterBusinesses call for now
                    /* onChanged: (value) {
                      model.filterBusinesses(value);
                      setState(() {});
                    }, */
                    decoration: InputDecoration(
                      labelText: 'Search for places or food & drink',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const Text("Places to be. " "Explore The Mirra scenes"),
                Expanded(
                  child: ListView.builder(
                    itemCount: model.filteredBusinesses.length,
                    itemBuilder: (context, index) {
                      if (kDebugMode) {
                        print('Building item at index $index');
                      }

                      final business = model.filteredBusinesses[index];
                      return BusinessCard(business: business);
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class BusinessCard extends StatelessWidget {
  final Business business;

  const BusinessCard({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => BusinessProfileBloc(
                  userService: context.read<UserService>(),
                  authService: context.read<FirebaseAuthService>(),
                  firestoreService: context.read<RealFirestoreService>(),
                  notificationProvider: context.read<NotificationProvider>(),
                ),
                child: BusinessProfilePage(
                  business: business,
                  authService: authService,
                ),
              ),
            ),
          );
        },
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 300.0,
            maxHeight: 314, // Adjusted max height
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5.0,
            child: Column(
              children: [
                SizedBox(
                  height: 200.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15.0),
                    ),
                    child: PageView.builder(
                      itemCount: business.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          business.imageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child: Text('Failed to load image'));
                          },
                        );
                      },
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0), // Added padding
                    color: Colors.white,
                    child: ListTile(
                      title: Text(business.name),
                      subtitle: Text(
                          '${business.amenity} - ${business.cuisine ?? ''}'),
                      trailing: Text(
                          'Distance: ${business.distanceFromUser?.toStringAsFixed(2) ?? 'N/A'} km'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
