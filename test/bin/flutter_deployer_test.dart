import 'package:args/args.dart';
import 'package:test/test.dart';

import '../../bin/core/arguments/argument_parser_factory.dart';
import '../../bin/core/arguments/arguments.dart';
import '../../bin/core/build_configuration/build_config.dart';
import '../../bin/core/build_configuration/build_function.dart';
import '../../bin/core/deploy_configuration/deploy_function.dart';
import '../../bin/core/function_command.dart';
import '../../bin/core/message_show.dart';

const testArgsBuild = ["build", "--env=qa", "--proj=default", "--platform=android"];
const testArgsDeploy = ["deploy", "--env=prod", "--proj=default", "--platform=ios", "--deploy-to=tf"];
const testArgsFull = ["full", "--env=dev", "--proj=default", "--platform=ios", "--deploy-to=fb"];

void main() {
  group('CICD Testing', () {
    late ArgParser parser;

    setUp(() {
      parser = createParser();
    });

    test(
      'Empty arguments',
      () => expect(() => Arguments.parseAndCheck([], parser), throwsA(isA<ExitException>())),
    );

    test('Not complete arguments', () {
      expect(
          () => Arguments.parseAndCheck(
              ["deploy", "--proj=default", "--platform=ios", "--deploy-to=tf"], parser),
          throwsA(isA<ExitException>()));

      expect(
          () => Arguments.parseAndCheck(
              ["full", "--env=dev", "--proj=default", "--deploy-to=fb"], parser),
          throwsA(isA<ExitException>()));
    });

    test('Parsing complete arguments', () {
      final args = Arguments.parseAndCheck(testArgsFull, parser);
      expect(args.mainCommand, 'full');
      expect(args.env, 'dev');
      expect(args.proj, 'default');
      expect(args.platform, 'ios');
      expect(args.deployTo, 'fb');
    });

    test('Parse main command', () async {
      var func = CommandFunction.create('build');
      expect(func, isA<BuildCommand>());

      func = CommandFunction.create('deploy');
      expect(func, isA<DeployCommand>());

      func = CommandFunction.create('full');
      expect(func, isA<BuildAndDeployCommand>());
    });

    test('Read cd.yaml', () async {
      var config = await BuildConfig.create('default', 'dev', 'android');
      expect(config.flavor, 'dev');
      expect(config.extension, 'apk');
      expect(config.entryPointPath, 'lib/main-dev.dart');
      expect(config.flags, '--release --tree-shake-icons --split-debug-info --obfuscate');
      config = await BuildConfig.create('default', 'prod', 'ios');
      expect(config.flavor, 'prod');
      expect(config.extension, 'ipa');
      expect(config.entryPointPath, 'lib/main-prod.dart');
      expect(config.flags,
          '--export-options-plist ios/prodExportOptions.plist --release --tree-shake-icons --split-debug-info --obfuscate');

      expect(() async => await BuildConfig.create('some', 'prod', 'ios'),
          throwsA(isA<ExitException>()));
      expect(() async => await BuildConfig.create('default', 'some', 'ios'),
          throwsA(isA<ExitException>()));
      expect(() async => await BuildConfig.create('default', 'prod', 'some'),
          throwsA(isA<ExitException>()));
    });

    test('Build function', () {
      expect(() => BuildFunction.create(''), throwsA(isA<ExitException>()));
      expect(() => BuildFunction.create('some'), throwsA(isA<ExitException>()));

      expect(BuildFunction.create('android'), isA<BuildAndroid>());
      expect(BuildFunction.create('ios'), isA<BuildIos>());
    });

    test('Deploy function', () {
      expect(() => DeployFunction.create('', ''), throwsA(isA<ExitException>()));
      expect(() => DeployFunction.create('some', ''), throwsA(isA<ExitException>()));
      expect(() => DeployFunction.create('', 'some'), throwsA(isA<ExitException>()));
      expect(() => DeployFunction.create('some', 'some'), throwsA(isA<ExitException>()));
      expect(() => DeployFunction.create('ios', ''), throwsA(isA<ExitException>()));
      expect(() => DeployFunction.create('ios', 'some'), throwsA(isA<ExitException>()));
      expect(() => DeployFunction.create('', 'fb'), throwsA(isA<ExitException>()));
      expect(() => DeployFunction.create('some', 'fb'), throwsA(isA<ExitException>()));

      expect(DeployFunction.create('android', 'fb'), isA<DeployAndroidFB>());
      expect(DeployFunction.create('android', 'gp'), isA<DeployAndroidGP>());
      expect(DeployFunction.create('ios', 'fb'), isA<DeployIosFB>());
      expect(DeployFunction.create('ios', 'tf'), isA<DeployIosTF>());
    });
  });
}
