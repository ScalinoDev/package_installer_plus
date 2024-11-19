
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:package_installer_plus/package_installer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _urlController = TextEditingController();
  final _packageInstallerPlusPlugin = PackageInstallerPlus();
  bool _isDownloading = false;
  Timer? _logTimer;
  double _percentage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Install apk'),
        ),
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(10),
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16,),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16,),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24,),
                  TextFormField(
                    controller: _urlController,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Please fill url';
                      }
                      return null;
                    },
                    minLines: 4,
                    maxLines: 15,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    readOnly: _isDownloading,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      hintText: 'Apk download url',
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(Icons.link_rounded, color: Colors.green.shade800, size: 18,),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black38,),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black38,),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5,),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red.shade800,),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.red.shade800, width: 1.5,),
                      ),
                    ),
                    onFieldSubmitted: (val) => _downloadApk(),
                  ),
                  const SizedBox(height: 12,),
                  Opacity(
                    opacity: _isDownloading ? 0.6 : 1,
                    child: ElevatedButton(
                      onPressed: _isDownloading ? null : () => _downloadApk(),
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.green.shade900,),
                        minimumSize: const WidgetStatePropertyAll(Size(100, 35),),
                      ),
                      child: const Text('Install',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12,),
                  Visibility(
                    visible: _isDownloading,
                    maintainAnimation: true,
                    maintainSize: false,
                    maintainState: true,
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            color: Colors.green.shade800,
                            value: _percentage,
                          ),
                        ),
                        const SizedBox(width: 8,),
                        Text('${(_percentage * 100).round()} %',
                          style: const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _downloadApk() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        if(_logTimer != null && _logTimer!.isActive){
          _logTimer!.cancel();
        }
        _percentage = 0;
        _logTimer = Timer.periodic(const Duration(seconds: 1), (timer) async{
          if(_percentage < 0.9) {
            setState(() => _percentage = double.parse((_percentage + 0.1).toStringAsFixed(1)));
          }
        });

        setState(() => _isDownloading = true);
        String? filePath = await _downloadAndCreateFile(_urlController.text);
        log('file path : $filePath');
        _logTimer?.cancel();
        setState(() => _percentage = 1);
        await Future.delayed(const Duration(seconds: 1));
        if(filePath != null) {
          bool res = await _packageInstallerPlusPlugin.installApk(filePath: filePath);
          log('install apk res : $res');
        }
      }
      catch (e) {
        log('Exception : $e');
      }
      setState(() => _isDownloading = false);
    }
  }

  Future<String?> _downloadAndCreateFile(String fileUrl) async{
    Uint8List? res = await _downloadFile(fileUrl);

    if(res != null){
      Directory folder = await getTemporaryDirectory();
      if(!await folder.exists()){
        await folder.create();
      }

      File file = File('${folder.path}${Platform.pathSeparator}update.apk' )
        ..createSync(recursive: true);
      await file.writeAsBytes(res, flush: true);

      return file.path;
    }
    return null;
  }

  // download file
  Future<Uint8List?> _downloadFile(String fileUrl) async {
    log(' downloadFile start');
    Uint8List? returnVal;
    await http.get(
      Uri.parse(fileUrl),
    ).then((response) async {
      log('downloadFile res code : ${response.statusCode}, body : ${response.body.length}');
      if (response.statusCode == 200) {
        returnVal = response.bodyBytes;

      } else {
        returnVal = null;
      }
    }).catchError((error) {
      log(' downloadFile error ${error.toString()}');
      returnVal = null;
    });
    log(' downloadFile end');
    return returnVal;
  }
}
