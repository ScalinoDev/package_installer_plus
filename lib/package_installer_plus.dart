
import 'package_installer_plus_platform_interface.dart';

class PackageInstallerPlus {
  Future<bool> installApk({required String filePath}) async{
    return await PackageInstallerPlusPlatform.instance.installApk(filePath: filePath) ?? false;
  }
}
