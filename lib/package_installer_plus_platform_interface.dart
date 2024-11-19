import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package_installer_plus_method_channel.dart';

abstract class PackageInstallerPlusPlatform extends PlatformInterface {
  /// Constructs a PackageInstallerPlusPlatform.
  PackageInstallerPlusPlatform() : super(token: _token);

  static final Object _token = Object();

  static PackageInstallerPlusPlatform _instance = MethodChannelPackageInstallerPlus();

  /// The default instance of [PackageInstallerPlusPlatform] to use.
  ///
  /// Defaults to [MethodChannelPackageInstallerPlus].
  static PackageInstallerPlusPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PackageInstallerPlusPlatform] when
  /// they register themselves.
  static set instance(PackageInstallerPlusPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool?> installApk({required String filePath}) {
    throw UnimplementedError('installApk() has not been implemented.');
  }
}
