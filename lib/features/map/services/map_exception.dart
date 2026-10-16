class MapRoutesException implements Exception {
  const MapRoutesException(this.message);

  final String message;

  @override
  String toString() => message;
}