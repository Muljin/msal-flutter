package uk.co.moodio.msal_flutter

import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.HashMap

class MsalAccountParse {

    companion object {
       private val tz = TimeZone.getTimeZone("UTC");
       private val df =  SimpleDateFormat("yyyy-MM-dd'T'HH:mm'Z'", Locale.ENGLISH)
        fun parse(account: com.microsoft.identity.client.Account): HashMap<String, Any?> {
            val map = HashMap<String, Any?>()
            map["username"] = account.username
            map["identifier"] = account.id
            map["accountClaims"] =parseClaims( account.claims as Map<String, Any>)

            return map
        }


//    loop through the claims and change date to string
private fun parseClaims(claims: Map<String, Any>): HashMap<String, Any?> {
    df.timeZone = tz
        val map = HashMap<String, Any?>()
        for (claim in claims) {
            if (claim.value is Date) {
                map[claim.key] = df.format(claim.value)
            } else {
                map[claim.key] = claim.value
            }
        }
        return map
    }
    }
}