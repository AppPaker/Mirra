import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mirra/src/app/controllers/admanager/ad_service.dart';
import 'package:mirra/src/app/controllers/users/user_service.dart';
import 'package:mirra/src/app/presentation/components/matched_user_card.dart';
import 'package:mirra/src/app/presentation/components/ocean_dial.dart';
import 'package:mirra/src/app/presentation/components/qr_widget.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart' as user;
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:provider/provider.dart';

import '../../components/business_card.dart';
import '../../components/mirror_card.dart';
// import '../../users/user.dart' as user;

import '../businesses/business_profile_widget.dart';
import '../../../../data/models/nearby_model.dart';
import '../chat/chat_widget.dart';
import '../insights/insights_page.dart';
import '../../../../data/models/quote_viewmodel.dart';
import '../../../controllers/home/home_page_model.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required TabController tabController,
    required AdManager adManager,
  });

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<NearbyModel> modelFuture = Future.value(NearbyModel());
  late UserService userService;
  late QuoteViewModel viewModel;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    viewModel = QuoteViewModel(FirebaseAuth.instance.currentUser!.uid);
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      Position userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() {
        modelFuture = NearbyModel.createInstance(userPosition);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildFullProfile(),
        _buildAdSection(),
        _buildMatchesSection(),
        _buildNearbySection(),
        _buildMirrorCardSection(),
      ],
    );
  }

  Widget _buildFullProfile() {
    return SliverToBoxAdapter(
      child: FutureBuilder<user.User>(
        future: Provider.of<HomePageViewModel>(context, listen: false)
            .fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildFullProfileLayout(
                snapshot.data); // Your existing _buildFullProfile method
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _buildAdSection() {
    // AdManager adManager = AdManager();
    var adManager = Provider.of<AdManager>(context, listen: false);

    return SliverToBoxAdapter(
      child: adManager.isAdLoaded()
          ? adManager.getBannerAdWidget()
          : const SizedBox(height: 50), // Placeholder for unloaded ad
    );
  }

  /*Widget _buildAdSection() {
    AdManager adManager = AdManager();

    return SliverToBoxAdapter(
      child: adManager.isAdLoaded()
          ? adManager.getBannerAdWidget()
          : const SizedBox(height: 50), // Placeholder for unloaded ad
    );
  }*/

  Widget _buildMatchesSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: kPadding3, horizontal: kPadding4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Your Matches',
                  style: GoogleFonts.lato(
                    color: Colors.indigo[900],
                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.labelMedium?.fontWeight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: FutureBuilder<List<user.User>>(
              future: userService.fetchMatchedUsers(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<user.User>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        const SizedBox(width: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final user = snapshot.data![index];
                      return MatchedUserCard(user: user);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbySection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: kPadding3, horizontal: kPadding4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Things to do nearby',
                  style: GoogleFonts.lato(
                    color: Colors.indigo[900],
                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.labelMedium?.fontWeight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 160,
            child: FutureBuilder<NearbyModel>(
              future: modelFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<NearbyModel> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.filteredBusinesses.length,
                    itemBuilder: (BuildContext context, int index) {
                      final business = snapshot.data!.filteredBusinesses[index];
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: kPadding3),
                        child: BusinessCard(
                          business: business,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusinessProfilePage(
                                  business: business,
                                  authService: authService,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMirrorCardSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: kPadding3, horizontal: kPadding4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Your Mirra Card',
                  style: GoogleFonts.lato(
                    color: Colors.indigo[900],
                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.labelMedium?.fontWeight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: kPadding3, vertical: 5.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MirrorCard(),
                ));
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kPadding3),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(kPadding3),
                    gradient: const RadialGradient(
                        center: Alignment(1, 1),
                        radius: 2,
                        colors: [
                          kPrimaryAccentColor,
                          kPurpleColor,
                        ]
                        /*stops: [0, 0.1, 0.45, 0.9, 1],
                      begin: AlignmentDirectional(1, 1.5),
                      end: AlignmentDirectional(-1, -1.5),*/
                        ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kPadding3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Your Personal check-in code:',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: kWhiteColor),
                          ),
                        ),
                        const SizedBox(width: 1.0),
                        FutureBuilder<user.User>(
                          future: Provider.of<HomePageViewModel>(context,
                                  listen: false)
                              .fetchUserData(),
                          builder: (BuildContext context,
                              AsyncSnapshot<user.User> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return QRWidget(
                                size: 100.0,
                                data: snapshot.data!.id,
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: kPadding5)
        ],
      ),
    );
  }

  Widget _buildFullProfileLayout(user.User? userData, {Key? key}) {
    // Define the full profile layout
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QuoteView(userId: FirebaseAuth.instance.currentUser!.uid),
            ),
          );
        },
        child: Container(
            margin: const EdgeInsets.all(0.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(kPadding10),
                bottomRight: Radius.circular(kPadding10),
              ),
              gradient: RadialGradient(
                center: Alignment(0, 0.3),
                radius: 1.3,
                colors: [
                  kPrimaryAccentColor,
                  kPurpleColor,
                  kPurpleColor,
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(kPadding10),
                bottomRight: Radius.circular(kPadding10),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Stack(alignment: Alignment.center, children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.4,
                      child: Image.asset(
                        'assets/images/Backgroundprofile25.gif',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Text(
                          '${userData!.firstName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child:
                                // Profile picture
                                Material(
                              elevation: 10.0, // Adjust the elevation as needed
                              shape: const CircleBorder(),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: userData.profileImage != null
                                    ? CachedNetworkImageProvider(
                                        userData.profileImage!)
                                    : const AssetImage(
                                            'assets/images/placeholder_image.png')
                                        as ImageProvider<Object>,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Space between the picture and the dial
                          // OceanScoreDial
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                            child: FutureBuilder<Map<String, dynamic>>(
                              future: viewModel.fetchOCEANRawScores(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                      width: 80,
                                      height: 60,
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  final rawScores = snapshot.data!;
                                  return SizedBox(
                                    width: 500,
                                    height: 130,
                                    child:
                                        OceanScoreDial(oceanScores: rawScores),
                                  );
                                } else {
                                  return const Text('Failed to load scores');
                                }
                              },
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Space between the row and the text

                      const Text(
                        'Tap to learn more',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                                1,
                                (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0, vertical: 2),
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )),
                          )),
                    ],
                  ),
                ]),
              ),
            )));
  }
}
