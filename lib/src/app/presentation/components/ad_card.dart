import 'package:flutter/material.dart';

class AdCardWidget extends StatefulWidget {
  final Function onClose;

  const AdCardWidget({super.key, required this.onClose});

  @override
  _AdCardWidgetState createState() => _AdCardWidgetState();
}

class _AdCardWidgetState extends State<AdCardWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Add elevation for a card-like look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'Sponsored Ad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ad Content Title',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ad Content Description Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Learn More',
                      style: TextStyle(
                        color: Colors.blue, // Add a link color
                      ),
                    ),
                    const Text(
                      'Sponsored',
                      style: TextStyle(
                        color: Colors.grey, // Add a sponsored tag color
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close), // Close button icon
                      onPressed: () {
                        // Call the onClose callback when the close button is tapped
                        widget.onClose();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
