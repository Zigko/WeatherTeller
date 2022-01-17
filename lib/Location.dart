import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

Future<Position> determinePosition() async {
  var serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error(
        Intl.message('Location services are disabled.', name: 'gps_disabled'));
  } //TODO meter as strings no Intl em PT e EN

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error(
          Intl.message('Location permissions are denied', name: 'gps_denied'));
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(Intl.message(
        'Location permissions are permanently denied, we cannot request permissions.',
        name: 'gps_blocked'));
  }

  return await Geolocator.getCurrentPosition();
}
