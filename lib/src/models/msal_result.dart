import 'package:msal_flutter/src/models/msal_account.dart';

import 'msal_tenant_profile.dart';

class MSALResult {
  String accessToken;
  MSALAccount account;
  String authenticationScheme;
  Uri authority;
  String authorizationHeader;
  String correlationId;
  DateTime? expiresOn;
  bool? extendedLifeTimeToken;
  String? idToken;
  List<String> scopes;
  MSALTenantProfile? tenantProfile;
  MSALResult({
    required this.accessToken,
    required this.account,
    required this.authenticationScheme,
    required this.authority,
    required this.authorizationHeader,
    required this.correlationId,
    required this.scopes,
    this.expiresOn,
    this.extendedLifeTimeToken,
    this.idToken,
    this.tenantProfile,
  });

  MSALResult.fromMap(Map<String, dynamic> map)
      : this(
          accessToken: map['accessToken'] ?? '',
          account:
              MSALAccount.fromMap(Map<String, dynamic>.from(map['account'])),
          authenticationScheme: map['authenticationScheme'] ?? '',
          authority: Uri.parse(map['authority']),
          authorizationHeader: map['authorizationHeader'] ?? '',
          correlationId: map['correlationId'] ?? '',
          expiresOn: map['expiresOn'] != null
              ? DateTime.parse(map['expiresOn'])
              : null,
          extendedLifeTimeToken: map['extendedLifeTimeToken'],
          idToken: map['idToken'],
          scopes: List<String>.from(map['scopes'] ?? []),
          tenantProfile: map['tenantProfile'] == null
              ? null
              : MSALTenantProfile.fromMap(
                  Map<String, dynamic>.from(map['tenantProfile'])),
        );
}
