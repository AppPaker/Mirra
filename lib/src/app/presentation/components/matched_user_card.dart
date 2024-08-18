
import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/profile_page/profile_page_widget.dart';
import 'package:mirra/src/app/presentation/screens/users/user.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

class MatchedUserCard extends StatelessWidget {
  const MatchedUserCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 109,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserProfilePage(
                userId: user.id,
                isEditable: false,
              ),
            ),
          );
        },
        /*child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kPadding3),
          ),*/
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: kPadding1),
            Material(
              elevation: 5.0, // Adjust elevation as needed
              shape: const CircleBorder(),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user.profileImage ?? ''),
                radius: 38,
              ),
            ),
            const SizedBox(height: kPadding3),
            Flexible(
              child: Text(
                user.firstName ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: kPadding1),
            /*Flexible(
                child: Text('${user.age}',
                    style: Theme.of(context).textTheme.bodySmall),
              ),*/
            /*Flexible(
                child: Text(user.mbtiType ?? "",
                    style: Theme.of(context).textTheme.bodySmall),
              ),*/
          ],
        ),
        // ),
      ),
    );
  }
}
