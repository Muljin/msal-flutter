import Flutter
import UIKit
import MSAL

public class SwiftMsalFlutterPlugin: NSObject, FlutterPlugin {
  
  //static fields as initialization isn't really required
  static var clientId : String = ""
  static var authority : String = ""
  static var redirectUri : String = ""
    static var keychain:String?

  var accessToken = String()
  var applicationContext : MSALPublicClientApplication?
  var webViewParamaters : MSALWebviewParameters?
  var currentAccount: MSALAccount?

  public static func register(with registrar: FlutterPluginRegistrar) {
      MSALGlobalConfig.loggerConfig.logMaskingLevel = .settingsMaskAllPII
      MSALGlobalConfig.loggerConfig.logLevel = .verbose
    let channel = FlutterMethodChannel(name: "msal_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftMsalFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) 
  {
    //get the arguments as a dictionary
    let dict = call.arguments! as! NSDictionary
    let scopes = dict["scopes"] as? [String] ?? [String]()
    let clientId = dict["clientId"] as? String ?? ""
    let authority = dict["authority"] as? String ?? ""
    let redirectUri = dict["redirectUri"] as? String ?? ""
    let keychain = dict["keychain"] as? String?
    let browserLogout = dict["browserLogout"] as? Bool ?? false
    let privateSession = dict["privateSession"] as? Bool ?? false

    switch( call.method ){
    case "initialize": initialize(clientId: clientId, authority: authority, result: result,redirectUri:redirectUri,keychain: keychain as? String,privateSession:privateSession)
      case "acquireToken": acquireToken(scopes: scopes, result: result)
      case "acquireTokenSilent": acquireTokenSilent(scopes: scopes, result: result)
      case "logout": logout(result: result,browserLogout: browserLogout)
      default: result(FlutterError(code:"INVALID_METHOD", message: "The method called is invalid", details: nil))
    } 
  }


    private func acquireToken(scopes: [String], result: @escaping FlutterResult)
    {
        clearAccounts()
        guard let applicationContext = self.applicationContext else {
            result(FlutterError(code: "CONFIG_ERROR", message: "Unable to find MSALPublicClientApplication", details: nil))
            return
        }
        let parameters = MSALInteractiveTokenParameters(scopes: scopes, webviewParameters: self.webViewParamaters!)
        applicationContext.acquireToken(with: parameters) { (token, error) in
            if let error = error {
                result(FlutterError(code: "AUTH_ERROR", message: "Could not acquire token: \(error)", details: error.localizedDescription))
                return
            }
            guard let tokenResult = token else {
                result(FlutterError(code: "AUTH_ERROR", message: "Could not acquire token: No result returned", details: nil))
                  return
            }
            self.accessToken = tokenResult.accessToken
            self.currentAccount = tokenResult.account
            result(self.accessToken)
        }
    }

    //removes all logged in accounts
    private func clearAccounts(){
          do {
            //delete old accounts
             let cachedAccounts = try applicationContext!.allAccounts()
             if !cachedAccounts.isEmpty {
               try applicationContext!.remove(cachedAccounts.first!)
             }
           } catch {
             //nothing to do really
           }
    }
    
    private func acquireTokenSilent(scopes: [String], result: @escaping FlutterResult)
    {
        guard self.applicationContext != nil else {
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
        //check the scopes
        if(scopes.isEmpty){
            result(FlutterError(code: "NO_SCOPE", message: "Call must include a scope", details: nil))
            return
          }
          //ensure accounts exist
        if(self.currentAccount == nil){
            result(FlutterError(code: "NO_ACCOUNT", message: "No account is available to acquire token silently for", details: nil))
            return
          }
        let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: self.currentAccount!)
        self.applicationContext!.acquireTokenSilent(with: silentParameters, completionBlock: { (msalresult, error) in
          guard let authResult = msalresult, error == nil else {
              result(FlutterError(code: "AUTH_ERROR", message: "Authentication error", details: nil))
              return
          }
          // Get access token from result
          let accessToken = authResult.accessToken
          result(accessToken)
        })
    }


    /**

     Initialize a MSALPublicClientApplication with a given clientID and authority

     - clientId:            The clientID of your application.
     - redirectUri:         A redirect URI of your application.
     */
    private func initialize(clientId: String, authority: String, result: @escaping FlutterResult,redirectUri : String,keychain:String?, privateSession: Bool) {
   //validate clientid exists
    if(clientId.isEmpty){
        result(FlutterError(code:"NO_CLIENTID", message: "Call must include a clientId", details: nil))
        return
    }
    SwiftMsalFlutterPlugin.clientId = clientId;
    SwiftMsalFlutterPlugin.authority = authority;
    SwiftMsalFlutterPlugin.keychain=keychain;
    if SwiftMsalFlutterPlugin.redirectUri.isEmpty {
        updateRedirectUri()
    } else {
        SwiftMsalFlutterPlugin.redirectUri = redirectUri;
    }
    do  {
        try self.initMSAL(result: result,privateSession:privateSession)
        loadCurrentAccount(result: result)
    } catch let error {
        result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication with error: \(error)", details: nil))
    }
  }

    // generates the default redirect uri for IOS
    private func updateRedirectUri() {
      if let bundleId = Bundle.main.bundleIdentifier {
        SwiftMsalFlutterPlugin.redirectUri = "msauth." + bundleId + "://auth"
      }
    }
    
    private func initWebViewParams(privateSession: Bool) {
        let viewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: viewController)
        if #available(iOS 13.0, *) {
//            self.webViewParamaters?.webviewType = MSALWebviewType.safariViewController
            self.webViewParamaters?.prefersEphemeralWebBrowserSession =  privateSession
        } else {
            // Fallback on earlier versions
        }
    }
    
