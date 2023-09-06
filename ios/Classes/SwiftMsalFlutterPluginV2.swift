import Flutter
import UIKit
import MSAL


public class SwiftMsalFlutterPluginV2: NSObject, FlutterPlugin {

    static public var customWebView: WKWebView?

    //static fields as initialization isn't really required

    var accessToken = String()
    var applicationContext: MSALPublicClientApplication?
    var webViewParameters: MSALWebviewParameters?
    var currentAccount: MSALAccount?

    public static func register(with registrar: FlutterPluginRegistrar) {
        MSALGlobalConfig.loggerConfig.logMaskingLevel = .settingsMaskAllPII
        MSALGlobalConfig.loggerConfig.logLevel = .verbose
        let channel = FlutterMethodChannel(name: "msal_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMsalFlutterPluginV2()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch (call.method) {
            case "initialize": initialize(result: result, dict: call.arguments as! NSDictionary)
            case "initWebViewParams": initWebViewParams(result: result, dict: call.arguments as! NSDictionary)
            case "loadAccounts": loadAccounts( result: result,  dict: call.arguments as? NSDictionary)
            case "acquireToken": acquireToken(result: result, dict: call.arguments as! NSDictionary)
            case "acquireTokenSilent": acquireTokenSilent(result: result, dict: call.arguments as! NSDictionary)
            case "logout": logout(result: result,dict:  call.arguments as! NSDictionary)
            default: result(FlutterError(code: "INVALID_METHOD", message: "The method called is invalid", details: nil))
        }

    }


    /**

     Initialize a MSALPublicClientApplication with a given clientID and authority

     - clientId:            The clientID of your application.
     - redirectUri:         A redirect URI of your application.
     */
    private func initialize(result: @escaping FlutterResult, dict: NSDictionary) {


        do {
            let config: MSALPublicClientApplicationConfig = try MSALPublicClientApplicationConfig.fromDict(dictionary: dict)
            let application = try MSALPublicClientApplication(configuration: config)
            applicationContext = application
            result(true)
            return
        } catch let error {
            //return error if exception occurs
            result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication  with error: \(error)", details: nil))
            return
        }
    }

    private func loadAccounts(result: @escaping FlutterResult,dict: NSDictionary?){

        self.applicationContext!.accountsFromDevice(for: MSALAccountEnumerationParameters.fromDict(dict: dict), completionBlock:{(accounts, error) in
            if error != nil
            {
                result(FlutterError(code: "NO_ACCOUNTS", message: "no recent accounts", details: nil))
                //Handle error
            }
            guard let accountObjs = accounts else {
                result(FlutterError(code: "NO_ACCOUNTS", message: "no recent accounts", details: nil))
                return}
            let map = accountObjs.map{$0.nsDictionary} as [NSDictionary]

            result(map)

        });

    }

    private func acquireToken(result: @escaping FlutterResult, dict: NSDictionary) {
        guard let applicationContext = applicationContext else {
            result(FlutterError(code: "CONFIG_ERROR", message: "Unable to find MSALPublicClientApplication", details: nil))
            return
        }
        guard let webViewParameters = webViewParameters else {
            result(FlutterError(code: "CONFIG_ERROR", message: "webViewParameters is not initialized", details: nil))
            return
        }
        let parameters = MSALInteractiveTokenParameters.fromDict(dict: dict, param: webViewParameters)
        applicationContext.acquireToken(with: parameters) { (token, error) in
            if let error = error {
                result(FlutterError(code: self.getErrorCode(error:error), message: "Could not acquire token: \(error)", details: error.localizedDescription))
                return
            }
            guard let tokenResult: MSALResult = token else {
                result(FlutterError(code: "AUTH_ERROR", message: "Could not acquire token: No result returned", details: nil))
                return
            }
            result(tokenResult.toDict())
            return
        }
    }

