import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UsageScreen extends StatefulWidget {
  const UsageScreen({super.key});

  @override
  _UsageScreenState createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  // Variables to hold aggregated data
  Map<String, int> checkInsData = {
    '1 Day': 0,
    '1 Week': 0,
    '1 Month': 0,
    '6 Months': 0,
  };

  // List to hold individual user data
  List<UserCheckInData> usersData = [];

  // Sorting and lookup variables
  String? selectedDuration = '1 Day';
  String? sortOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Duration Dropdown
        DropdownButton<String>(
          dropdownColor: Colors.grey[800], // Darker dropdown background
          value: selectedDuration,
          items: checkInsData.keys.map((duration) {
            return DropdownMenuItem(
                value: duration,
                child: Text(duration, style: const TextStyle(color: Colors.white)));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDuration = value;
              // Fetch data based on selected duration
            });
          },
        ),

        // Chart Display
        AspectRatio(
          aspectRatio: 1.3,
          child: BarChart(
            BarChartData(
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: checkInsData[selectedDuration!]!.toDouble(),
                      color: Colors.green, // Changed to white for visibility
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // User Sorting Dropdown
        DropdownButton<String>(
          dropdownColor: Colors.grey[800], // Darker dropdown background
          value: sortOption,

          items: const [
            DropdownMenuItem(
                value: 'count',
                child: Text('Sort by Check-in Count',
                    style: TextStyle(color: Colors.white))),
            DropdownMenuItem(
                value: 'recent',
                child: Text('Sort by Most Recent',
                    style: TextStyle(color: Colors.white))),
          ],
          onChanged: (value) {
            setState(() {
              sortOption = value;
              // Apply sorting to usersData list
            });
          },
        ),

        // Display Individual User Data
        Expanded(
          child: ListView.builder(
            itemCount: usersData.length,
            itemBuilder: (context, index) {
              final user = usersData[index];
              return ListTile(
                title: Text(user.firstName,
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text('Check-ins: ${user.checkInCount}',
                    style: const TextStyle(color: Colors.white)),
                // Add more details as needed
              );
            },
          ),
        ),
      ],
    );
  }
}

class UserCheckInData {
  final String firstName;
  final int checkInCount;
  // Add more fields as needed

  UserCheckInData({
    required this.firstName,
    required this.checkInCount,
  });
}
