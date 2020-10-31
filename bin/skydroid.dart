#!/usr/bin/env dart

library skydroid_cli.tool;

import "dart:io";

import "package:args/command_runner.dart";
import 'package:io/ansi.dart';
import 'package:skydroid_cli/commands/publish.dart';
import 'package:skydroid_cli/commands/init.dart';

main(List<String> args) async {
  var runner = CommandRunner(
      'skydroid v0.1.1',
      '\n' +
          "Command-line tool for SkyDroid app distribution. (https://skydroid.dev)");

  runner.argParser
      .addFlag('verbose', help: 'Print verbose output.', negatable: false);

  runner..addCommand(InitCommand())..addCommand(PublishCommand());

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
