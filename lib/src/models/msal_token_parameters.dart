import 'package:msal_flutter/src/models/authority.dart';

abstract class MSALTokenParameters {
  List<String> scopes;

  Map<String, dynamic>? extraQueryParameters;
  String? correlationId;
  Authority? overrideAuthority;
  MSALTokenParameters({
    required this.scopes,
    this.extraQueryParameters,
    this.correlationId,
    this.overrideAuthority,
  });
}
