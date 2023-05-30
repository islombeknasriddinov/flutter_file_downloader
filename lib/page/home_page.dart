import 'dart:io';
import 'dart:isolate';
import 'dart:math';
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
    print(status.isGranted);

    if (status.isGranted) {
     try{
       await FlutterDownloader.enqueue(
         url: url,
         savedDir: ios.path,
         fileName: "Test.zip",
         showNotification: true,
         openFileFromNotification: true,
       );

       final file=File("${ios.path}/Test.zip");
      final fileByte=await file.readAsBytes();
       print(getFileSizeString(bytes:fileByte.length));

     }catch(e,st){
       print("${e.toString()}\n ${st}");
     }
    }
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return "${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }
}
