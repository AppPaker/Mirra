import 'package:flutter/material.dart';

class SubscriptionDurationScreen extends StatefulWidget {
  final String subscriptionType;

  const SubscriptionDurationScreen({super.key, required this.subscriptionType});

  @override
  _SubscriptionDurationScreenState createState() =>
      _SubscriptionDurationScreenState();
}

class _SubscriptionDurationScreenState
    extends State<SubscriptionDurationScreen> {
  String? selectedDuration;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> durations = [];

    switch (widget.subscriptionType) {
      case 'Subscriber - from £3.09 per month':
        durations = [
          {'duration': '1 Month', 'price': 5.99, 'total': 5.99},
          {'duration': '3 Months', 'price': 4.99, 'total': 14.97},
          {'duration': '6 Months', 'price': 3.99, 'total': 23.94},
          {'duration': 'Annual', 'price': 3.09, 'total': 37.08}
        ];
        break;
      case 'Premium - from £4.99 per month':
        durations = [
          {'duration': '1 Month', 'price': 9.99, 'total': 9.99},
          {'duration': '3 Months', 'price': 7.99, 'total': 23.97},
          {'duration': '6 Months', 'price': 5.99, 'total': 35.94},
          {'duration': 'Annual', 'price': 4.99, 'total': 59.88}
        ];
        break;
      case 'VIP - from £7.79 per month':
        durations = [
          {'duration': '1 Month', 'price': 11.99, 'total': 11.99},
          {'duration': '3 Months', 'price': 9.59, 'total': 28.77},
          {'duration': '6 Months', 'price': 8.39, 'total': 50.34},
          {'duration': 'Annual', 'price': 7.79, 'total': 93.48}
        ];
        break;
      default:
        durations = [
          {'duration': 'Free', 'price': 0, 'total': 0}
        ];
        break;
    }
    double oneMonthPrice = durations[0]['price'];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Duration')),
      body: ListView.builder(
        itemCount: durations.length,
        itemBuilder: (context, index) {
          double savings =
              (1 - (durations[index]['price'] / oneMonthPrice)) * 100;
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('${durations[index]['duration']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${durations[index]['price'].toStringAsFixed(2)}/mo',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Total: £${durations[index]['total'].toStringAsFixed(2)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (index != 0) // Don't show savings for 1 month
                    Text(
                      'Save ${savings.toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.blue),
                    ),
                ],
              ),
              trailing: selectedDuration == durations[index]['duration']
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  selectedDuration = durations[index]['duration'];
                });
              },
            ),
          );
        },
      ),
    );
  }
}
