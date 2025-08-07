// SQL queries for distance/radius filtering using Haversine formula

const String selectLoadsWithinRadius = """
SELECT *,
  (6371 * acos(
    cos(radians(?)) * cos(radians(latitude)) *
    cos(radians(longitude) - radians(?)) +
    sin(radians(?)) * sin(radians(latitude))
  )) AS distance
FROM loads
WHERE distance <= ?
ORDER BY distance ASC;
""";

const String selectCarrierPostsWithinRadius = """
SELECT *,
  (6371 * acos(
    cos(radians(?)) * cos(radians(carrier_latitude)) *
    cos(radians(carrier_longitude) - radians(?)) +
    sin(radians(?)) * sin(radians(carrier_latitude))
  )) AS distance
FROM carrier_posts
WHERE distance <= ?
ORDER BY distance ASC;
""";
