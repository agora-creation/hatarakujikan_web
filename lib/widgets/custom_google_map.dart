import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatelessWidget {
  final double? height;
  final Function(GoogleMapController)? onMapCreated;
  final Set<Marker>? markers;
  final double? lat;
  final double? lon;
  final double? range;
  final bool? area;
  final Function(LatLng)? onTap;

  CustomGoogleMap({
    this.height,
    this.markers,
    this.onMapCreated,
    this.lat,
    this.lon,
    this.range,
    this.area,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: GoogleMap(
        onMapCreated: onMapCreated,
        markers: markers ?? {},
        initialCameraPosition: CameraPosition(
          target: LatLng(lat ?? 0, lon ?? 0),
          zoom: 17.0,
        ),
        circles: area == true
            ? Set.from([
                Circle(
                  circleId: CircleId('area'),
                  center: LatLng(lat ?? 0, lon ?? 0),
                  radius: range ?? 0,
                  fillColor: Colors.red.withOpacity(0.3),
                  strokeColor: Colors.transparent,
                ),
              ])
            : {},
        onTap: onTap,
      ),
    );
  }
}
