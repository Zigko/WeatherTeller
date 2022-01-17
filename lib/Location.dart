import 'package:location/location.dart';
import 'package:intl/intl.dart';

Future<LocationData> determinePosition() async {
  var location = Location();

  var serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    return Future.error(Intl.message('', name: 'gps_disabled'));
  }

  var permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
    permission = await location.requestPermission();
    if (permission == PermissionStatus.denied) {
      return Future.error(Intl.message('', name: 'gps_denied'));
    }
  }

  if (permission == PermissionStatus.deniedForever) {
    return Future.error(Intl.message('', name: 'gps_blocked'));
  }

  return await location.getLocation();
}
