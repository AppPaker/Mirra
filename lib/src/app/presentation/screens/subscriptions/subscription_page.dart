import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/components/gradient_appbar.dart';
import 'package:mirra/src/app/presentation/screens/subscriptions/subscription_duration.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

import '../../components/mirror_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: Text('Subscription Options'),
      ),
      body: Stack(children: [
        // Gradient container
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.5, 0.5),
              radius: 1.3,
              colors: [
                kPurpleColor,
                kPrimaryAccentColor,
              ],
            ),
          ),
          child: Column(
            children: [
              TabBar(
                labelColor: Colors.white,
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Free'),
                  Tab(text: 'Subscriber'),
                  Tab(text: 'Premium'),
                  Tab(text: 'VIP'),
                ],
                labelPadding: const EdgeInsets.symmetric(horizontal: 6.0),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SubscriptionCard(
                      title: 'Free',
                      color: Colors.grey[300]!,
                      features: const [
                        'Track-A-Date',
                        'Likes: 20 daily',
                        '5% off at Mirror partners',
                        '3x Glints',
                        'MBTI insights',
                        'Shards',
                        'Ads Enabled'
                        // ... Add other features
                      ],
                      isFreeSubscription: true,
                    ),
                    SubscriptionCard(
                      title: 'Subscriber - from £3.09 per month',
                      color: Colors.blue[300]!,
                      features: const [
                        'Everything in Free plus More!',
                        'Spotify playlists',
                        '10% off at Mirror partners',
                        'UNLIMITED Likes',
                        '6x Glints',
                        'Gift your connections',
                        'Priority',
                        'No Ads!',
                        '15% off Mirror Events',
                        '10% off Shards'
                        // ... Add other features
                      ],
                    ),
                    const SubscriptionCard(
                      title: 'Premium - from £4.99 per month',
                      color: Colors.amberAccent,
                      features: [
                        'It gets better than Subscriber!?!',
                        '15% off at Mirror partners',
                        'UNLIMITED Likes',
                        '10x Glints',
                        '5x ReTrace',
                        'High priority',
                        '7 day profile Boost',
                        'See who likes you!',
                        '30% off Mirror Events',
                        '25% off VIP events ',
                        '20% off Shards'
                      ],
                    ),
                    const SubscriptionCard(
                      title: 'VIP - from £7.79 per month',
                      color: Colors.black,
                      textColor: Colors.white,
                      features: [
                        'Everything in the other subscriptions:',
                        '20% off at Mirror partners',
                        '14x Glints',
                        'UNLIMITED ReTrace',
                        'VIP priority',
                        '2x 7 day profile Boost',
                        'Bling - Send a message with your Glint!',
                        '50% off Mirror Events',
                        'Invites to VIP events - FREE',
                        '30% off Shards'
                      ],
                    ),
                  ],
                ),
              ),
              // Logo positioned towards the bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 16.0), // Adjust the margin as needed
                  child: Image.asset(
                    'assets/images/D51136ED-043D-4C43-B78B-2401B36407E9.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> features;
  final Color textColor;
  final bool isFreeSubscription; // Added property

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.color,
    required this.features,
    this.textColor = Colors.black,
    this.isFreeSubscription = false, // Default value is false
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: color,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 10),
                for (var feature in features) ...[
                  if (feature.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 5),
                ],
                if (!isFreeSubscription) 
                  MirrorElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionDurationScreen(
                              subscriptionType: title),
                        ),
                      );
                    },
                    child: const Text('Subscribe Now'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
