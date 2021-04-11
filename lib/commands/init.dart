import "dart:io";

import "package:args/command_runner.dart";
import 'package:io/ansi.dart';

class InitCommand extends Command {
  @override
  String get name => "init";

  @override
  String get description =>
      "Creates a skydroid-app.yaml and skydroid-dev.yaml file in the current directory";

  InitCommand() {}

  @override
  run() async {
    Directory projectDir = Directory.current;
    print("Initializing SkyDroid app in ${projectDir.absolute.path}...");

    bool isFlutterApp =
        File.fromUri(projectDir.uri.resolve('pubspec.yaml')).existsSync();

    if (isFlutterApp) {
      print(white.wrap('Detected Flutter app...'));
    }

    final skydroidAppYamlFile =
        File.fromUri(projectDir.uri.resolve('skydroid-app.yaml'));

    if (skydroidAppYamlFile.existsSync()) {
      print(red.wrap('skydroid-app.yaml file already exists, skipping...'));
    } else {
      final millis = DateTime.now().millisecondsSinceEpoch;

      skydroidAppYamlFile.createSync(recursive: true);

      skydroidAppYamlFile.writeAsStringSync('''name: # TODO Your app's name
authorName: # TODO Your name
packageName: # TODO Your app's android package name

icon: # TODO The link to your app's icon (https:// or sia://)

localized:
  en-US:
    description: |-
      Replace # TODO Add description
      this text
      with your
      app description
    summary: # TODO Add short summary of your app

# !!! DO NO EDIT BELOW THIS LINE !!!

builds:

currentVersionName:
currentVersionCode:

added: $millis
lastUpdated: $millis
''');
      print(green.wrap('Created skydroid-app.yaml file.'));
    }

    final skydroidDevYamlFile =
        File.fromUri(projectDir.uri.resolve('skydroid-dev.yaml'));

    if (skydroidDevYamlFile.existsSync()) {
      print(red.wrap('skydroid-dev.yaml file already exists, skipping...'));
    } else {
      skydroidDevYamlFile.createSync(recursive: true);

      skydroidDevYamlFile.writeAsStringSync('''name: # TODO Your domain name
metadataFile: skydroid-app.yaml
skynetPortal: https://siasky.net

checkVersion:
  file: ${isFlutterApp ? 'pubspec.yaml' : 'app/build.gradle'}
  versionCode: ${isFlutterApp ? r"'version:\s.+\+(\d+)'" : "'versionCode\\s+(\\d+)'"}
  versionName: ${isFlutterApp ? r"'version:\s(.+)\+'" : "'versionName.+\"(.+)\"'"}

uploadBuild:
  file: ${isFlutterApp ? 'build/app/outputs/flutter-apk/app-release.apk' : 'app/release/app-release.apk'}

updateMetadataFile:
  updateWhatsNew: false

# uploadMetadata:
''');
      print(green.wrap('Created skydroid-dev.yaml file.'));
    }

    print('');

    print(green.wrap('Successfully initialized SkyDroid app.'));

    stdout
      ..writeln()
      ..writeln(
          'Congratulations! You are almost ready to publish your app on SkyDroid.')
      ..writeln()
      ..writeln(cyan.wrap(
          'Please check the skydroid-app.yaml and skydroid-dev.yaml files and change the values to suit your app.'))
      ..writeln()
      ..write('Then you can validate that the file is correct using ')
      ..writeln(magenta.wrap('skydroid validate'))
      ..writeln()
      ..write('And finally you can publish your app by executing ')
      ..writeln(magenta.wrap('skydroid publish'));
  }
}
