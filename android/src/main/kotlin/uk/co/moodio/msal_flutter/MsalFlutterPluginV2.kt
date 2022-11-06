package uk.co.moodio.msal_flutter

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalClientException
import com.microsoft.identity.client.exception.MsalException
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception

class MsalFlutterPluginV2 : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var activity: Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var msalApp: IPublicClientApplication
    private fun isClientInitialized() = ::msalApp.isInitialized

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "msal_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext;
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {

        when (call.method) {
            "logout" -> Thread(Runnable {
                logout(
                    call.arguments<HashMap<String, Any>>(),
                    result
                )
            }).start()
            "initialize" -> initialize(call.arguments<HashMap<String, Any>>(), result)
            "loadAccounts" -> Thread(Runnable { loadAccounts(result) }).start()
            "acquireToken" -> Thread(Runnable {
                acquireToken(
                    call.arguments<HashMap<String, Any>>(), result
                )
            }).start()
            "acquireTokenSilent" -> Thread(Runnable {
                acquireTokenSilent(
                    call.arguments<HashMap<String, Any>>(),
                    result
                )
            }).start()
            else -> result.notImplemented()
        }

    }

    // initializes the PCA
    private fun initialize(args: HashMap<String, Any>?, result: MethodChannel.Result) {
        if (args == null) {
            Log.d("MsalFlutter", "error no clientId")
            result.error("NO_CONFIG", "Call must include a config", null)
            return
        }
        val configFile = MSALConfigParser.parse(args)
        try {

            MultipleAccountPublicClientApplication.create(
                context, configFile, getApplicationCreatedListener(result)
            )

        } catch (e: Throwable) {
            Log.d("MsalFlutter", "Exception thrown");
            Handler(Looper.getMainLooper()).post {
                result.error("UNKNOWN", "Unknown error occurred.", e.localizedMessage)
            }
        }
    }

    private fun acquireToken(args: HashMap<String, Any>?, result: MethodChannel.Result) {

        if (args == null) {
            Log.d("MsalFlutter", "error no clientId")
            result.error("NO_CONFIG", "Call must include a config", null)
            return
        }
        // check if client has been initialized
        if (!isClientInitialized()) {
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }
        //acquire the token
        try {
            val parameters =
                MSALTokenParametersParser.parse(activity, getAuthCallback(result), args)
            msalApp.acquireToken(parameters)
        } catch (e: MsalException) {
            Log.d("MsalFlutter", "MSAL excepton thrown on acquire token")
            handleMsalException(e, result)
        } catch (e: Throwable) {
            Log.d("MsalFlutter", "Throwable thrown");
            Handler(Looper.getMainLooper()).post {
                result.error("UNKNOWN", "An unknown error occured.", e.localizedMessage)
            }
        }
    }

    private fun acquireTokenSilent(args: HashMap<String, Any>?, result: MethodChannel.Result) {
        // check if client has been initialized
        if (!isClientInitialized()) {
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }

        //check the scopes
        if (args == null) {
            Log.d("MsalFlutter", "no scope")
            Handler(Looper.getMainLooper()).post {
                result.error("NO_SCOPE", "Call must include a scope", null)
            }
            return
        }


        //ensure accounts exist
        if (msalApp is MultipleAccountPublicClientApplication) {
            val accounts = (msalApp as MultipleAccountPublicClientApplication).accounts
            if (accounts.isEmpty()) {
                Log.d("MsalFlutter", "no accounts")
                Handler(Looper.getMainLooper()).post {
                    result.error("NO_ACCOUNT", "No accounts exist", null)
                }
                return
            }
        }


        //acquire the token and return the result
        try {
            val account = getAccountFromId(args["accountId"] as String)
            val params = MSALSilentTokenParametersParser.parse(
                args["tokenParameters"] as HashMap<String, Any>,
                account as Account,
                msalApp.configuration.defaultAuthority.authorityURL.toURI().toString(),
                getAuthCallback(result)
            )
            val authenticationResult = msalApp.acquireTokenSilentAsync(
                params
            )

        } catch (e: MsalException) {
            handleMsalException(e, result)
        } catch (e: Throwable) {
            Log.d("MsalFlutter", "Throwable thrown")
            Handler(Looper.getMainLooper()).post {
                result.error("UNKNOWN", "An unknown error occured.", e.localizedMessage)
            }
        }
    }

    private fun loadAccounts(result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }
        if (msalApp is MultipleAccountPublicClientApplication) {
            try {
                val accounts = (msalApp as MultipleAccountPublicClientApplication).accounts
                val accountList = ArrayList<HashMap<String, Any?>>()
                for (account in accounts) {
                    accountList.add(MsalAccountParse.parse(account as Account))
                }
                Handler(Looper.getMainLooper()).post {
                    result.success(accountList)
                }
            } catch (e: MsalException) {
                handleMsalException(e, result)
            } catch (e: Throwable) {
                Log.d("MsalFlutter", "Throwable thrown")
                Handler(Looper.getMainLooper()).post {
                    result.error("UNKNOWN", "An unknown error occured.", e.localizedMessage)
                }
            }
        } else {
            try {
                val account =
                    (msalApp as SingleAccountPublicClientApplication).currentAccount.currentAccount
                val accountList = ArrayList<HashMap<String, Any?>>()
                accountList.add(MsalAccountParse.parse(account as Account))
                Handler(Looper.getMainLooper()).post {
                    result.success(accountList)
                }
            } catch (e: MsalException) {
                handleMsalException(e, result)
            } catch (e: Throwable) {
                Log.d("MsalFlutter", "Throwable thrown")
                Handler(Looper.getMainLooper()).post {
                    result.error("UNKNOWN", "An unknown error occured.", e.localizedMessage)
                }
            }
        }
    }

    // logs out user from all accounts
    private fun logout(args: HashMap<String, Any>?, result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Log.d("MsalFlutter", "Client has not been initialized")
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }
        try
        {
            if (msalApp is MultipleAccountPublicClientApplication && args?.get("accountId") != null) {
                (msalApp as MultipleAccountPublicClientApplication).removeAccount(getAccountFromId(args["accountId"] as String) as Account)
            } else {
                (msalApp as SingleAccountPublicClientApplication).signOut()
            }
            Handler(Looper.getMainLooper()).post {
                result.success(true)
            }
        }
        catch (e: MsalException) {
            handleMsalException(e, result)
        } catch (e: Throwable) {
            Log.d("MsalFlutter", "Throwable thrown")
            Handler(Looper.getMainLooper()).post {
                result.error("UNKNOWN", "An unknown error occured.", e.localizedMessage)
            }
        }

    }

    // get the authentication callback object
    private fun getAuthCallback(result: MethodChannel.Result): AuthenticationCallback {
        return object : AuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Handler(Looper.getMainLooper()).post {
                    val map = MSALResultParser.parse(authenticationResult as AuthenticationResult)
                    result.success(map)
                }
            }

            override fun onError(exception: MsalException) {
                handleMsalException(exception, result)
            }

            override fun onCancel() {
                Handler(Looper.getMainLooper()).post {
                    result.error("CANCELLED", "User cancelled", "User cancelled")
                }
            }
        }
    }

    private fun getAccountFromId(id: String?): IAccount? {
        if (msalApp is MultipleAccountPublicClientApplication) {
            if (id != null && id.isNotEmpty()) {
                return (msalApp as MultipleAccountPublicClientApplication).getAccount(id)
            }
            val accounts = (msalApp as MultipleAccountPublicClientApplication).accounts
            if (accounts != null && accounts.isNotEmpty()) {
                return accounts[0]
            }
        } else {
            return (msalApp as SingleAccountPublicClientApplication).currentAccount.currentAccount
        }
        throw MsalClientException("No account found")
    }

    // get the application created listener for when initializing new PCA
    private fun getApplicationCreatedListener(result: MethodChannel.Result): IPublicClientApplication.ApplicationCreatedListener {
        Log.d("MsalFlutter", "Getting the created listener")
        return object : IPublicClientApplication.ApplicationCreatedListener {


            override fun onCreated(application: IPublicClientApplication?) {
                if (application != null) {


                    msalApp = application

                    Handler(Looper.getMainLooper()).post {
                        result.success(true)
                    }
                } else {
                    Handler(Looper.getMainLooper()).post {
                        result.success(false)
                    }
                }
            }

            override fun onError(exception: MsalException?) {
                if (exception != null) {
                    handleMsalException(exception, result)
                } else {
                    Log.d("MsalFlutter", "Error thrown without exception")
                    Handler(Looper.getMainLooper()).post {
                        result.error(
                            "INIT_ERROR", "Error initializting client", exception?.localizedMessage
                        )
                    }
                }
            }
        }
    }

    // converts an azure ad error code to a msal flutter one, and returns error
    private fun handleMsalException(exception: MsalException, result: MethodChannel.Result) {

        val errorCode: String = when (exception.errorCode) {
            "access_denied" -> "CANCELLED"
            "declined_scope_error" -> "SCOPE_ERROR"
            "invalid_request" -> "INVALID_REQUEST"
            "invalid_grant" -> "INVALID_GRANT"
            "unknown_authority" -> "INVALID_AUTHORITY"
            "unknown_error" -> "UNKNOWN"
            else -> "AUTH_ERROR"
        }

        Log.d("MsalFlutter", "Msal exception caugth ${exception.errorCode}")
        Log.d("MsalFlutter", exception.stackTraceToString())

        //return result
        Handler(Looper.getMainLooper()).post {
            result.error(errorCode, "Authentication failed", exception.localizedMessage)
        }
    }

}
