# Partido Client
Client App for Partido written in Flutter/Dart.

## Developer information

Recompile generated code (API, Domain model) with following command:

```flutter pub run build_runner build```

Or use this command to continuously regenerate the code if files are changed:

```flutter pub run build_runner watch```

### Release

To create a release, you need to specify the upload key's credentials and the keystore location details in a file named `key.properties` inside the `<partido-project>/android/` folder with the following contents:

```
storePassword=xyz                   # password of keystore
keyPassword=xyz                     # password of key
keyAlias=key0                       # alias of key
storeFile=../../../keystore.jks     # location of keystore (relative to <partido-project>/android/app/build.gradle)
```

This file (and the upload key / keystore) should not be uploaded to the git repository! .git-ignore contains an entry for `android/key.properties`.