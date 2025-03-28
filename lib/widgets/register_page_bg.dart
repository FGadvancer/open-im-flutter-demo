import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

class RegisterBgView extends StatelessWidget {
  const RegisterBgView({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        child: TouchCloseSoftKeyboard(
          isGradientBg: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                54.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22.w), // 左右统一间距
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 左右分散对齐
                    children: [
                      // 返回按钮（左）
                      ImageRes.backBlack.toImage
                        ..width = 24.w
                        ..height = 24.h
                        ..onTap = () => Get.back(),

                      // // 新增图片（右）
                      // ImageRes.loginLogo.toImage // 替换为你的图片资源
                      //   ..width = 24.w
                      //   ..height = 24.h
                    ],
                  ),
                ),
                25.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.w),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      );
}
