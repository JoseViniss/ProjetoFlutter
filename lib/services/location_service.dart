import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    final p = await Permission.location.request();
    if (p.isGranted) {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    }
    return null;
  }

  double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
