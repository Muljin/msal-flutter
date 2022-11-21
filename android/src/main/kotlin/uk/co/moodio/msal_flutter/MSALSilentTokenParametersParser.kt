package uk.co.moodio.msal_flutter

import com.microsoft.identity.client.Account
import com.microsoft.identity.client.AcquireTokenSilentParameters
import com.microsoft.identity.client.AuthenticationCallback

class MSALSilentTokenParametersParser {
    companion object {
        fun parse(
            map: HashMap<String, Any>,
            account: Account,
            authority: String,
            callback: AuthenticationCallback?,

        ): AcquireTokenSilentParameters {
            val parameters = AcquireTokenSilentParameters.Builder()
            if(callback != null){
                parameters.withCallback(callback)
            }
            if (map.containsKey("scopes")) {
                parameters.withScopes(map["scopes"] as List<String>)
            } else {
                throw Exception("Scopes are required")
            }
            parameters.forAccount(account)
            parameters.forceRefresh((map["forceRefresh"] as Boolean?) ?: false)
            if (map.containsKey("authority") && map["authority"] != null) {
                parameters.fromAuthority(map["authority"] as String)
            }else {
                parameters.fromAuthority(authority)
            }
            if (map.containsKey("correlationId")) {
                parameters.withCorrelationId(java.util.UUID.fromString(map["correlationId"] as String))
            }
            if (map.containsKey("resource")) {
                parameters.withResource(map["resource"] as String)
            }
            return parameters.build()
        }
    }
}
