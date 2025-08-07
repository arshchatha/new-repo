class LanePreference {
  final String origin;
  final String destination;

  LanePreference({
    required this.origin,
    required this.destination,
  });

  bool matches(String originFilter, String destinationFilter) {
    return origin.toLowerCase().contains(originFilter.toLowerCase()) &&
           destination.toLowerCase().contains(destinationFilter.toLowerCase());
  }
}
