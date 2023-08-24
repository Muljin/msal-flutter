import 'package:msal_flutter/src/models/android_account_mode.dart';
import 'package:msal_flutter/src/models/android_logger_config.dart';
import 'package:msal_flutter/src/models/authorization_agent.dart';
import 'package:msal_flutter/src/models/http_configuration.dart';
import 'package:msal_flutter/src/models/msal_environment.dart';
import 'package:msal_flutter/src/models/safe_browser.dart';

import 'authority.dart';

class MSALAndroidConfig {
  List<Authority> authorities;
  bool handleNullTaskAffinity;
  AuthorizationAgent authorizationUserAgent;
  String minimumRequiredBrowsersVersion;
  bool multipleCloudsSupported;
  bool brokerRedirectUriRegistered;
  bool webViewZoomControlsEnabled;
  bool webViewZoomEnabled;
  bool authorizationInCurrentTask;
  MsalEnvironment environment;
  bool powerOptCheckEnabled;
  HttpConfiguration http;
  AndroidLoggerConfiguration logger;
  AndroidAccountMode accountMode;
  List<SafeBrowser> browserSafeList;
  MSALAndroidConfig({
    required this.authorities,
    this.handleNullTaskAffinity = false,
    this.authorizationUserAgent = AuthorizationAgent.DEFAULT,
    this.minimumRequiredBrowsersVersion = "3.0",
    this.multipleCloudsSupported = false,
    this.brokerRedirectUriRegistered = true,
    this.webViewZoomControlsEnabled = true,
    this.webViewZoomEnabled = true,
    this.authorizationInCurrentTask = false,
    this.environment = MsalEnvironment.Production,
    this.powerOptCheckEnabled = true,
    this.http = const HttpConfiguration(),
    this.logger = const AndroidLoggerConfiguration(),
    this.accountMode = AndroidAccountMode.MULTIPLE,
    this.browserSafeList = SafeBrowser.defaultSafeBrowsers,
  });

  Map<String, dynamic> toMap() {
    return {
      "authorities": authorities.map((x) => x.toMap()).toList(),
      "handle_null_taskaffinity": handleNullTaskAffinity,
      "authorization_user_agent":
          authorizationUserAgent.toString().split('.').last,
      "minimum_required_broker_protocol_version":
          minimumRequiredBrowsersVersion,
      "multiple_clouds_supported": multipleCloudsSupported,
      "broker_redirect_uri_registered": brokerRedirectUriRegistered,
      "web_view_zoom_controls_enabled": webViewZoomControlsEnabled,
      "web_view_zoom_enabled": webViewZoomEnabled,
      "authorization_in_current_task": authorizationInCurrentTask,
      "environment": environment.toString().split('.').last,
      "power_opt_check_for_network_req_enabled": powerOptCheckEnabled,
      "http": http.toMap(),
      "logger": logger.toMap(),
      "account_mode": accountMode.toString().split('.').last,
      "browser_safelist": browserSafeList.map((x) => x.toMap()).toList(),
    };
  }
}
