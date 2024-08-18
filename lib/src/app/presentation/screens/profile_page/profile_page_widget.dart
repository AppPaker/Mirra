import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/users/profile_page_viewmodel.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';
import 'package:mirra/src/domain/firebase/cloud_storeage/firebase_storage.dart';
import 'package:provider/provider.dart';

import '../../components/gradient_appbar.dart';
import '../../../controllers/home/home_page_model.dart';
import '../home/home_page_widget.dart';
import '../insights/insights_page.dart';
import 'EditProfilePage.dart';
import 'image_reel.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final bool isEditable;

  const UserProfilePage({
    super.key,
    required this.userId,
    this.isEditable = true,
  });

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("User ID in UserProfilePage: ${widget.userId}");
    }

    return ChangeNotifierProvider(
        create: (context) => ProfilePageViewModel(
            authService: Provider.of<AuthService>(context, listen: false),
            userId: widget.userId),
        child: Consumer<ProfilePageViewModel>(
          builder: (context, model, child) {
            return Scaffold(
                appBar: GradientAppBar(
                  centerTitle: true,
                  title: Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            ChangeNotifierProvider<HomePageViewModel>(
                                create: (_) => HomePageViewModel(
                                      authService: Provider.of<AuthService>(
                                          context,
                                          listen: false),
                                    ),
                                child: const HomePage()),
                      ),
                    ),
                  ),
                  actions: [
                    if (widget.isEditable)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(userId: model.user.id),
                            ),
                          );
                          model.fetchUserData();
                        },
                      ),
                  ],
                ),
                body: Column(children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Profile'),
                      Tab(text: 'Insights'),
                    ],
                  ),
                  Expanded(
                      child: TabBarView(controller: _tabController, children: [
                    SingleChildScrollView(
                      child: Column(children: [
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            model.user.profileImage?.isNotEmpty ?? false
                                ? Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CachedNetworkImage(
                                          imageUrl:
                                              model.user.profileImage ?? '',
                                          fit: BoxFit.cover),
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: kPadding9),
                                    child: widget.isEditable
                                        ? _buildUploadButton(model)
                                        : _defaultPlaceholder(),
                                  ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.2),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${model.user.firstName}, ${model.user.age}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                              Text(
                                model.user.mbtiType ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),

                              // Inside Consumer builder method
                              Text(
                                'Location: ${model.user.city ?? "Unknown Location"}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        FutureBuilder<List<String>>(
                          future: _storageService.fetchImageUrls(model.user.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return ImageReel(imageUrls: snapshot.data!);
                              } else {
                                return const SizedBox
                                    .shrink(); // Placeholder or empty space
                              }
                            } else {
                              return const CircularProgressIndicator(); // Loading indicator
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(kPadding4),
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bio",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (model.user.city != null &&
                                      model.user.city!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.home,
                                          color: Colors.grey[600],
                                          size: 18,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          model.user.city!,
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 5),
                                  Text(
                                    model.user.bio ?? '',
                                    // Providing a default empty string if bio is null
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  //TODO: ADD Religion/Looking for to profile page
                                ],
                              ),
                            ),
                          ),
                        ),

// Interests Section
                        if (model.user.interests != null &&
                            model.user.interests!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Interests',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Wrap(
                                  spacing: 8.0,
                                  children: model.user.interests!
                                      .map((interest) => Chip(
                                            label: Text(
                                              interest,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                      color: kWhiteColor),
                                            ),
                                            backgroundColor:
                                                kPrimaryAccentColor,
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                      ]),
                    ),
                    QuoteView(
                      userId: widget.userId,
                      isTabView: true,
                      isEditable: widget.isEditable,
                    ),
                  ])),
                ]));
          },
        ));
  }

  Widget _buildUploadButton(ProfilePageViewModel model) {
    return GestureDetector(
      onTap: model.addImage,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10.0),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.add_a_photo, color: Colors.white),
        ),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.person, color: Colors.white),
      ),
    );
  }
}

List<Widget> _buildImageWidgets(ProfilePageViewModel model) {
  List<String>? otherImages = model.user.otherImages;
  if (otherImages!.isEmpty) {
    return [_buildUploadButton(model)];
  }

  int length = otherImages.length;
  int halfLength = (length / 2).floor();

  List<Widget> widgets = [];

  for (int i = 0; i < halfLength; i++) {
    widgets.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScaleImage(imageUrl: otherImages[i]),
    ));
  }

  if (length < 6) {
    widgets.add(Padding(
      padding: const EdgeInsets.all(5.0),
      child: _buildUploadButton(model),
    ));
  }

  for (int i = halfLength; i < length; i++) {
    widgets.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScaleImage(imageUrl: otherImages[i]),
    ));
  }

  return widgets;
}

Widget _buildUploadButton(ProfilePageViewModel model) {
  return GestureDetector(
    onTap: model.addImage,
    child: AspectRatio(
      aspectRatio: 1, // It will force the Container to be a square
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    ),
  );
}

class ScaleImage extends StatefulWidget {
  final String imageUrl;

  const ScaleImage({super.key, required this.imageUrl});

  @override
  _ScaleImageState createState() => _ScaleImageState();
}

class _ScaleImageState extends State<ScaleImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GestureDetector(
            onLongPress: () {
              _animationController.forward();
            },
            onLongPressEnd: (details) {
              _animationController.reverse();
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageFullScreen(
                    imageUrl: widget.imageUrl,
                  ),
                ),
              );
            },
            child: Image.network(widget.imageUrl, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class ImageFullScreen extends StatelessWidget {
  final String imageUrl;

  const ImageFullScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black,
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}
