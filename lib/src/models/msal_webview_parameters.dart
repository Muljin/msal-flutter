import 'package:msal_flutter/src/models/ios_modal_presentation_style.dart';
import 'package:msal_flutter/src/models/msal_webview_type.dart';

class MSALWebviewParameters {
  /// A specific webView type for the interactive authentication flow. By default, it will be set to MSALGlobalConfig.defaultWebviewType.
  final MSALWebviewType? webviewType;

  /// A Boolean value that indicates whether the ASWebAuthenticationSession should ask the browser for a private authentication session.
  /// The value of this property is false by default. For more info see
  /// here: https://developer.apple.com/documentation/authenticationservices/aswebauthenticationsession/3237231-prefersephemeralwebbrowsersessio?language=objc
  final bool prefersEphemeralWebBrowserSession;

  /// Modal presentation style for displaying authentication web content.
  /// Note that presentationStyle has no effect when webviewType == MSALWebviewType.MSALWebviewTypeDefault
  /// or webviewType == MSALWebviewType.MSALWebviewTypeAuthenticationSession.
  final IOSModalPresentationStyle? presentationStyle;
  MSALWebviewParameters({
    this.prefersEphemeralWebBrowserSession = false,
    this.webviewType,
    this.presentationStyle,
  });

  Map<String, dynamic> toMap() {
    return {
      'webviewType': webviewType?.name,
      'prefersEphemeralWebBrowserSession': prefersEphemeralWebBrowserSession,
      'presentationStyle': presentationStyle?.name,
    };
  }
}

