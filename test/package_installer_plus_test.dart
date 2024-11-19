import 'package:flutter_test/flutter_test.dart';
import 'package:package_installer_plus/package_installer_plus.dart';
import 'package:package_installer_plus/package_installer_plus_platform_interface.dart';
import 'package:package_installer_plus/package_installer_plus_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPackageInstallerPlusPlatform
    with MockPlatformInterfaceMixin
    implements PackageInstallerPlusPlatform {

  @override
  Future<bool?> installApk({required String filePath}) => Future.value(true);
}

void main() {
  final PackageInstallerPlusPlatform initialPlatform = PackageInstallerPlusPlatform.instance;

  test('$MethodChannelPackageInstallerPlus is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPackageInstallerPlus>());
  });

  test('installApk', () async {
    PackageInstallerPlus packageInstallerPlusPlugin = PackageInstallerPlus();
    MockPackageInstallerPlusPlatform fakePlatform = MockPackageInstallerPlusPlatform();
    PackageInstallerPlusPlatform.instance = fakePlatform;

    expect(await packageInstallerPlusPlugin.installApk(filePath: 'update.apk'), true);
  });
}
