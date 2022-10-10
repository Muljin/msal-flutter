class MSALSignoutParameters {
  final bool? signoutFromBrowser;
  final bool? wipeAccount;
  final bool? wipeCacheForAllAccounts;
  const MSALSignoutParameters(
      {this.signoutFromBrowser,
      this.wipeAccount,
      this.wipeCacheForAllAccounts});

  Map<String, dynamic> toMap() {
    return {
      'signoutFromBrowser': signoutFromBrowser,
      'wipeAccount': wipeAccount,
      'wipeCacheForAllAccounts': wipeCacheForAllAccounts,
    };
  }
}
