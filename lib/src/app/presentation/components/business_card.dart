import 'package:flutter/material.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/utils/constants.dart';

class BusinessCard extends StatelessWidget {
  const BusinessCard({super.key, required this.business, required this.onTap});

  final Business business;
  final VoidCallback onTap;

  String formatAmenities(String amenities) {
    if (amenities.isEmpty) {
      return ''; // Or any default message you'd like to show
    }

    List<String> amenitiesList = amenities.split(',').take(2).toList();
    return amenitiesList
        .map((a) => a
            .trim()
            .split('_')
            .map((word) =>
                word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
            .join(' '))
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    String formattedAmenities = formatAmenities(business.amenity);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 109,
        child: GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 4.0,
            margin: EdgeInsets.zero, // Keep margin zero inside the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kPadding3),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(kPadding3),
                    ),
                    child: Image.network(
                      business.imageUrls.isNotEmpty
                          ? business.imageUrls.first
                          : '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(child: Icon(Icons.error_outline)),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(kPadding3)),
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: kPadding3),
                      Text(
                        business.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: kPadding2),
                      Text(
                        formattedAmenities,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: kPadding3),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
