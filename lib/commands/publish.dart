import 'dart:async';
import 'dart:convert';
import "dart:io";

import "package:args/command_runner.dart";
import 'package:crypto/crypto.dart';
import 'package:io/ansi.dart';
import 'package:yaml/yaml.dart';

import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class PublishCommand extends Command {
  // final KeyCommand _key = new KeyCommand();

  @override
  String get name => "publish";

  @override
  String get description => "Publishes app according to skydroid-dev.yaml file";

  PublishCommand() {
    argParser
      ..addFlag('only-metadata',
          help:
              'Ignores APK and version changes and just uploads the Metadata file. Useful for metadata changes.',
          negatable: false);
  }

  Future uploadMetadataFile(String skynetPortalUploadUrl, File metadataFile,
      String domainName) async {
    print('Uploading new metadata file...');

    final meta = await uploadFile(skynetPortalUploadUrl, metadataFile);

    final txtRecord = "skydroid-app=1+${meta.skylink}+${meta.sha256}";

    print('');
    print(green.wrap('SUCCESS'));
    print('');
    print(
        'Please set the TXT record of ${cyan.wrap(domainName)} to ${magenta.wrap(txtRecord)}');
    print('');
  }

  @override
  run() async {
    Directory projectDir = Directory.current;

    print("Publishing SkyDroid app in ${projectDir.absolute.path}...");

    final skydroidDevYamlFile =
        File.fromUri(projectDir.uri.resolve('skydroid-dev.yaml'));

    if (!skydroidDevYamlFile.existsSync()) {
      throw UsageException('skydroid-dev.yaml file not found', '');
    }

    final str = skydroidDevYamlFile.readAsStringSync();

    final Map data = loadYaml(str);

    final String domainName = data['name'];
    final File metadataFile = File(data['metadataFile']);
    final String skynetPortal = data['skynetPortal'];

    final skynetPortalUploadUrl = '${skynetPortal}/skynet/skyfile';

    String metadataFileContent = metadataFile.readAsStringSync();

    final Map metadataFileData = loadYaml(metadataFileContent);

    if (argResults['only-metadata'] == true) {
      await uploadMetadataFile(skynetPortalUploadUrl, metadataFile, domainName);
      return;
    }

    final String checkVersionFile = data['checkVersion']['file'];
    final String checkVersionCode = data['checkVersion']['versionCode'];
    final String checkVersionName = data['checkVersion']['versionName'];

    final String checkVersionFileContent =
        File(checkVersionFile).readAsStringSync();

    final currentVersionCode = int.parse(RegExp(checkVersionCode)
        .allMatches(checkVersionFileContent)
        .first
        .group(1));

    print('Found version code: $currentVersionCode');

    final String currentVersionName = RegExp(checkVersionName)
        .allMatches(checkVersionFileContent)
        .first
        .group(1);

    print('Found version name: $currentVersionName');

    int highestVersionCode = 0;

    for (final build in (metadataFileData['builds'] ?? [])) {
      if (build['versionCode'] > highestVersionCode) {
        highestVersionCode = build['versionCode'];
      }
    }

    print('Highest existing version code: ${highestVersionCode}');

    if (highestVersionCode < currentVersionCode) {
      print('');
      print('New version, updating app...');
      print('');

      if (data['uploadBuild'].containsKey('file')) {
        print('Uploading APK...');

        final String apkFilePath = data['uploadBuild']['file'];

        final apk = await uploadFile(skynetPortalUploadUrl, File(apkFilePath));

        metadataFileContent = metadataFileContent.replaceFirst('\nbuilds:\n',
            '\nbuilds:\n  - versionName: ${currentVersionName}\n    versionCode: ${currentVersionCode}\n    sha256: ${apk.sha256}\n    apkLink: sia://${apk.skylink}\n');
      } else {
        print('Uploading APKs...');

        final buildABIs = StringBuffer();

        for (final abi in data['uploadBuild']['abis'].keys) {
          print('Uploading APK for ABI $abi...');
          final String apkFilePath = data['uploadBuild']['abis'][abi];

          final apk =
              await uploadFile(skynetPortalUploadUrl, File(apkFilePath));

          buildABIs.write(
              '      $abi:\n        sha256: ${apk.sha256}\n        apkLink: sia://${apk.skylink}\n');
        }
        metadataFileContent = metadataFileContent.replaceFirst('\nbuilds:\n',
            '\nbuilds:\n  - versionName: ${currentVersionName}\n    versionCode: ${currentVersionCode}\n    abis:\n$buildABIs');
      }

      metadataFileContent = metadataFileContent.replaceFirst(
          RegExp(
            r'^currentVersionCode:.*$',
            multiLine: true,
          ),
          'currentVersionCode: ${currentVersionCode}');
      metadataFileContent = metadataFileContent.replaceFirst(
          RegExp(
            r'^currentVersionName:.*$',
            multiLine: true,
          ),
          'currentVersionName: ${currentVersionName}');
      metadataFileContent = metadataFileContent.replaceFirst(
          RegExp(
            r'^lastUpdated:.*$',
            multiLine: true,
          ),
          'lastUpdated: ${DateTime.now().millisecondsSinceEpoch}');

      print('Writing new metadata file...');

      metadataFile.writeAsStringSync(metadataFileContent);

      await uploadMetadataFile(skynetPortalUploadUrl, metadataFile, domainName);
    }
  }

  Future<SkynetFile> uploadFile(String skynetPortalUploadUrl, File file) async {
    final hash = await file.openRead().transform(sha256).join();

    var stream = new http.ByteStream(file.openRead());
    var length = await file.length();

    var uri = Uri.parse(skynetPortalUploadUrl);

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(file.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final res = await response.stream.transform(utf8.decoder).join();

    final resData = json.decode(res);

    if (resData['skylink'] == null) throw Exception('Skynet Upload Fail');

    return SkynetFile(sha256: hash, skylink: resData['skylink']);
  }
}

class SkynetFile {
  String skylink;
  String sha256;
  SkynetFile({this.skylink, this.sha256});
}
