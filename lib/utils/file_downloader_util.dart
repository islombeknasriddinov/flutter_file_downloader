import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloader {
  static const String url = "https://images.unsplash.com/photo-1685491107139-7d7f4f17b3eb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=388&q=80";
  static const String androidPath = "/storage/emulated/0/Download";
  static const iosPath = "";

  static void initialize(ReceivePort port) {
    IsolateNameServer.registerPortWithName(port.sendPort, 'downloader_send_port');
    registerCallback();
  }

  static void registerCallback() {
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  static Future download({required String url, required String fileName}) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        await FlutterDownloader.enqueue(
          url: url,
          savedDir: Platform.isAndroid ? androidPath : iosPath,
          fileName: "$fileName.jpg",
          showNotification: false,
          openFileFromNotification: false,
          saveInPublicStorage: true,
        );
      } catch (e, st) {
        print("${e.toString()}\n $st");
      }
    }
  }

  static void removerPort() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
}
