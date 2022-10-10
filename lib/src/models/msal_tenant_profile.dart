class MSALTenantProfile {
  String? tenantId;
  String? environment;
  String? identifier;
  bool? isHomeTenantProfile;
  MSALTenantProfile({
    this.tenantId,
    this.environment,
    this.identifier,
    this.isHomeTenantProfile,
  });

  MSALTenantProfile.fromMap(Map<String, dynamic> map)
      : this(
          tenantId: map['tenantId'],
          environment: map['environment'],
          identifier: map['identifier'],
          isHomeTenantProfile: map['isHomeTenantProfile'],
        );
}

