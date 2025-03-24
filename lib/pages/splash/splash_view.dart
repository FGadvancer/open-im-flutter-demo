import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import 'splash_logic.dart';

class SplashPage extends StatelessWidget {
  final logic = Get.find<SplashLogic>();

  SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.blue.shade300,
      body: Center(
        child: ImageRes.splashBackground.toImage
          ..width = double.infinity
          ..height = double.infinity
          ..fit = BoxFit.cover, // 让图片铺满屏幕
      ),
    );
  }
}
