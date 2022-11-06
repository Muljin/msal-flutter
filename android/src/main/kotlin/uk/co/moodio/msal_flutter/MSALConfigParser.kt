package uk.co.moodio.msal_flutter

import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.microsoft.identity.client.Logger
import com.microsoft.identity.client.internal.configuration.LogLevelDeserializer
import com.microsoft.identity.common.internal.authorities.AzureActiveDirectoryAudienceDeserializer
import com.microsoft.identity.common.java.authorities.Authority
import com.microsoft.identity.common.java.authorities.AuthorityDeserializer
import com.microsoft.identity.common.java.authorities.AzureActiveDirectoryAudience
import java.io.File
import java.io.FileOutputStream

class MSALConfigParser {
    companion object {
        public  fun  parse(map: HashMap<String, Any>): File{

            val gson:Gson = this.getGsonForLoadingConfiguration()

            val file = File.createTempFile("config", "json", null)
//            val fos = FileOutputStream(tempFile)
//            fos.write(byteArray)
            // create a new file

            file.writeText(gson.toJson(map))
            return file
        }

        private fun getGsonForLoadingConfiguration(): Gson {
            return GsonBuilder()
                .registerTypeAdapter(
                    Authority::class.java,
                    AuthorityDeserializer()
                )
                .registerTypeAdapter(
                    AzureActiveDirectoryAudience::class.java,
                    AzureActiveDirectoryAudienceDeserializer()
                )
                .registerTypeAdapter(
                    Logger.LogLevel::class.java,
                    LogLevelDeserializer()
                )
                .create()
        }
    }
}