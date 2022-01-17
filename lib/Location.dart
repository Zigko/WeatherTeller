import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

Future<Position> determinePosition() async {
  var serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error(Intl.message('', name: 'gps_disabled'));
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error(Intl.message('', name: 'gps_denied'));
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(Intl.message('', name: 'gps_blocked'));
  }

  return await Geolocator.getCurrentPosition();
}
