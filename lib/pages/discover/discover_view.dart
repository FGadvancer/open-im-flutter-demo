import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';


import '../../routes/app_pages.dart';
import 'discover_logic.dart';

class DiscoverPage extends StatelessWidget {
  final logic = Get.find<DiscoverLogic>();
  DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    print('DiscoverPage home build');

    return Scaffold(
      appBar: TitleBar.workbench(onTap: logic.returnToInitialUrl,),
      backgroundColor: Styles.c_F8F9FA,
      body: DiscoverWebView(),
    );
  }
}
