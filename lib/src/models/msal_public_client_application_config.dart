import 'dart:developer';
import 'dart:io';

import 'package:msal_flutter/src/models/authority.dart';
import 'package:msal_flutter/src/models/msal_android_config.dart';

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

  List<Authority>? authorities;
  MSALAndroidConfig? androidConfig;

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
    this.androidConfig,
  }) : assert(androidConfig != null || Platform.isAndroid,
            'Android config is required for Android platform') {
    if (Platform.isAndroid) {
      redirectUri = androidRedirectUri;
    } else {
      redirectUri = iosRedirectUri;
    }
  }

  Map<String, dynamic> _toMapAndroid() {
    return {
      'client_id': clientId,
      'redirect_uri' :  redirectUri,
      'client_capabilities': clientApplicationCapabilities,
      ...androidConfig?.toMap() ?? {},
    };
  }


  Map<String, dynamic> _toMapIos() {
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
  Map<String, dynamic> toMap() {
    if (Platform.isAndroid) {
      return _toMapAndroid();
    } else {
      return _toMapIos();
    }
  }
}
