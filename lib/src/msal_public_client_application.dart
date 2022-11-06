import 'dart:io';

import 'package:flutter/services.dart';
import 'package:msal_flutter/src/models/msal_account.dart';
import 'package:msal_flutter/src/models/msal_public_client_application_config.dart';
import 'package:msal_flutter/src/models/msal_result.dart';
import 'package:msal_flutter/src/models/msal_signout_parameters.dart';

import 'models/msal_account_enumeration_parameters.dart';
import 'models/msal_interactive_token_parameters.dart';
import 'models/msal_silent_token_parameters.dart';
import 'models/msal_webview_parameters.dart';

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
      final result = await _channel.invokeMethod<bool>('initialize', config.toMap()..removeWhere((key, value) => value==null));
      return result??false;
    } on PlatformException catch (e) {
      throw e;
    }
  }
  /// this is `ios` only you need to set web param before initializing the client 
  Future<bool> initWebViewParams(MSALWebviewParameters webviewParameters) async {
    try {
      if(Platform.isAndroid){
        return true;
      }
      final result = await _channel.invokeMethod<bool>('initWebViewParams', webviewParameters.toMap()..removeWhere((key, value) => value==null));
      return result??false;
    } on PlatformException catch (e) {
      throw e;
    }
  }
  Future<List<MSALAccount>?> loadAccounts([MSALAccountEnumerationParameters? enumerationParameters]) async {
    try {
      final result = await _channel.invokeMethod<List>('loadAccounts', enumerationParameters?.toMap()?..removeWhere((key, value) => value==null));
      return result?.map((e) => MSALAccount.fromMap(Map<String,dynamic>.from(e))).toList();
    } on PlatformException catch (e) {
      throw e;
    }
  }
  Future<MSALResult?> acquireToken(MSALInteractiveTokenParameters interactiveTokenParameters) async {
    try {
      final result = await _channel.invokeMethod('acquireToken', interactiveTokenParameters.toMap()..removeWhere((key, value) => value==null));
      return result!=null?MSALResult.fromMap(Map<String,dynamic>.from(result) ):null;
    } on PlatformException catch (e) {
      throw e;
    }
  }
  Future<MSALResult?> acquireTokenSilent(MSALSilentTokenParameters silentTokenParameters,MSALAccount account) async {
    try {
      final result = await _channel.invokeMethod('acquireTokenSilent', {'accountId':account.identifier,'tokenParameters':silentTokenParameters.toMap()..removeWhere((key, value) => value==null)} );
      return result!=null?MSALResult.fromMap(Map<String,dynamic>.from(result)):null;
    } on PlatformException catch (e) {
      throw e;
    }
  }
  Future<bool> logout(MSALSignoutParameters signoutParameters,MSALAccount account) async {
    try {
      final result = await _channel.invokeMethod<bool>('logout', {'accountId':account.identifier,'signoutParameters':signoutParameters.toMap()..removeWhere((key, value) => value==null)} );
      return result??false;
    } on PlatformException catch (e) {
      throw e;
    }
  }
}
