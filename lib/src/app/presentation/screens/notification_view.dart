import 'package:flutter/material.dart';
import 'package:mirra/src/app/controllers/notification/notification_provider.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/components/notification_card.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';
import 'package:provider/provider.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: const GradientAppBar(
            title: Text('Notifications'),
          ),
          body: Container(
            padding: const EdgeInsets.all(kPadding3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kPadding3),
                Text(
                  'Here\'s your latest notifications',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: kPadding4),
                ...List.generate(
                  provider.notifications.length,
                      (index) {
                    final notification = provider.notifications[index];
                    return NotificationCard(
                      notification: notification,
                      onTap: () {
                        provider.markNotificationAsRead(notification.id);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
