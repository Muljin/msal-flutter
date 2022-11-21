package uk.co.moodio.msal_flutter

import com.microsoft.identity.client.Account
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap


class MSALResultParser {
    companion object {
        private val tz = TimeZone.getTimeZone("UTC");
        private val df = SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'", Locale.ENGLISH)
        fun parse(result: com.microsoft.identity.client.AuthenticationResult): HashMap<String, Any> {
            df.timeZone = tz

            val map = HashMap<String, Any>()
            map["accessToken"] = result.accessToken
            map["expiresOn"] = df.format(result.expiresOn)
            map["correlationId"] = result.correlationId.toString()
            map["tenantProfile"] = mapOf("tenantId" to result.tenantId)
            map["authorizationHeader"] = result.authorizationHeader
            map["scopes"] = result.scope.asList()
            map["authenticationScheme"] = result.authenticationScheme
            map["account"] = MsalAccountParse.parse(result.account as Account)
            map["authority"] = result.account.authority
            map["idToken"] = result.account.idToken.toString()
            return map
        }
    }
}