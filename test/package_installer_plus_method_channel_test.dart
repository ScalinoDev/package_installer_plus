import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_installer_plus/package_installer_plus_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelPackageInstallerPlus platform = MethodChannelPackageInstallerPlus();
  const MethodChannel channel = MethodChannel('package_installer_plus');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return true;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('installApk', () async {
    expect(await platform.installApk(filePath: 'update.apk'), true);
  });
}
