# Partido Client
[![Build Status](https://ci.fosforito.net/api/badges/Fosforito/partido-client/status.svg)](https://ci.fosforito.net/Fosforito/partido-client)

Client App for Partido written in Flutter/Dart.

## Developer information

Recompile generated code (API, Domain model) with following command:

```flutter pub run build_runner build```

Or use this command to continuously regenerate the code if files are changed:

```flutter pub run build_runner watch```

### Release for Google Play Store

To prepare a release, adjust the marked entries in the file `<partido-project>/android/app/build.gradle`:

```
    compileSdkVersion 29                                # <-- set to latest SDK

    ...

    defaultConfig {
        applicationId "net.fosforito.partido"
        minSdkVersion 24                                # <-- (optional, if needed)
        targetSdkVersion 29                             # <-- set to latest SDK
        versionCode 4                                   # <-- increment every release by 1 
        versionName "2.0.0"                             # <-- increment every release pendinng on changes
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
```

To create a release for Google Play Store, you need to specify the upload key's credentials and the keystore location details in a file named `key.properties` inside the `<partido-project>/android/` folder with the following contents:

```
storePassword=xyz                   # password of keystore
keyPassword=xyz                     # password of key
keyAlias=key0                       # alias of key
storeFile=../../../keystore.jks     # location of keystore (relative to <partido-project>/android/app/build.gradle)
```

This file (and the upload key / keystore) should not be uploaded to the git repository! .git-ignore contains an entry for `android/key.properties`.

### Release for Web

Run the following command in the project root folder:

```flutter build web```

The outputs are placed in `<partido-project>/build/web` and can be served directly.

### Local testing for Web

When testing local Web Client with remote Backend, the Chrome instance must be run in insecure mode (due to CORS - Cross-Origin Resource Sharing - issues).
To do this, just create a shortcut script (for example a .bat File on Windows) with the following contents:

```
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --user-data-dir="C:\Libraries\chromeDevSession" --disable-web-security
```

Make sure that the path of the chrome.exe matches to your system. The `--user-data-dir` can be any unused location
(just to make it possible to open an insecure chrome instance along other _normal_ open chrome instances).

### Icons

Icons are generated with the flutter_launcher_icons plugin.
See [[https://pub.dev/packages/flutter_launcher_icons]] for detailed usage information.

The configuration of the plugin can be found in the `pubspec.yaml` file and the media file to be used for generation should be put in the `<partido-project>/assets/images` folder.

The command to re-generate all icons, using the image files specified in the previous configuration, is:

```flutter pub run flutter_launcher_icons:main```
