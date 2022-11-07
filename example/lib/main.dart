import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msal_flutter/msal_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _authority =
      "_authority";
  static const String _iosRedirectUri = "_iosRedirectUri";
  static const String _androidRedirectUri = "_androidRedirectUri";
  static const String _clientId = "_clientId";
  String _output = 'NONE';
  final config = MSALPublicClientApplicationConfig(
    androidRedirectUri: _androidRedirectUri,
    iosRedirectUri: _iosRedirectUri,
    clientId: _clientId,androidConfig: MSALAndroidConfig(authorities:[Authority(authorityUrl: Uri.parse(_authority))] ),
    authority: Uri.parse(_authority),
  );

  MSALPublicClientApplication? pca;
  List<MSALAccount>? accounts;

  Future<void> _acquireToken() async {
    print("called acquiretoken");
    //create the PCA if not already created
    if (pca == null) {
      print("creating pca...");
      pca = await MSALPublicClientApplication.createPublicClientApplication(
          config);
        await  pca!.initWebViewParams(MSALWebviewParameters());
    }

    print("pca created");

    String res = '';
    try {
      MSALResult? resp = await pca!.acquireToken(MSALInteractiveTokenParameters(
          scopes: ['scopes']));
      res = resp?.account.identifier?? 'noAuth';
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token. Unspecified reason";
    }

    setState(() {
      _output = res;
    });
  }

  Future<void> _loadAccount() async {
    if (pca == null) {
      print("initializing pca");
      pca = await MSALPublicClientApplication.createPublicClientApplication(
          config);
        await  pca!.initWebViewParams(MSALWebviewParameters());

    }
    try {
      final result = await pca!.loadAccounts();
      if (result != null) {
        accounts = result;
      }
    } catch (e) {
      log(e.toString());
    }
     setState(() {
    });
  }

  Future<void> _acquireTokenSilently() async {
    if (pca == null) {
      print("initializing pca");
      pca = await MSALPublicClientApplication.createPublicClientApplication(
          config);
        await  pca!.initWebViewParams(MSALWebviewParameters());

    }

    String res = 'res';
    try {
      if (accounts?.isNotEmpty ==true) {
        final response = await pca!.acquireTokenSilent(
            MSALSilentTokenParameters(
              scopes: ['scopes'],
              // overrideAuthority: Authority(authorityUrl: Uri.parse(_authority)),
            ),
            accounts!.first);
        res = response?.account.identifier ?? '';
      }
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token silently!";
    }

    print("Got token");
    print(res);

    setState(() {
      _output = res;
    });
  }

  Future _logout() async {
    print("called logout");
    if (pca == null) {
      print("initializing pca");
      pca = await MSALPublicClientApplication.createPublicClientApplication(
          config);
        await  pca!.initWebViewParams(MSALWebviewParameters());

    }

    print("pca is not null");
    String res;
    try {
      if (accounts?.isNotEmpty == true) {
        final resp =
            await pca!.logout(MSALSignoutParameters(), accounts!.first);

      }
      res = "Account removed";
    } on MsalException {
      res = "Error signing out";
    } on PlatformException catch (e) {
      res = "some other exception ${e.toString()}";
    }

    print("setting state");
    setState(() {
      _output = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _acquireToken,
                child: Text('AcquireToken()'),
              ),
              
              ElevatedButton(
                  onPressed: _loadAccount,
                  child: Text('loadAccount()')),
              ElevatedButton(
                  onPressed: _acquireTokenSilently,
                  child: Text('AcquireTokenSilently()')),
              ElevatedButton(onPressed: _logout, child: Text('Logout')),
              Text(_output),
              Expanded(child: ListView.builder(itemCount: accounts?.length??0,
                itemBuilder: (context, index) {
                  final item = accounts![index];
                return ListTile(title:Text(item.username??item.identifier) ,);
              },))
            ],
          ),
        ),
      ),
    );
  }
}
