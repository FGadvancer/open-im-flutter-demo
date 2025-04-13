import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'splash_logic.dart';

class SplashPage extends StatelessWidget {
  final logic = Get.find<SplashLogic>();

  SplashPage({super.key});

  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent, // 不影响原生背景图
      body: SizedBox.expand(),
    );
  }
}
