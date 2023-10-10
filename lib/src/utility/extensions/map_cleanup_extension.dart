// map extension to remove null values
extension MapCleanup on Map<String, dynamic> {
  Map<String, dynamic> cleanup() {
    removeWhere((key, value) {
      if (value is List) {
        if (value.isEmpty) {
          return true;
        }
        return false;
      }
      return value == null;
    });
    return this;
  }
}
