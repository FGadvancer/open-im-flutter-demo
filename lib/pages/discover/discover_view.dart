import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../routes/app_pages.dart';
import 'discover_logic.dart';

class DiscoverPage extends StatelessWidget {
  final logic = Get.find<DiscoverLogic>();
  DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.workbench(),
      backgroundColor: Styles.c_F8F9FA,
      body: DiscoverWebView(),
    );
  }
}
