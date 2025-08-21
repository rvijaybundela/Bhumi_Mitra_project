import 'package:proj4dart/proj4dart.dart' as proj4;

// EPSG:4326 (WGS84) is built-in: Projection.WGS84
// Define EPSG:32643 (UTM Zone 43N)
final epsg32643 = proj4.Projection.parse(
  '+proj=utm +zone=43 +datum=WGS84 +units=m +no_defs +type=crs',
);

// Create transformer from UTM to WGS84
proj4.Point transformToWgs84(double x, double y) {
  final utmPoint = proj4.Point(x: x, y: y);
  return epsg32643.transform(proj4.Projection.WGS84, utmPoint);
}
