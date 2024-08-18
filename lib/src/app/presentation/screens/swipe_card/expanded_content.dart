import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/ocean_dial.dart';

import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

import '../../../../data/models/quote_viewmodel.dart';

class ExpandedContentWidget extends StatelessWidget {
  final User user;
  final QuoteViewModel viewModel;

  const ExpandedContentWidget({
    super.key,
    required this.user,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: RadialGradient(
          center: Alignment(0.87, 0.5),
          radius: 1,
          colors: [
            kPurpleColor,
            kPrimaryAccentColor,
          ],
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: FutureBuilder<Map<String, dynamic>>(
        future: viewModel.fetchOCEANRawScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data != null) {
            final rawScores = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AspectRatio(
                  aspectRatio: 1.2, // Maintain the graph's aspect ratio
                  child: Card(
                    color: const Color(0x00ffffff),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OceanScoreDial(
                        oceanScores: rawScores,
                      ),
                    ),
                  ),
                ),
                buildUserInformation(user, rawScores),
              ],
            );
          } else {
            return const Text('Failed to load scores');
          }
        },
      ),
    );
  }

  Widget buildUserInformation(User user, Map<String, dynamic> oceanScores) {
    final List<Widget> infoWidgets = [];
    const TextStyle infoStyle = TextStyle(
      color: Colors.white,
    );
    const TextStyle chipLabelStyle = TextStyle(
        color: Colors.white,
        fontSize: 15); // Define chip label styles as needed

    // Add user information sections
    if (user.mbtiType != null) {
      infoWidgets.add(Text("MBTI Type: ${user.mbtiType}",
          style: infoStyle, textAlign: TextAlign.center));
      infoWidgets.add(const SizedBox(height: 10));
    }
    if (user.city != null) {
      infoWidgets.add(Text("City: ${user.city}",
          style: infoStyle, textAlign: TextAlign.center));
    }
    if (user.interests != null && user.interests!.isNotEmpty) {
      addInterests(infoWidgets, user, chipLabelStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: infoWidgets,
    );
  }

  void addInterests(
      List<Widget> infoWidgets, User user, TextStyle chipLabelStyle) {
    infoWidgets.add(const Text("Interests:",
        style: TextStyle(color: Colors.white), textAlign: TextAlign.right));
    final List<Widget> chipWidgets = user.interests!
        .take(2)
        .map((interest) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(
                label: Text(interest, style: chipLabelStyle),
                backgroundColor: Colors.blueAccent.shade100,
                shape: const StadiumBorder(),
              ),
            ))
        .toList();

    infoWidgets.add(Wrap(
      spacing: 8.0, // Space between chips horizontally
      runSpacing: 4.0, // Space between chips vertically
      children: chipWidgets,
    ));

    if (user.interests!.length > 2) {
      infoWidgets.add(Text(
        "+ ${user.interests!.length - 2} more",
        style: const TextStyle(color: Colors.white),
      ));
    }
  }
}
