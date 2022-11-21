//  Created by omar mgerbie on 26/9/2022.
//

import Foundation
import MSAL

extension MSALAccount {


    var dictionary: [String: Any?] {
        return ["username": username,
                "identifier": identifier,
                "environment": environment,
                "accountClaims": accountClaims,
                "isSSOAccount": isSSOAccount
        ]
    }
    var nsDictionary: NSDictionary {
        return dictionary as NSDictionary
    }
}

extension MSALWebviewParameters {
    func fromDict(dictionary: NSDictionary) {
        if dictionary["webviewType"] != nil {
            webviewType = MSALWebviewType.fromString(entry: dictionary["webviewType"] as? String)
        }
        if #available(iOS 13.0, *) {
            prefersEphemeralWebBrowserSession = dictionary["prefersEphemeralWebBrowserSession"] as? Bool ?? false
        }
        if dictionary["presentationStyle"] != nil {
            presentationStyle = UIModalPresentationStyle.fromString(entry: dictionary["presentationStyle"] as? String)
        }


    }
}

extension MSALWebviewType {
    /// from string to MSALWebviewType
    static func fromString(entry: String?) -> MSALWebviewType {
        switch entry {
        case "safariViewController":
            return MSALWebviewType.safariViewController
        case "authenticationSession":
            return MSALWebviewType.authenticationSession
        case "wkWebView":
            return MSALWebviewType.wkWebView
        case "default":
            return MSALWebviewType.default
        default:
            return MSALWebviewType.default
        }
    }
}

extension UIModalPresentationStyle {
    static func fromString(entry: String?) -> UIModalPresentationStyle {
        switch entry {
        case "fullScreen":
            return .fullScreen
        case "pageSheet":
            return .pageSheet
        case "formSheet":
            return .formSheet
        case "currentContext":
            return .currentContext
        case "custom":
            return .custom
        case "overFullScreen":
            return .overFullScreen
        case "overCurrentContext":
            return .overCurrentContext
        case "popover":
            return .popover
        case "none":
            return .none
        case "automatic":
            if #available(iOS 13.0, *) {
                return .automatic
            } else {
                return .fullScreen
            }
        default:
            return .fullScreen
        }
    }
}

extension MSALPublicClientApplicationConfig {
    static func fromDict(dictionary: NSDictionary) throws -> MSALPublicClientApplicationConfig {
       var  authority :MSALAuthority
        do {
            guard let result = try MSALAuthority.fromString(entry: dictionary["authority"] as? String) else {
                fatalError("guard failure handling has not been implemented")
            }
            authority =  result
        } catch let  error {
            throw  error
        }
        let config = MSALPublicClientApplicationConfig(clientId: dictionary["clientId"] as! String, redirectUri: (dictionary["redirectUri"] as? String) ?? self.generateRedirectUri(), authority: authority)
        config.bypassRedirectURIValidation = dictionary["bypassRedirectURIValidation"] as? Bool ?? false
        config.clientApplicationCapabilities = dictionary["clientApplicationCapabilities"] as? [String]
        config.extendedLifetimeEnabled = dictionary["extendedLifetimeEnabled"] as? Bool ?? false
    var knownAuthorities : [MSALAuthority] = [authority]
            if dictionary["knownAuthorities"] != nil {
                for item in dictionary["knownAuthorities"] as! [String] {
                    do{
                let auth = try MSALAuthority.fromString(entry: item)!
                        knownAuthorities.insert(auth,at:0)
            } catch {

            }
                }

            }


    config.knownAuthorities = knownAuthorities
        if dictionary["cacheConfig"] != nil {
            config.cacheConfig.fromDict(dict: dictionary["cacheConfig"] as! NSDictionary)
        }
        config.multipleCloudsSupported = dictionary["multipleCloudsSupported"] as? Bool ?? false
        config.sliceConfig = MSALSliceConfig.fromDict(dict: dictionary["sliceConfig"] as? NSDictionary)
        let tokenBuff = dictionary["tokenExpirationBuffer"] as? Double
        if tokenBuff != nil {
            config.tokenExpirationBuffer = tokenBuff!
        }
        return config
    }

    // generates the default redirect uri for IOS

    static private func generateRedirectUri() -> String? {
        if let bundleId = Bundle.main.bundleIdentifier {
            return "msauth." + bundleId + "://auth"
        }
        return nil
    }
}

extension MSALAuthority {
    static func fromString(entry: String?) throws -> MSALAuthority? {
        if entry?.isEmpty == false {
            guard let authorityUrl = URL(string: entry!) else {
                return nil
            }
            return try MSALAuthority(url: authorityUrl);
        }
        return nil
    }
}

