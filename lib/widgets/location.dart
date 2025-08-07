import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class Location {
  Location({
    required this.latitude,
    required this.longitude,
    this.borough,
    this.bounds,
    this.city,
    this.country,
    this.countryCode,
    this.displayName,
    this.houseNumber,
    this.municipality,
    this.name,
    this.neighbourhood,
    this.postcode,
    this.road,
    this.state,
    this.suburb,
  });

  final gmaps.LatLngBounds? bounds;
  final String? borough;
  final String? city;
  final String? country;
  final String? countryCode;
  final String? displayName;
  final String? houseNumber;
  final double latitude;
  final double longitude;
  final String? municipality;
  final String? name;
  final String? neighbourhood;
  final String? postcode;
  final String? road;
  final String? state;
  final String? suburb;

  gmaps.LatLng get latLng => gmaps.LatLng(latitude, longitude);

  List<Object?> get props => [
        borough,
        bounds,
        city,
        country,
        countryCode,
        displayName,
        houseNumber,
        latitude,
        longitude,
        municipality,
        name,
        neighbourhood,
        postcode,
        road,
        state,
        suburb,
      ];

  factory Location.fromGeoJson(Map<String, dynamic> geoJson) {
    final address = geoJson['properties']['address'];
    final boundsList = List<double>.from(geoJson['bbox']);
    final latLngBounds = gmaps.LatLngBounds(
      southwest: gmaps.LatLng(boundsList[1], boundsList[0]),
      northeast: gmaps.LatLng(boundsList[3], boundsList[2]),
    );

    return Location(
      bounds: latLngBounds,
      city: address['city'],
      country: address['country'],
      countryCode: address['country_code'],
      displayName: geoJson['properties']['display_name'],
      houseNumber: address['house_number'],
      latitude: geoJson['geometry']['coordinates'][1],
      longitude: geoJson['geometry']['coordinates'][0],
      name: geoJson['properties']['name'],
      neighbourhood: address['neighbourhood'],
      postcode: address['postcode'],
      road: address['road'],
      state: address['state'],
      suburb: address['suburb'],
    );
  }

  @override
  String toString() {
    return displayName ?? name ?? '\$latitude, \$longitude';
  }
}
