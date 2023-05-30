import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_file_downloader/main.dart';
import 'package:flutter_file_downloader/utils/notification_util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ReceivePort _port = ReceivePort();
  final String saveDir = "/storage/emulated/0/Download";

  @override
  void initState() {
    NotificationUtil.initialize(
      flutterLocalNotificationsPlugin,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("------------onDidReceiveNotificationResponse---------------");
        print("actionId ${response.actionId}");
        print("id ${response.id}");
        print("input ${response.input}");
        print("notificationResponseType ${response.notificationResponseType.name}");
        print("payload ${response.payload}");
      },
    );

    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];

      print("progress $progress");
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
/*    Directory? ios = await getDownloadsDirectory();
    print("ios $ios");*/
/*
    Directory? android = await getExternalStorageDirectory();
    print("android :${android?.path}");
    print(status.isGranted);*/

    if (status.isGranted) {
      try {
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: saveDir,
          fileName: "Test.zip",
          showNotification: false,
          openFileFromNotification: false,
        );

        final file = File("/storage/emulated/0/Download/Test.zip");
        bool fileByte = file.existsSync();
        if (fileByte == true) {
          NotificationUtil.showBigTextNotification(
            title: "Your file has downloaded successfully ",
            body: "Done",
            fl: flutterLocalNotificationsPlugin,
          );
        } else {
          NotificationUtil.showBigTextNotification(
            title: "Downloaded file failure",
            body: "Fail",
            fl: flutterLocalNotificationsPlugin,
          );
        }
      } catch (e, st) {
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
