import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:url_launcher/url_launcher.dart';

import 'personal_info_logic.dart';

class PersonalInfoPage extends StatelessWidget {
  final logic = Get.find<PersonalInfoLogic>();

  PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.personalInfo,
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: SingleChildScrollView(
          child: Obx(
        () => Column(
          children: [
            10.verticalSpace,
            _buildCornerBgView(
              children: [
                _buildItemView(
                  label: StrRes.avatar,
                  isAvatar: true,
                  value: logic.nickname,
                  AvatarUrl: logic.faceURL,
                ),
                _buildItemView(
                  label: StrRes.name,
                  value: logic.nickname,
                ),
                _buildItemView(
                  label: StrRes.gender,
                  value: logic.isMale ? StrRes.man : StrRes.woman,
                ),
                _buildItemView(
                  label: StrRes.englishName,
                  value: logic.englishName,
                ),
                _buildItemView(
                  label: StrRes.birthDay,
                  value: logic.birth,
                ),
              ],
            ),
            10.verticalSpace,
            _buildCornerBgView(
              children: [
                _buildItemView(
                  label: StrRes.mobile,
                  value: logic.phoneNumber,
                  onTap: logic.clickPhoneNumber,
                ),
                _buildItemView(
                  label: StrRes.email,
                  value: logic.email,
                  onTap: logic.clickEmail,
                ),
                _buildItemView(
                  label: StrRes.enterpriseName,
                  value: logic.enterprise,
                ),
                _buildItemView(
                  label: StrRes.website,
                  value: logic.enterpriseWebsite,
                  isUrl: true,
                ),
              ],
            ),
            10.verticalSpace,
            _buildCornerBgView(
              children: [
                _buildItemWithTags(
                  label: StrRes.tags,
                  tags: logic.tags,
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildCornerBgView({required List<Widget> children}) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        margin: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: Styles.c_FFFFFF,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(6.r),
            topRight: Radius.circular(6.r),
            bottomLeft: Radius.circular(6.r),
            bottomRight: Radius.circular(6.r),
          ),
        ),
        child: Column(children: children),
      );

  Widget _buildItemView({
    required String label,
    String? value,
    String? AvatarUrl,
    bool isAvatar = false,
    bool isUrl = false,
    Function()? onTap,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: SizedBox(
          height: 46.h,
          child: Row(
            children: [
              label.toText..style = Styles.ts_0C1C33_17sp,
              SizedBox(width: 40.w),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 右侧对齐
                    children: [
              if (value != null && !isAvatar && !isUrl)
                Flexible(
                  child: value.toText
                    ..style = Styles.ts_0C1C33_17sp
                    ..maxLines = 1
                    ..overflow = TextOverflow.ellipsis,
                ),
              if (value != null && isUrl)
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.tryParse(value ?? '');
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
                    }
                  },
                  onLongPress: () {
                    IMUtils.copy(text: value);
                  },
                  child: Text(
                    value,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 17.sp,
                    ),
                  ),
                ),
              if (isAvatar)
                AvatarView(
                  width: 32.w,
                  height: 32.h,
                  url: AvatarUrl,
                  text: value,
                  textStyle: Styles.ts_FFFFFF_10sp,
               )
                    ],
            ),
          ),
            ],
          ),
        ),
      );

  Widget _buildItemWithTags({
    required String label,
    List<String>? tags,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: Styles.ts_0C1C33_17sp,
                ),
              ],
            ),
            if (tags != null && tags.isNotEmpty) ...[
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child:           Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.end,
                  children: tags.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 14, color: Styles.c_0C1C33),
                      ),
                    );
                  }).toList(),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
