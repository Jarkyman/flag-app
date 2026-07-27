import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

timezone.Location initializeLocalTimezone(String identifier) {
  timezone_data.initializeTimeZones();
  final location = timezone.getLocation(identifier);
  timezone.setLocalLocation(location);
  return location;
}