    private func acquireTokenSilent(result: @escaping FlutterResult, dict: NSDictionary)  {
        guard applicationContext != nil else {
            result(FlutterError(code: "CONFIG_ERROR", message: "Call must include an MSALPublicClientApplication", details: nil))
            return
        }
        /**
           Acquire a token for an existing account silently
           - forScopes:           Permissions you want included in the access token received
           in the result in the completionBlock. Not all scopes are
           guaranteed to be included in the access token returned.
           - account:             An account object that we retrieved from the application object before that the
           authentication flow will be locked down to.
           */
        var account: MSALAccount
        do {


            account = try getAccountById(id: dict["accountId"] as? String)

        } catch {
            result(FlutterError(code: "NO_ACCOUNT", message: "No account is available to acquire token silently for", details: nil))
            return
        }


        let silentParameters = MSALSilentTokenParameters.fromDict(dict: dict["tokenParameters"] as! NSDictionary, account: account)
        self.applicationContext!.acquireTokenSilent(with: silentParameters, completionBlock: { (tokenResult, error) in
            guard let authResult = tokenResult, error == nil else {
                result(FlutterError(code: self.getErrorCode(error:error), message: "Authentication error \(String(describing: error))", details: error?.localizedDescription))
                return
            }
            result(authResult.toDict())
        })
    }

    private func logout(result: @escaping FlutterResult, dict: NSDictionary )
    {
        guard let applicationContext = self.applicationContext else {

            result(FlutterError(code: "CONFIG_ERROR", message: "Unable to find MSALPublicClientApplication", details: nil))
            return
        }
        guard let webViewParameters = self.webViewParameters else {

            result(FlutterError(code: "CONFIG_ERROR", message: "Unable to find webViewParameters", details: nil))
            return
        }
        do {
            /**
                 Removes all tokens from the cache for this application for the provided account
                 - account:    The account to remove from the cache
                 */
            var account: MSALAccount
            do {


                account = try getAccountById(id: dict["accountId"] as? String)

            } catch {
                result(FlutterError(code: "NO_ACCOUNT", message: "No account is available to acquire token silently for", details: nil))
                return
            }
            let signoutParameters = MSALSignoutParameters.fromDict(dict: dict["signoutParameters"] as! NSDictionary, param:  webViewParameters)
            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                if let error = error {
                    result(FlutterError(code: "CONFIG_ERROR", message: "Couldn't sign out account with error: \(error)", details: nil))
                    return
                }
                result(true)
            })
        }
    }

    private func initWebViewParams(result: @escaping FlutterResult, dict: NSDictionary) {
        let viewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
        webViewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        webViewParameters?.fromDict(dictionary: dict)
        if (SwiftMsalFlutterPluginV2.customWebView != nil) {
            webViewParameters?.customWebview = SwiftMsalFlutterPluginV2.customWebView
        }
        result(true)

    }

    private func getAccountById(id: String?) throws -> MSALAccount {
        do {
            if(id == nil){
                let accounts = try self.applicationContext!.allAccounts()
                if(accounts.count > 0){
                    return accounts[0]
                }
                else{
                    throw NSError(domain: "NO_ACCOUNT", code: 0, userInfo: nil)

                }
            }
            else{
                return try self.applicationContext!.account(forIdentifier: id!)
            }
        } catch let error {
            throw  error
        }
    }

    private func getErrorCode(error: Error?) -> String
    {
        guard let error = error as NSError? else { return "AUTH_ERROR"; }

        if error.domain == MSALErrorDomain, let errorCode = MSALError(rawValue: error.code)
        {
            switch errorCode
            {
                case .interactionRequired:
                    return "INTERACTION_REQUIRED"
                case .serverDeclinedScopes:
                    return "SERVER_DECLINED_SCOPES"
                case .serverProtectionPoliciesRequired:
                    return "SERVER_PROTECTION_POLICIES_REQUIRED"
                case .userCanceled:
                    return "CANCELLED"
                case .internal:
                    return "INTERNAL_ERROR"
                default:
                    return "AUTH_ERROR"
            }
        }
                
        // Handle no internet connection.
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorNotConnectedToInternet
        {
            return "CONNECTION_ERROR"
        }

        return "AUTH_ERROR"

    }
}
