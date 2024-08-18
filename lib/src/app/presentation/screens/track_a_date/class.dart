import '../users/user.dart';

class DateTracker {
  DateTime startTime;
  DateTime? endTime;
  String location;
  String trustedContactEmail;
  String datePartnerName;
  bool active;
  User? selectedMatch;

  DateTracker({
    required this.startTime,
    this.endTime,
    this.location = '',
    this.trustedContactEmail = '',
    this.datePartnerName = '',
    this.active = false,
    this.selectedMatch,
  });
}
