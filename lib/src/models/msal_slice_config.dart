
import 'package:msal_flutter/src/utility/extensions/map_cleanup_extension.dart';

class MSALSliceConfig {
  String? slice;
  String? dc;
  MSALSliceConfig({
    this.slice,
    this.dc,
  });

  Map<String, dynamic> toMap() {
    return {
      'slice': slice,
      'dc': dc,
    }.cleanup();
  }
}
