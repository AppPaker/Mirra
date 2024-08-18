import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mirra/src/app/presentation/screens/businesses/businesses.dart';
import 'package:mirra/src/app/presentation/screens/map/google_places_api.dart';
class MapModel {
  late GoogleMapController mapController;
  List<String> selectedAmenities = []; // If you still need this for filtering

  List<Business> businesses = [];

  // HeatMap and Markers toggles
  bool showHeatMap = false;
  bool showMarkers = true;

  void setController(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> getBusinessMarkers() {
    return businesses
        .map((business) => Marker(
              markerId: MarkerId(business.id),
              position: LatLng(business.latitude!, business.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueViolet),
              infoWindow: InfoWindow(
                  title: business.name, snippet: business.description),
            ))
        .toSet();
  }

  // TODO: Implement heatmap logic here

  Future<void> init(LocationData locationData) async {
    businesses = await fetchBusinessesForMap(); // Use the new function here
  }

  Set<Marker> convertToMarkers(List<Business> businesses) {
    return businesses.map((business) {
      return Marker(
        markerId: MarkerId(business.id),
        position: LatLng(business.latitude!, business.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow:
            InfoWindow(title: business.name, snippet: business.description),
      );
    }).toSet();
  }
}
