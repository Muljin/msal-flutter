class MSALAccountEnumerationParameters {
  String? _identifier;
  String? _username;
  String? _tenantProfileIdentifier;

  MSALAccountEnumerationParameters.fromIdentifier(String identifier) {
    this._identifier = identifier;
  }
  MSALAccountEnumerationParameters.fromUsername(
      {required String username, String? identifier}) {
    this._identifier = identifier;
    this._username = username;
  }
  MSALAccountEnumerationParameters.fromTenantIdentifier(
      String tenantIdentifier) {
    this._tenantProfileIdentifier = tenantIdentifier;
  }

  Map<String, dynamic> toMap() {
    return {
      'identifier': _identifier,
      'username': _username,
      'tenantProfileIdentifier': _tenantProfileIdentifier,
    };
  }
}
