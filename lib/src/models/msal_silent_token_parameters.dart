import 'package:msal_flutter/src/models/msal_token_parameters.dart';

class MSALSilentTokenParameters extends MSALTokenParameters {
  bool? forceRefresh;

  MSALSilentTokenParameters({
    required super.scopes,
    super.correlationId,
    super.extraQueryParameters,
    super.overrideAuthority,
    this.forceRefresh,
  });

 Map<String, dynamic> toMap() {
    return {
      'scopes': scopes,
      'correlationId': correlationId,
      'extraQueryParameters': extraQueryParameters,
      'forceRefresh': forceRefresh,
      'authority': overrideAuthority?.authorityUrl.toString(),

    };
  }

}

