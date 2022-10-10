class MSALCacheConfig {
  String? keychainSharingGroup;
  MSALCacheConfig({
    this.keychainSharingGroup,
  });

  Map<String, dynamic> toMap() {
    return {
      'keychainSharingGroup': keychainSharingGroup,
    };
  }
}
