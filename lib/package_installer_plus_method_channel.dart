import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package_installer_plus_platform_interface.dart';

/// An implementation of [PackageInstallerPlusPlatform] that uses method channels.
class MethodChannelPackageInstallerPlus extends PackageInstallerPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('package_installer_plus');

  @override
  Future<bool?> installApk({required String filePath}) async {
    return await methodChannel.invokeMethod<bool>(
      'installApk',
      <String, Object> {
        'filePath' : filePath,
      },
    );
  }
}
