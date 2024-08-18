import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/profile_page/profile_page_widget.dart';

class ImageReel extends StatelessWidget {
  final List<String> imageUrls;

  const ImageReel({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130, // Set the height according to your UI design
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImageFullScreen(imageUrl: imageUrls[index]),
                  ),
                );
              },
              child: Card(
                elevation: 4.0, // Adjust elevation for desired 'lift' effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      12), // Adjust for desired corner radius
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12), // Same as Card's borderRadius
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    width: 100, // Set the width according to your UI design
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                          'Error Loading Image'); // Error handling
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
