import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:mirra/src/domain/firebase/auth_service.dart';


Map<int, String> ratingLabels = {4: 'High', 3: 'Good', 2: 'Ok', 1: 'Fair'};

class CompatibilityWidget extends StatefulWidget {
  final String userId;
  final AuthService authService;

  const CompatibilityWidget(
      {super.key, required this.userId, required this.authService});

  @override
  _CompatibilityWidgetState createState() => _CompatibilityWidgetState();
}

class _CompatibilityWidgetState extends State<CompatibilityWidget> {
  String compatibilityLabel = '';

  @override
  void initState() {
    super.initState();
    _loadCompatibility();
  }

  _loadCompatibility() async {
    final functions = FirebaseFunctions.instance;

    try {
      final loggedInUserId = await widget.authService.getUserId();
      final result = await functions.httpsCallable('getCompatibility').call({
        'loggedInUserId': loggedInUserId,
        'profileUserId': widget.userId,
      });

      int compatibilityValue = result.data;
      setState(() {
        compatibilityLabel = ratingLabels[compatibilityValue] ?? 'Unknown';
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading compatibility: $e');
      }
      // Handle errors, for instance, if the user is not logged in
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text('Compatibility: $compatibilityLabel');
  }
}
