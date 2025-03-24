import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../widgets/register_page_bg.dart';
import 'set_password_logic.dart';

class SetPasswordPage extends StatelessWidget {
  final logic = Get.find<SetPasswordLogic>();

  SetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) => RegisterBgView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StrRes.setInfo.toText..style = Styles.ts_0089FF_22sp_semibold,
            29.verticalSpace,
            InputBox(
              label: StrRes.nickname,
              hintText: StrRes.plsEnterYourNickname,
              controller: logic.nicknameCtrl,
            ),
            17.verticalSpace,
            // 头像上传组件
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Upload Button
                GestureDetector(
                  onTap: logic.openPhotoSheet,
                  child: Obx(() => logic.selectedAvatarFile.value != null
                      ? Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r), // Slight rounding, adjust if needed
                      image: DecorationImage(
                        image: FileImage(logic.selectedAvatarFile.value!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : logic.faceURL.isNotEmpty
                      ? AvatarView(
                    width: 48.w,
                    height: 48.h,
                    url: logic.faceURL.value,
                  )
                      : SizedBox(
                    width: 48.w,
                    height: 48.h,
                    child: ImageRes.cameraGray.toImage,
                  )),
                ),

                // Space between avatar and text
                12.horizontalSpace,

                // Upload hint text
                Text(
                  StrRes.plsUploadAvatar, // Add your localized string here
                  style: Styles.ts_8E9AB0_12sp,
                ),
              ],
            ),



            // 17.verticalSpace,
            // _buildItemView(
            //   label: StrRes.gender,
            //   value: logic.isMale? StrRes.man : StrRes.woman,
            //   onTap: logic.selectGender,
            // ),
            17.verticalSpace,
            InputBox(
              label: StrRes.enterpriseName,
              hintText: StrRes.plsEnterEnterpriseName,
              controller: logic.enterpriseNameCtrl,
            ),
            17.verticalSpace,
            InputBox(
              label: StrRes.website,
              hintText: StrRes.plsEnterWebsite,
              controller: logic.websiteCtrl,
            ),
            17.verticalSpace,
            InputBox.password(
              label: StrRes.password,
              hintText: StrRes.plsEnterPassword,
              controller: logic.pwdCtrl,
              formatHintText: StrRes.loginPwdFormat,
              inputFormatters: [IMUtils.getPasswordFormatter()],
            ),
            17.verticalSpace,

            InputBox.password(
              label: StrRes.confirmPassword,
              hintText: StrRes.plsConfirmPasswordAgain,
              controller: logic.pwdAgainCtrl,
              inputFormatters: [IMUtils.getPasswordFormatter()],
            ),
            50.verticalSpace,
            Obx(() => Button(
                  text: StrRes.registerNow,
                  enabled: logic.enabled.value,
                  onTap: logic.nextStep,
                )),
          ],
        ),
      );


  Widget _buildItemView({
    required String label,
    String? value,
    String? url,
    bool isAvatar = false,
    bool showRightArrow = true,
    Function()? onTap,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: showRightArrow ? onTap : null,
        child: SizedBox(
          height: 30.h,
          child: Row(
            children: [
              label.toText..style = Styles.ts_8E9AB0_12sp,
              const Spacer(),
              if (isAvatar)
                AvatarView(
                  width: 32.w,
                  height: 32.h,
                  url: url,
                  text: value,
                  textStyle: Styles.ts_FFFFFF_10sp,
                )
              else
                Expanded(
                    flex: 3,
                    child: (IMUtils.emptyStrToNull(value) ?? '').toText
                      ..style = Styles.ts_0C1C33_12sp
                      ..maxLines = 1
                      ..overflow = TextOverflow.ellipsis
                      ..textAlign = TextAlign.right),
              if (showRightArrow)
                ImageRes.rightArrow.toImage
                  ..width = 24.w
                  ..height = 24.h,
            ],
          ),
        ),
      );
}
