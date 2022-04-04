## 2.0.0-beta.2
* broswser privateSession ios-only.
* msal android bumpup to 2.2.3. ``Note:`` add `authorization_in_current_task:false` to msal_default_config.json
## 2.0.0-beta.1
* change default kaychain feature
* logout from browser
## 2.0.0-alpha.5
* Added new exception type for invalid grant for Dart and Android libs.
## 2.0.0-alpha.4
* Updated to allow being reinitialized in android
## 2.0.0-alpha.3
* Updated podspec file to new identity and increased version
## 2.0.0-alpha.2
* Updating iOS implementation to match new api
* Update MSAL flutter library
* Update iOS deployment target to 9.0
* Set minimum flutter sdk to >=1.10.0
## 2.0.0-alpha.1
* Updated to V2 library for Android
* Updated Android implementation to utalise new plugin interfaces
* Improvements to kotlin implementation
* Changed to new repoistory
* Added null safety
* Updated license to The 3-Clause BSD License
## 1.0.0+2
* Updates to readme in regards to kotlin static field issues.
## 1.0.0+1
* Added some more information to readme for clarity
## 1.0.0
* New API, including requirement to initialize
* New static async factory method
* Removal of old constructor
* Updated iOS MSAL package to version ~>1.0.3
* Updated Android MSAL package to version 1.0.+
* Added ability to use b2clogin.com, the new preferred authority
* Migrated to Android-X
* logout now returns a value
* Now compatiable with iOS 13
## 0.1.2
* Added initial logout functionality
## 0.1.1
* Added nullcheck on interactive callback to avoid crashes when other plugins callback before msal is initialized
## 0.1.0
* Released of first beta version.
* Small bits of formatting cleanup
## 0.0.5
* Added new custom exception for returning and handling login errors.
## 0.0.4
* added swift version to podspec
* added change log for 0.0.3
* testing changes to ensure easier compatiability with new flutter projects
* fixes to the readme documentation
## 0.0.3
* Removed errors from displaying in returned error message in anticipation to change error handling to throw exceptions
## 0.0.2
* Removed unused pub dependency
* Removed unused resources
* removed intent filter from plugin which was pointing to example app client id
## 0.0.1
* Initial release includes the basic functionality and api for a PublicClientApplication capable of getting tokens interactivity and silently for a single user account at a time
