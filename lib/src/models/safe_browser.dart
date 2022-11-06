class SafeBrowser {
  const SafeBrowser({
    required this.browserPackageName,
    required this.browserSignatureHashes,
  });

  final String browserPackageName;
  final List<String> browserSignatureHashes;

  Map<String, dynamic> toMap() => {
        "browser_package_name": browserPackageName,
        "browser_signature_hashes": browserSignatureHashes,
      };

/// the default safe browswers list
static const List<SafeBrowser> defaultSafeBrowsers = [
  SafeBrowser(
      browserPackageName: 'com.android.chrome',
      browserSignatureHashes: [
        "7fmduHKTdHHrlMvldlEqAIlSfii1tl35bxj1OXN5Ve8c4lU6URVu4xtSHc3BVZxS6WWJnxMDhIfQN0N0K2NDJg=="
      ]),
  SafeBrowser(
      browserPackageName: 'org.mozilla.firefox',
      browserSignatureHashes: [
        "2gCe6pR_AO_Q2Vu8Iep-4AsiKNnUHQxu0FaDHO_qa178GByKybdT_BuE8_dYk99G5Uvx_gdONXAOO2EaXidpVQ=="
      ]),
  SafeBrowser(
      browserPackageName: 'com.sec.android.app.sbrowser',
      browserSignatureHashes: [
        "ABi2fbt8vkzj7SJ8aD5jc4xJFTDFntdkMrYXL3itsvqY1QIw-dZozdop5rgKNxjbrQAd5nntAGpgh9w84O1Xgg=="
      ]),
  SafeBrowser(
      browserPackageName: 'com.cloudmosa.puffinFree',
      browserSignatureHashes: [
        "1WqG8SoK2WvE4NTYgr2550TRhjhxT-7DWxu6C_o6GrOLK6xzG67Hq7GCGDjkAFRCOChlo2XUUglLRAYu3Mn8Ag=="
      ]),
  SafeBrowser(
      browserPackageName: 'com.duckduckgo.mobile.android',
      browserSignatureHashes: [
        "S5Av4cfEycCvIvKPpKGjyCuAE5gZ8y60-knFfGkAEIZWPr9lU5kA7iOAlSZxaJei08s0ruDvuEzFYlmH-jAi4Q=="
      ]),
  SafeBrowser(
      browserPackageName: 'com.explore.web.browser',
      browserSignatureHashes: [
        "BzDzBVSAwah8f_A0MYJCPOkt0eb7WcIEw6Udn7VLcizjoU3wxAzVisCm6bW7uTs4WpMfBEJYf0nDgzTYvYHCag=="
      ]),
  SafeBrowser(browserPackageName: 'com.ksmobile.cb', browserSignatureHashes: [
    "lFDYx1Rwc7_XUn4KlfQk2klXLufRyuGHLa3a7rNjqQMkMaxZueQfxukVTvA7yKKp3Md3XUeeDSWGIZcRy7nouw=="
  ]),
  SafeBrowser(
      browserPackageName: 'com.microsoft.emmx',
      browserSignatureHashes: [
        "Ivy-Rk6ztai_IudfbyUrSHugzRqAtHWslFvHT0PTvLMsEKLUIgv7ZZbVxygWy_M5mOPpfjZrd3vOx3t-cA6fVQ=="
      ]),
  SafeBrowser(browserPackageName: 'com.opera.browser', browserSignatureHashes: [
    "FIJ3IIeqB7V0com.opera.browserqHpRNEpYNkhEGA_eJaf7ntca-Oa_6Feev3UkgnpguTNV31JdAmpEFPGNPo0RHqdlU0k-3jWJWw=="
  ]),
  SafeBrowser(
      browserPackageName: 'com.opera.mini.native',
      browserSignatureHashes: [
        "TOTyHs086iGIEdxrX_24aAewTZxV7Wbi6niS2ZrpPhLkjuZPAh1c3NQ_U4Lx1KdgyhQE4BiS36MIfP6LbmmUYQ=="
      ]),
  SafeBrowser(
      browserPackageName: 'mobi.mgeek.TunnyBrowser',
      browserSignatureHashes: [
        "RMVoXuK1sfJZuGZ8onG1yhMc-sKiAV2NiB_GZfdNlN8XJ78XEE2wPM6LnQiyltF25GkHiPN2iKQiGwaO2bkyyQ=="
      ]),
  SafeBrowser(browserPackageName: 'org.mozilla.focus', browserSignatureHashes: [
    "L72dT-stFqomSY7sYySrgBJ3VYKbipMZapmUXfTZNqOzN_dekT5wdBACJkpz0C6P0yx5EmZ5IciI93Q0hq0oYA=="
  ]),
  SafeBrowser(browserPackageName: 'com.cake.browser', browserSignatureHashes: [
    "442kvSdZT1fEAewzSi8Wre73x4mWmHBhOFtQ-9T9N6ExZzUdsELUmaaS0edsI7ur2nY-bjbWX7IpluFOyvKkOA=="
  ]),
  SafeBrowser(browserPackageName: 'com.brave.browser', browserSignatureHashes: [
    "wIwX1v_1TfPxHm5qn-_jdGoH3Pa9VVMR5dtVz0Y0xqPkyM_KlavjWPSgOolrVH05AVO1cHWoLPqMzCH04Pw8LQ=="
  ]),
  SafeBrowser(
      browserPackageName: 'com.kiwibrowser.browser',
      browserSignatureHashes: [
        "kmPeixKA04JcDuWNBMUPu_6WaODr6a9ofROUIHIGxiiFGvH8Y92MonrDQmsNqEJO2DQkpEQc425WmAYB4NlD3Q=="
      ]),
  SafeBrowser(
      browserPackageName: 'com.mi.globalbrowser.mini',
      browserSignatureHashes: [
        "6FEWlPfWn-omfES2ZYDj5bZUIR5au_nfyRr-o_1R3fesjfoV1JptBMumtvVIo0q37abcMRWQt9RUSNXpzKpNdA=="
      ]),
  SafeBrowser(browserPackageName: 'mark.via.gp', browserSignatureHashes: [
    "oTJf5e5nB1NinkdBpkkmhPnwbVRmDlHZ-s_QhvyuGKM5nq5XtjA439O31wxrkL6ReHyyKfDHFUHpQnoXoj--Ig=="
  ]),
];
}