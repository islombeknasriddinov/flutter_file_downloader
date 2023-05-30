import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
    super.initState();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Download file'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          download(
              url:
                  'https://app2.verifix.com/b/vhr/href/person/person_document:download_files?document_id=369341&-token=B34AC2BA22E3CD5238947970FA7F73E7444ABBA87A107368CD3401561D297BDDC08297695B1415B180904592F9CB9C935D5C9A5D80F059C5644ABAF86A909A06&-project_code=vhr&-project_hash=01&-filial_id=161&-user_id=143&-lang_code=ru');
        },
        child: const Icon(Icons.download),
      ),
    );
  }

  Future download({required String url}) async {
    var status = await Permission.storage.request();
    Directory ios = await getApplicationDocumentsDirectory();
    print("ios $ios");
    Directory? android = await getExternalStorageDirectory();
    print("android $android");
    if (status.isGranted) {
      await FlutterDownloader.enqueue(
        url: url,
        savedDir: ios.toString(),
        fileName: "Test.zip",
        showNotification: true,
        openFileFromNotification: true,
        requiresStorageNotLow: false,
      );
    }
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }
}
