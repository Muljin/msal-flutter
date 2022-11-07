//
// Created by omar mgerbie on 6/10/2022.
//

import Foundation
import MSAL

class InterActiveResult {
    var token: String?
    var account: MSALAccount?

    init(token: String, account: MSALAccount) {
        self.token = token
        self.account = account
    }

    func toDict() -> NSDictionary {
        return ["token": token, "account": account]
    }
}