    /**

     Initialize a MSALPublicClientApplication with a given clientID and authority
     */
    func initMSAL(result: @escaping FlutterResult, privateSession: Bool) throws {
        var config: MSALPublicClientApplicationConfig
        //setup the config, using authority if it is set, or defaulting to msal's own implementation if it's not
          if !SwiftMsalFlutterPlugin.authority.isEmpty  {
            //try creating the msal aad authority object
            do {
                //create authority url
                guard let authorityUrl = URL(string: SwiftMsalFlutterPlugin.authority) else {
                    result(FlutterError(code: "INVALID_AUTHORITY", message: "Unable to create authority URL", details: nil))
                    return
                }
                //create the msal authority and configuration
                let msalAuthority = try MSALAuthority(url: authorityUrl)
                config = MSALPublicClientApplicationConfig(clientId: SwiftMsalFlutterPlugin.clientId, redirectUri: SwiftMsalFlutterPlugin.redirectUri, authority: msalAuthority)
                // validateAuthority' is deprecated: Use knowAuthorities
                config.knownAuthorities = [msalAuthority]
                if(SwiftMsalFlutterPlugin.keychain != nil){
                    config.cacheConfig.keychainSharingGroup = SwiftMsalFlutterPlugin.keychain!
                }
            } catch {
                //return error if exception occurs
                result(FlutterError(code: "INVALID_AUTHORITY", message: "invalid authority", details: nil))
                return
            }
          } else {
            config = MSALPublicClientApplicationConfig(clientId: SwiftMsalFlutterPlugin.clientId, redirectUri: SwiftMsalFlutterPlugin.redirectUri, authority: nil)
          }
        //create the application and return it
        do {
            let application = try MSALPublicClientApplication(configuration: config)
//            'validateAuthority' is deprecated: Use knowAuthorities in MSALPublicClientApplicationConfig instead
//            application.validateAuthority = false
            self.applicationContext = application
            initWebViewParams(privateSession:privateSession)
            result(true)
        } catch let error {
            //return error if exception occurs
            result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication  with error: \(error)", details: nil))
            return
        }
    }



    func loadCurrentAccount(result: @escaping FlutterResult) {
        guard let applicationContext = self.applicationContext else { return }
        let msalParameters = MSALParameters()
        msalParameters.completionBlockQueue = DispatchQueue.main
        applicationContext.getCurrentAccount(with: msalParameters, completionBlock: { (currentAccount, previousAccount, error) in
            if let error = error {
              result(FlutterError(code: "CONFIG_ERROR", message: "Couldn't query current account with error: \(error)", details: nil))
                return
            }
            if let currentAccount = currentAccount {
                self.currentAccount = currentAccount
                return
            }
            self.accessToken = ""
            self.currentAccount = nil
        })
    }

    private func logout(result: @escaping FlutterResult,browserLogout:Bool)
    {
       guard let applicationContext = self.applicationContext else {
        
        result(FlutterError(code: "CONFIG_ERROR", message: "Unable to find MSALPublicClientApplication", details: nil))
        return
          }
            guard let account = self.currentAccount else {
                result(FlutterError(code: "NO_ACCOUNT", message: "No account is available to acquire token silently for", details: nil))
                return
            }
            do {
                /**
                 Removes all tokens from the cache for this application for the provided account
                 - account:    The account to remove from the cache
                 */
                let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!)
                signoutParameters.signoutFromBrowser = browserLogout
                applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
                    if let error = error {
                     result(FlutterError(code: "CONFIG_ERROR", message: "Couldn't sign out account with error: \(error)", details: nil))
                        return
                    }
                    self.accessToken = ""
                    self.currentAccount = nil
                    result(true)
                })
            }
    }
}
