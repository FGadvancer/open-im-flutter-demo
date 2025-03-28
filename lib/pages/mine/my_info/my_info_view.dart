import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';
import 'my_info_logic.dart';

class MyInfoPage extends StatelessWidget {
  final logic = Get.find<MyInfoLogic>();
  final imLogic = Get.find<IMController>();

  MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: StrRes.myInfo,
      ),
      backgroundColor: Styles.c_F8F9FA,
      body: Obx(() => SingleChildScrollView(
            child: Column(
              children: [
                10.verticalSpace,
                _buildCornerBgView(
                  children: [
                    _buildItemView(
                      label: StrRes.avatar,
                      isAvatar: true,
                      value: imLogic.userInfo.value.nickname,
                      url: imLogic.userInfo.value.faceURL,
                      onTap: logic.openPhotoSheet,
                    ),
                    _buildItemView(
                      label: StrRes.nickname,
                      value: imLogic.userInfo.value.nickname,
                      onTap: logic.editMyName,
                    ),
                    _buildItemView(
                      label: StrRes.gender,
                      value: imLogic.userInfo.value.isMale ? StrRes.man : StrRes.woman,
                      onTap: logic.selectGender,
                    ),
                    _buildItemView(
                      label: StrRes.birthDay,
                      value: DateUtil.formatDateMs(
                        imLogic.userInfo.value.birth ?? 0,
                        format: IMUtils.getTimeFormat1(),
                      ),
                      onTap: logic.openDatePicker,
                    ),
                  ],
                ),
                10.verticalSpace,
                _buildCornerBgView(
                  children: [
                    _buildItemView(
                      label: StrRes.mobile,
                      value: imLogic.userInfo.value.phoneNumber,
                      showRightArrow: false,
                    ),
                    _buildItemView(
                      label: StrRes.email,
                      value: imLogic.userInfo.value.email,
                      onTap: logic.editEmail,
                    ),
                    _buildItemView(
                      label: StrRes.enterpriseName,
                      value: imLogic.userInfo.value.enterprise,
                      onTap: logic.editEnterpriseName,
                    ),
                    _buildItemView(
                      label: StrRes.website,
                      value: imLogic.userInfo.value.enterpriseWebsite,
                      onTap: logic.editEnterpriseWebsite,
                    ),
                  ],
                ),
                10.verticalSpace,
                _buildCornerBgView(
                  children: [
                    _buildItemWithTags(
                      label: StrRes.tags,
                      tags: imLogic.userInfo.value.tags,
                      onTap: logic.editTags,
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
    String? url,
    bool isAvatar = false,
    bool showRightArrow = true,
    Function()? onTap,
  }) =>
      GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: showRightArrow ? onTap : null,
        child: SizedBox(
          height: 46.h,
          child: Row(
            children: [
              label.toText..style = Styles.ts_0C1C33_17sp,
              const Spacer(),
              if (isAvatar)
                AvatarView(
                  width: 48.w,
                  height: 48.h,
                  url: url,
                  text: value,
                  textStyle: Styles.ts_FFFFFF_10sp,
                )
              else
                Expanded(
                    flex: 3,
                    child: (IMUtils.emptyStrToNull(value) ?? '').toText
                      ..style = Styles.ts_0C1C33_17sp
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
                        color: Styles.c_F8F9FA, // 统一背景色
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueGrey[300]!, // 边框颜色更清晰
                          width: 1, // 边框宽度
                        ),
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
