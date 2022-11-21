package uk.co.moodio.msal_flutter

import android.app.Activity
import com.microsoft.identity.client.*
import com.microsoft.identity.client.TokenParameters
import java.util.*
import kotlin.collections.HashMap

//@Suppress("UNCHECKED_CAST")
class MSALTokenParametersParser {
    companion object {
        fun parse(activity: Activity,callback : AuthenticationCallback,map: HashMap<String, Any>):AcquireTokenParameters {
            val builder = AcquireTokenParameters.Builder().startAuthorizationFromActivity(activity).withCallback(callback)

            for (entry in map.entries) {
                when (entry.key) {
                    "scopes" -> builder.withScopes(entry.value as MutableList<String>)
                    "correlationId"-> builder.withCorrelationId( UUID.fromString(entry.value as String))
                    "authority"-> builder.fromAuthority(entry.value as String)
                    "extraQueryParameters" -> builder.withAuthorizationQueryStringParameters(
                        entry.value as MutableList<MutableMap.MutableEntry<String, String>>?
                    )
                    "loginHint" -> builder.withLoginHint(entry.value as String?)
                    "extraScopesToConsent" ->builder.withOtherScopesToAuthorize(entry.value as MutableList<String>?)
                    "prompt"-> builder.withPrompt(parsePrompt(entry.value as String))
                }
            }
            return  builder.build()
        }

        private fun parsePrompt(value:String):Prompt {
           when (value){

                "consent"->return Prompt.CONSENT
                "create"->return Prompt.CREATE
                "login"->return Prompt.LOGIN
                "selectAccount"->return Prompt.SELECT_ACCOUNT
                "promptIfNecessary"->return Prompt.WHEN_REQUIRED
            }
            return  Prompt.WHEN_REQUIRED
        }
    }
}