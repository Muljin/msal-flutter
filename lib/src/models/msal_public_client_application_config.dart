import 'dart:convert';
import 'dart:io';

import 'msal_cache_config.dart';
import 'msal_slice_config.dart';

class MSALPublicClientApplicationConfig {
  String clientId;
  String? redirectUri;
  Uri? authority;
  bool bypassRedirectURIValidation;
  List<String>? clientApplicationCapabilities;
  bool extendedLifetimeEnabled;
  List<Uri>? knownAuthorities;
  MSALCacheConfig? cacheConfig;
  bool multipleCloudsSupported;
  MSALSliceConfig? sliceConfig;
  double? tokenExpirationBuffer;
  MSALPublicClientApplicationConfig({
    required String androidRedirectUri,
    String? iosRedirectUri,
    required this.clientId,
    this.authority,
    this.bypassRedirectURIValidation = false,
    this.clientApplicationCapabilities,
    this.extendedLifetimeEnabled = false,
    this.knownAuthorities,
    this.cacheConfig,
    this.multipleCloudsSupported = false,
    this.sliceConfig,
    this.tokenExpirationBuffer,
  }) {
    if (Platform.isAndroid) {
      redirectUri = androidRedirectUri;
    } else {
      redirectUri = iosRedirectUri;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'redirectUri': redirectUri,
      'authority': authority?.toString(),
      'bypassRedirectURIValidation': bypassRedirectURIValidation,
      'clientApplicationCapabilities': clientApplicationCapabilities,
      'extendedLifetimeEnabled': extendedLifetimeEnabled,
      'knownAuthorities': knownAuthorities?.map((x) => x.toString()).toList(),
      'cacheConfig': cacheConfig?.toMap(),
      'multipleCloudsSupported': multipleCloudsSupported,
      'sliceConfig': sliceConfig?.toMap(),
      'tokenExpirationBuffer': tokenExpirationBuffer,
    };
  }
}
