import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:msal_flutter/src/exceptions/msal_scope_error_exception.dart';
import 'exceptions/msal_exceptions.dart';

/// Represents a PublicClientApplication used to authenticate using the implicit flow
class PublicClientApplication {
  static const MethodChannel _channel = const MethodChannel('msal_flutter');

  String _clientId;
  String? _authority;
  String? _redirectUri;
  String? _keychain;
  late bool _privateSession;

  PublicClientApplication._create(this._clientId,
      {String? authority,
      String? redirectUri,
      String? keychain,
      bool? privateSession}) {
    _authority = authority;
    _redirectUri = redirectUri;
    _keychain = keychain;
    _privateSession = privateSession ?? false;
  }

  ///
  /// @param clientId The id of the client, as registered in Azure AD
  /// @param authority The authority to authenticate against
  /// @param redirectUri The redirect uri registered for your application for all platforms
  /// @param androidRedirectUri Override for android specific redirectUri
  /// @param iosRedirectUri Override for iOS specific redirectUri
  /// @param privateSession is set to true to request that the browser doesn’t share cookies or other browsing data between the authentication session and the user’s normal browser session. Whether the request is honored depends on the user’s default web browser. Safari always honors the request.
  /// The value of this property is false by default.
  /// @param keychain this is only used in ios it won't affect android configuration
  /// for more info go to https://docs.microsoft.com/en-us/azure/active-directory/develop/single-sign-on-macos-ios#silent-sso-between-apps
  static Future<PublicClientApplication> createPublicClientApplication(
      String clientId,
      {String? authority,
      String? redirectUri,
      String? androidRedirectUri,
      String? iosRedirectUri,
      String? keychain,
      bool? privateSession}) async {
    //set the correct redirect uri based on platform
    if (Platform.isAndroid && androidRedirectUri != null) {
      redirectUri = androidRedirectUri;
    } else if (Platform.isIOS && iosRedirectUri != null) {
      redirectUri = iosRedirectUri;
    }

    var res = PublicClientApplication._create(clientId,
        authority: authority,
        redirectUri: redirectUri,
        keychain: keychain,
        privateSession: privateSession);
    await res._initialize();
    try {
      await res.loadAccounts();
    } catch (e) {
      log(e.toString());
    }
    return res;
  }

  /// Acquire a token interactively for the given [scopes]
  Future<String> acquireToken(List<String> scopes, [bool? clearSession]) async {
    //create the arguments
    var res = <String, dynamic>{'scopes': scopes};
    if (clearSession != null) {
      res['clearSession'] = clearSession;
    }
    //call platform
    try {
      final String token = await _channel.invokeMethod('acquireToken', res);
      return token;
    } on PlatformException catch (e) {
      print(e.toString());
      throw _convertException(e);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  /// Acquire a token interactively for the given [scopes]
  Future<List<Map<String,dynamic>>> loadAccounts() async {
    //create the arguments
    var res = <String, dynamic>{};

    //call platform
    try {
      final map = await _channel.invokeMethod('loadAccounts', res);

      return map;
    } on PlatformException catch (e) {
      print(e.toString());
      throw _convertException(e);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  Future<String> acquireTokenSilent(
    List<String> scopes,
  ) async {
    //create the arguments
    var res = <String, dynamic>{'scopes': scopes};
    //call platform
    try {
      final String token =
          await _channel.invokeMethod('acquireTokenSilent', res);
      return token;
    } on PlatformException catch (e) {
      throw _convertException(e);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future logout({bool browserLogout = false}) async {
    try {
      await _channel.invokeMethod(
          'logout', <String, dynamic>{'browserLogout': browserLogout});
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  MsalException _convertException(PlatformException e) {
    switch (e.code) {
      case "CANCELLED":
        return MsalUserCancelledException();
      case "NO_SCOPE":
        return MsalInvalidScopeException();
      case "NO_ACCOUNT":
        return MsalNoAccountException();
      case "NO_CLIENTID":
        return MsalInvalidConfigurationException("Client Id not set");
      case "INVALID_AUTHORITY":
        return MsalInvalidConfigurationException("Invalid authroity set.");
      case "INVALID_GRANT":
        return MsalInvalidGrantException();
      case "INVALID_REQUEST":
        return MsalInvalidRequestException("Invalid request");
      case "CONFIG_ERROR":
        return MsalInvalidConfigurationException(
            "Invalid configuration, please correct your settings and try again");
      case "NO_CLIENT":
        return MsalUninitializedException();
      case "CHANGED_CLIENTID":
        return MsalChangedClientIdException();
      case "INIT_ERROR":
        return MsalInitializationException();
      case "SCOPE_ERROR":
        return MsalScopeErrorException();
      case "AUTH_ERROR":
      case "UNKNOWN":
      default:
        return MsalException("Authentication error");
    }
  }

  //initialize the main client platform side
  Future _initialize() async {
    var res = <String, dynamic>{
      'clientId': this._clientId,
      'privateSession': this._privateSession
    };
    //if authority has been set, add it aswell
    if (this._authority != null) {
      res["authority"] = this._authority;
    }

    if (this._redirectUri != null) {
      res["redirectUri"] = this._redirectUri;
    }
    if (this._keychain != null) {
      res["keychain"] = this._keychain;
    }

    try {
      final result = await _channel.invokeMethod('initialize', res);
      return result;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }
}