extension MSALCacheConfig {
    func fromDict(dict: NSDictionary) {
        let keychain = dict["keychainSharingGroup"] as? String
        if keychain?.isEmpty == false {
            keychainSharingGroup = keychain!
        }

    }
}

extension MSALSliceConfig {
    static func fromDict(dict: NSDictionary?) -> MSALSliceConfig? {
        if dict != nil {
            let slincConfig = MSALSliceConfig(slice: dict!["slice"] as? String, dc: dict!["dc"] as? String)
            return slincConfig
        }
        return nil
    }
}

extension MSALInteractiveTokenParameters {
    static func fromDict(dict: NSDictionary, param: MSALWebviewParameters) -> MSALInteractiveTokenParameters {
        var tokenParam: MSALInteractiveTokenParameters
        tokenParam = MSALInteractiveTokenParameters(scopes: dict["scopes"] as! [String], webviewParameters: param)
        tokenParam.fromDict(dict: dict)
        if dict["authority"] != nil {
            do {
                tokenParam.authority = try MSALAuthority.fromString(entry: dict["authority"] as? String)
            } catch {
    //            Do Nothing
            }
        }

        tokenParam.promptType = MSALPromptType.fromString(entry: dict["promptType"] as? String)
        tokenParam.extraScopesToConsent = dict["extraScopesToConsent"] as? [String]
        tokenParam.loginHint = dict["loginHint"] as? String

        return tokenParam
    }

}

extension MSALPromptType {
    static func fromString(entry: String?) -> MSALPromptType {
        switch entry {
        case "consent":
            return MSALPromptType.consent
        case "create":
            return MSALPromptType.create
        case "login":
            return MSALPromptType.login
        case "promptIfNecessary":
            return MSALPromptType.promptIfNecessary
        case "selectAccount":
            return MSALPromptType.selectAccount
        case "defaultType":
            return MSALPromptType.default
        default:
            return MSALPromptType.default
        }
    }
}

extension MSALTokenParameters {
    func fromDict(dict: NSDictionary) {
        extraQueryParameters = dict["extraQueryParameters"] as? [String: String]
        correlationId = UUID(uuidString: dict["correlationId"] as? String ?? "")

    }
}

extension MSALSilentTokenParameters {
    static func fromDict(dict: NSDictionary, account: MSALAccount) -> MSALSilentTokenParameters {
        var silentParam: MSALSilentTokenParameters

        silentParam = MSALSilentTokenParameters(scopes: dict["scopes"] as! [String], account: account)

        if dict["forceRefresh"] != nil {
            silentParam.forceRefresh = dict["forceRefresh"] as? Bool ?? false
        }
        silentParam.fromDict(dict: dict)
//        silentParam.
        return silentParam
    }
}

extension MSALSignoutParameters {
    static func fromDict(dict: NSDictionary, param: MSALWebviewParameters) -> MSALSignoutParameters {
        let signOutParam = MSALSignoutParameters(webviewParameters: param)
        signOutParam.signoutFromBrowser = dict["signoutFromBrowser"] as? Bool ?? false
        signOutParam.wipeAccount = dict["wipeAccount"] as? Bool ?? false
        signOutParam.wipeCacheForAllAccounts = dict["wipeCacheForAllAccounts"] as? Bool ?? false
        return signOutParam
    }
}

extension MSALAccountEnumerationParameters {
    static func fromDict(dict: NSDictionary?) -> MSALAccountEnumerationParameters {
        if (dict?["identifier"] != nil) {
            if (dict?["username"] != nil) {
                return MSALAccountEnumerationParameters(identifier: dict!["identifier"] as? String, username: dict!["username"] as! String)
            }
            return MSALAccountEnumerationParameters(identifier: dict!["identifier"] as! String)
        } else if (dict?["tenantProfileIdentifier"] != nil) {
            return MSALAccountEnumerationParameters(tenantProfileIdentifier: dict!["tenantProfileIdentifier"] as! String)
        }
        return MSALAccountEnumerationParameters()
    }
}

extension MSALResult {

    func toDict() -> [String: Any?] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return ["accessToken": accessToken, "account": account.nsDictionary,
                "authenticationScheme": authenticationScheme,
                "authority": authority.url.absoluteString,
                "authorizationHeader": authorizationHeader,
                "correlationId": correlationId.uuidString,
                "expiresOn": expiresOn != nil ? dateFormatter.string(from: expiresOn!) : nil,
                "extendedLifeTimeToken": extendedLifeTimeToken,
                "idToken": idToken,
                "scopes": scopes,
                "tenantProfile": tenantProfile.toDict(),

        ]
    }
}

extension MSALTenantProfile {
    func toDict() -> [String: Any?] {
        return ["tenantId": tenantId, "claims": claims, "environment": environment, "identifier": identifier, "isHomeTenantProfile": isHomeTenantProfile]
    }
}
