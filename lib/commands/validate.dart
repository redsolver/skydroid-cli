import "dart:io";

import "package:args/command_runner.dart";
import 'package:tint/tint.dart';
import 'package:json_schema2/json_schema2.dart';
import 'package:skydroid_cli/assets/skydroid_app_schema.dart';
import 'package:yaml/yaml.dart';

class ValidateCommand extends Command {
  @override
  String get name => "validate";

  @override
  String get description =>
      "Checks if the format of the skydroid-app.yaml file is valid";

  @override
  run() async {
    Directory projectDir = Directory.current;

    print("Validating SkyDroid app in ${projectDir.absolute.path}...");

    final skydroidAppYamlFile =
        File.fromUri(projectDir.uri.resolve('skydroid-app.yaml'));

    if (!skydroidAppYamlFile.existsSync()) {
      throw UsageException('skydroid-app.yaml file not found', '');
    }

    final fileContent = skydroidAppYamlFile.readAsStringSync();

    final Map metadataFileData = loadYaml(fileContent);

    final schema = JsonSchema.createSchema(skydroidAppSchema);

    print('Validating schema...');

    final errors = schema.validateWithErrors(metadataFileData);
    print('');
    if (errors.isEmpty) {
      print('No errors found'.green());

      stdout
        ..writeln()
        ..write('You can now publish your app by executing ')
        ..writeln('skydroid publish'.magenta());

      exit(0);
    } else {
      print('Found ${errors.length} error${errors.length > 1 ? 's' : ''}'
          .red()
          .bold());

      for (final error in errors) {
        print(
          '${error.instancePath.isEmpty ? '# (root)' : error.instancePath}: '
                  .brightYellow() +
              '${error.message}'.red() +
              ' (${error.schemaPath})'.grey(),
        );
      }
      exit(1);
    }
  }
}
