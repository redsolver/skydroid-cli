#!/usr/bin/env dart

library skydroid_cli.tool;

import "dart:io";

import "package:args/command_runner.dart";
import 'package:io/ansi.dart';
import 'package:skydroid_cli/commands/publish.dart';
import 'package:skydroid_cli/commands/init.dart';
import 'package:skydroid_cli/commands/validate.dart';

main(List<String> args) async {
  var runner = CommandRunner(
      'skydroid',
      '\n' +
          "Command-line tool for SkyDroid app distribution. (https://skydroid.dev) [v0.1.3]");

  runner.argParser
      .addFlag('verbose', help: 'Print verbose output.', negatable: false);

  runner
    ..addCommand(InitCommand())
    ..addCommand(PublishCommand())
    ..addCommand(ValidateCommand());

  return await runner.run(args).catchError((exc, st) {
    if (exc is String) {
      stdout.writeln(exc);
    } else {
      stderr.writeln("Oops, something went wrong: $exc");
      if (args.contains('--verbose')) {
        stderr.writeln(st);
      }
    }

    exitCode = 1;
  }).whenComplete(() {
    stdout.write(resetAll.wrap(''));
  });
}
