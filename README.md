# package_installer_plus

A flutter plugin to install android apk

## Usage

Add dependency to pubspec.yaml file
```
package_installer_plus: ^1.0.0
```

### Android
No need any additional configuration.

## Example

```dart
import 'package:flutter/material.dart';
import 'package:package_installer_plus/package_installer_plus.dart';

void main() {
  runApp(Scaffold(
    body: Center(
      child: RaisedButton(
        onPressed: _installApk,
        child: Text('Install Apk'),
      ),
    ),
  ));
}

_installApk() async{
  String filePath = 'update.apk';
  await PackageInstallerPlus().installApk(filePath: filePath);
}
```