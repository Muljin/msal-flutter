import 'dart:io';

import 'package:flutter/services.dart';
import 'package:msal_flutter/src/exceptions/msal_user_interaction_required.dart';

import '../msal_flutter.dart';
import 'exceptions/msal_scope_error_exception.dart';

class MSALPublicClientApplication {
  static const MethodChannel _channel = const MethodChannel('msal_flutter');

  static Future<MSALPublicClientApplication> createPublicClientApplication(
      MSALPublicClientApplicationConfig config) async {
    try {
      final clientApplication = MSALPublicClientApplication();
      await clientApplication._initialize(config);
      return clientApplication;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> _initialize(MSALPublicClientApplicationConfig config) async {
    try {
      final result =
          await _channel.invokeMethod<bool>('initialize', config.toMap());
      return result ?? false;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  /// this is `ios` only you need to set web param before acquireing token the client
  Future<bool> initWebViewParams(
      MSALWebviewParameters webviewParameters) async {
    try {
      if (Platform.isAndroid) {
        return true;
      }
      final result = await _channel.invokeMethod<bool>(
          'initWebViewParams', webviewParameters.toMap());
      return result ?? false;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  Future<List<MSALAccount>?> loadAccounts(
      [MSALAccountEnumerationParameters? enumerationParameters]) async {
    try {
      final result = await _channel.invokeMethod<List>(
          'loadAccounts', enumerationParameters?.toMap());
      return result
          ?.map((e) => MSALAccount.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  Future<MSALResult?> acquireToken(
      MSALInteractiveTokenParameters interactiveTokenParameters) async {
    try {
      final result = await _channel.invokeMethod(
          'acquireToken', interactiveTokenParameters.toMap());
      return result != null
          ? MSALResult.fromMap(Map<String, dynamic>.from(result))
          : null;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  Future<MSALResult?> acquireTokenSilent(
      MSALSilentTokenParameters silentTokenParameters,
      MSALAccount? account) async {
    try {
      final result = await _channel.invokeMethod('acquireTokenSilent', {
        'accountId': account?.identifier,
        'tokenParameters': silentTokenParameters.toMap()
      });
      return result != null
          ? MSALResult.fromMap(Map<String, dynamic>.from(result))
          : null;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  Future<bool> logout(
      MSALSignoutParameters signoutParameters, MSALAccount account) async {
    try {
      final result = await _channel.invokeMethod<bool>('logout', {
        'accountId': account.identifier,
        'signoutParameters': signoutParameters.toMap()
      });
      return result ?? false;
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
      case "INTERACTION_REQUIRED":
        return MsalUserInteractionRequired();
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
      case "SERVER_DECLINED_SCOPES":
        return MsalScopeErrorException();
      case "AUTH_ERROR":
      case "UNKNOWN":
      default:
        return MsalException("Authentication error", errorDetails: e.message);
    }
  }
}
