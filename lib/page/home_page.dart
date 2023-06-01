import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_file_downloader/main.dart';
import 'package:flutter_file_downloader/utils/file_downloader_util.dart';
import 'package:flutter_file_downloader/utils/notification_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FNP flutterLocalNotificationsPlugin = FNP();
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    NotificationUtil.initialize(flutterLocalNotificationsPlugin);

    FileDownloader.initialize(_port);

    _port.listen(downloadTaskNotifier);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _buildButton(),
        ),
      ),
    );
  }

  void downloadTaskNotifier(dynamic data) {
    DownloadTaskStatus status = DownloadTaskStatus(data[1]);

    if (status == DownloadTaskStatus.complete) {
      showNotification(
        id: 0,
        channelId: "complete",
        title: "flutter_file_downloader",
        bodyMessage: "File downloaded successfully",
        fmp: flutterLocalNotificationsPlugin,
      );
    }

    if (status == DownloadTaskStatus.enqueued) {
      showNotification(
        id: 2,
        channelId: "enqueued",
        title: "flutter_file_downloader",
        bodyMessage: "File enqueued",
        fmp: flutterLocalNotificationsPlugin,
      );
    }

    if (status == DownloadTaskStatus.failed ||
        status == DownloadTaskStatus.canceled ||
        status == DownloadTaskStatus.undefined) {
      showNotification(
        id: 1,
        channelId: "failed",
        title: "flutter_file_downloader",
        bodyMessage: "File downloaded unsuccessfully",
        fmp: flutterLocalNotificationsPlugin,
      );
    }
  }

  Widget _buildButton() {
    return SizedBox(
      height: 100,
      width: 100,
      child: FloatingActionButton(
        onPressed: download,
        elevation: 0,
        child: const Icon(
          Icons.download,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  void download() async {
    try {
      await FileDownloader.download(
        url: FileDownloader.url,
        fileName: "test_image",
      );
    } catch (error, st) {
      print("$error, $st");
    }
  }

  void showNotification({
    String? title,
    String? bodyMessage,
    int? id,
    required FNP fmp,
    required String channelId,
  }) {
    NotificationUtil.showBigTextNotification(
      id: id,
      channelId: channelId,
      title: title ?? "None title",
      body: bodyMessage ?? "None body",
      fl: fmp,
    );
  }

  @override
  void dispose() {
    _port.close();
    FileDownloader.removerPort();
    super.dispose();
  }
}
