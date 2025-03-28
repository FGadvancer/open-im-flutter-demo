import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

import 'add_by_search_logic.dart';

class AddContactsBySearchPage extends StatelessWidget {
  final logic = Get.find<AddContactsBySearchLogic>();

  AddContactsBySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar.back(
        title: logic.isSearchUser ? StrRes.addFriend : (logic.isUserDiscovery? StrRes.userDiscovery:StrRes.addGroup),
      ),
      backgroundColor: Styles.c_FFFFFF,
      body: Column(
        children: [
          SearchBox(
            focusNode: logic.focusNode,
            controller: logic.searchCtrl,
            hintText: logic.isSearchUser || logic.isUserDiscovery ? StrRes.searchUsers : StrRes.searchIDAddGroup,
            enabled: true,
            autofocus: true,
            margin: EdgeInsets.symmetric(horizontal: 17.w, vertical: 10.h),
            onSubmitted: (_) => logic.search(),
          ),
          Divider(color: Styles.c_E8EAEF, height: 1.h),
          if (logic.isSearchUser)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: AppNavigator.startScan,
              child: Container(
                margin: EdgeInsets.only(top: 22.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    ImageRes.scanBlue.toImage
                      ..width = 40.w
                      ..height = 40.h,
                    8.horizontalSpace,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StrRes.scan.toText..style = Styles.ts_0C1C33_17sp_medium,
                        8.verticalSpace,
                        StrRes.scanHint.toText..style = Styles.ts_8E9AB0_12sp,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          Obx(() => Expanded(
                child: logic.isSearchUser||logic.isUserDiscovery
                    ? (logic.isNotFoundUser ? _buildNotFoundView() : _buildUserListView())
                    : (logic.isNotFoundGroup
                        ? _buildNotFoundView()
                        : (Column(
                            children: logic.groupInfoList.map((e) => _buildItemView(e)).toList(),
                          ))),
              ))
        ],
      ),
    );
  }

  Widget _buildUserListView() => SmartRefresher(
        controller: logic.refreshCtrl,
        enablePullDown: false,
        enablePullUp: true,
        footer: IMViews.buildFooter(),
        onLoading: logic.loadMoreUser,
        child: ListView.builder(
          itemCount: logic.userInfoList.length,
          itemBuilder: (_, index) {
            final userInfo = logic.userInfoList.elementAt(index);
            return _buildItemView(userInfo);
          },
        ),
      );

  Widget _buildItemView(dynamic info) => InkWell(
        onTap: () => logic.viewInfo(info),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: BorderDirectional(
              bottom: BorderSide(color: Styles.c_E8EAEF, width: 1.h),
            ),
          ),
          height: 68.h,
          child: Row(
            children: [
                AvatarView(
                url: logic.getAvatar(info),
                text: logic.getNickname(info),
                width: 48.w,
                height: 48.h,
                textStyle: Styles.ts_FFFFFF_14sp,
              ),

              12.horizontalSpace,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：昵称
                    Text(
                      logic.getNickname(info),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // 第二行：匹配字段
                    logic.searchKey.isNotEmpty ?
                    Text.rich(
                      logic.getMergedMatchedSpan(info, logic.searchKey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ): Text(
                      logic.getEnterpriseName(info),
                      style: Styles.ts_8E9AB0_14sp,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),


                  ],
                ),
              ),
            ],


          ),
        ),
      );

  Widget _buildNotFoundView() => Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: (logic.isSearchUser || logic.isUserDiscovery? StrRes.noFoundUser : StrRes.noFoundGroup).toText..style = Styles.ts_8E9AB0_17sp,
      );
}


