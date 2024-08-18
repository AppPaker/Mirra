import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:mirra/src/data/models/notification_model.dart';
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onAccept; // Optional callback for accepting invites
  final VoidCallback? onDecline; // Optional callback for declining invites

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kPadding3),
          border: Border.all(
            color: kBlackColor,
          ),
        ),
        padding: const EdgeInsets.all(kPadding4),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    notification.title ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: kPadding3),
                Icon(
                  Icons.circle,
                  size: 12,
                  color: notification.read ? Colors.grey : kGreenColor,
                ),
              ],
            ),
            const SizedBox(height: kPadding3),
            Text(
              notification.body ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (notification.type == 'invite') ...[
              const SizedBox(height: kPadding3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onAccept,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: onDecline,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: kPadding3),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatDateTime(notification.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  // Format the date as needed
  return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}';
}

String _getMonthName(int month) {
  const monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  return monthNames[month - 1];
}
