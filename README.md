# Partido Client
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/partidodev/partido-client/CI?style=flat-square)

Client App for Partido written in Flutter/Dart.

Partido is a platform independent App for sharing group expenses.

## How to contribute to the project

You can contribute in various ways - even if you're not a software developer. You can translate Partido to your language, report bugs, request features or code. Please check the [contribution guidelines](https://github.com/partidodev/partido-client/blob/main/CONTRIBUTING.md) to start.

## Developer information

### Generated code

(Re-)Compile generated code (API, Domain model) with the following command:

```flutter pub run build_runner build```

Or use this command to continuously regenerate the code if the relevant files are changed:

```flutter pub run build_runner watch```

### Local testing for Web

When testing local Web Client with remote Backend, the Chrome instance must be run in insecure mode (due to CORS - Cross-Origin Resource Sharing - issues). To do this, just create a shortcut script (for example a .bat file on Windows or .sh file on Linux) with the following contents:

On Windows:
```
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --user-data-dir="C:\Libraries\chromeDevSession" --disable-web-security
```

On Linux:
```
chrome-browser --user-data-dir="~/.chromeDevSession" --disable-web-security
```

Make sure that the path of the chrome.exe matches to your system. The `--user-data-dir` can be any unused location (just to make it possible to open an insecure chrome instance along other _normal_ open chrome instances).

### Icons

Icons are generated with the flutter_launcher_icons plugin.
See https://pub.dev/packages/flutter_launcher_icons for detailed usage information.

The configuration of the plugin can be found in the `pubspec.yaml` file and the media file to be used for generation should be put in the `<partido-project>/assets/images` folder.

The command to re-generate all icons, using the image files specified in the previous configuration, is:

```flutter pub run flutter_launcher_icons:main```

**Note:** the icons are generated for the android or iOS Apps only. To change WebApp's icons, look at the corresponding configuration in `<partido-project>/web/manifest.json` and the icon files in `<partido-project>/web/icons/`.

## Translating Partido

![POEditor](https://img.shields.io/poeditor/progress/550083/en?style=flat-square&token=36600ce7684f3410cc4469c2ff3d305c)
![POEditor](https://img.shields.io/poeditor/progress/550083/de?style=flat-square&token=36600ce7684f3410cc4469c2ff3d305c)
![POEditor](https://img.shields.io/poeditor/progress/550083/es?style=flat-square&token=36600ce7684f3410cc4469c2ff3d305c)
![POEditor](https://img.shields.io/poeditor/progress/550083/pt?style=flat-square&token=36600ce7684f3410cc4469c2ff3d305c)
![POEditor](https://img.shields.io/poeditor/progress/550083/nb?style=flat-square&token=36600ce7684f3410cc4469c2ff3d305c)

### Online with POEditor

You can contribute to existing languages or start with a new language online on poeditor.com.

Join the Project on: https://poeditor.com/join/project/nZRUu7IzH6

### Old way working directly with YAML-Files

To translate Partido to another language not available yet in the `<partido-project>/assets/i18n/` folder, copy the file `<partido-project>/assets/i18n/en.yaml` and rename it according to the new language like `<partido-project>/assets/i18n/<language>.yaml`. The file `en.yaml` always contains the latest and up to date default strings. If a specific other language file does not contain a certain translation, the default string from `en.yaml` is shown to the user.
