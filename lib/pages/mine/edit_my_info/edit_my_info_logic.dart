import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../../../core/controller/im_controller.dart';

enum EditAttr {
  nickname,
  englishName,
  telephone,
  mobile,
  email,
  enterprise,
  enterpriseWebsite,
}

class EditMyInfoLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  late TextEditingController inputCtrl;
  late EditAttr editAttr;
  late int maxLength;
  String? title;
  String? defaultValue;
  TextInputType? keyboardType;

  @override
  void onInit() {
    editAttr = Get.arguments['editAttr'];
    maxLength = Get.arguments['maxLength'] ?? 16;
    _initAttr();
    inputCtrl = TextEditingController(text: defaultValue);
    super.onInit();
  }

  _initAttr() {
    switch (editAttr) {
      case EditAttr.nickname:
        title = StrRes.name;
        defaultValue = imLogic.userInfo.value.nickname;
        keyboardType = TextInputType.text;
        break;
      case EditAttr.englishName:
        break;
      case EditAttr.telephone:
        break;
      case EditAttr.mobile:
        title = StrRes.mobile;
        defaultValue = imLogic.userInfo.value.phoneNumber;
        keyboardType = TextInputType.phone;
        break;
      case EditAttr.email:
        title = StrRes.email;
        defaultValue = imLogic.userInfo.value.email;
        keyboardType = TextInputType.emailAddress;
        break;
      case EditAttr.enterprise:
         title = StrRes.enterpriseName;
         defaultValue = imLogic.userInfo.value.enterprise;
         keyboardType = TextInputType.text;
      case EditAttr.enterpriseWebsite:
        title = StrRes.website;
        defaultValue = imLogic.userInfo.value.enterpriseWebsite;
        keyboardType = TextInputType.text;
        break;
    }
  }

  void save() async {
    final value = inputCtrl.text.trim();
    if (editAttr == EditAttr.nickname) {
      if (!IMUtils.isValidNickname(value)) {
        IMViews.showToast(StrRes.nicknameLengthInvalid);
         return;
      }
      await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.updateUserInfo(
          userID: OpenIM.iMManager.userID,
          nickname: value,
        ),
      );
      imLogic.userInfo.update((val) {
        val?.nickname = value;
      });
    } else if (editAttr == EditAttr.mobile) {
      await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.updateUserInfo(
          userID: OpenIM.iMManager.userID,
          phoneNumber: value,
        ),
      );
      imLogic.userInfo.update((val) {
        val?.phoneNumber = value;
      });
    } else if (editAttr == EditAttr.email) {
      if (defaultValue?.isNotEmpty == true && value.isEmpty) {
        IMViews.showToast(StrRes.plsEnterEmail);
        return;
      }
      await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.updateUserInfo(
          userID: OpenIM.iMManager.userID,
          email: value,
        ),
      );
      imLogic.userInfo.update((val) {
        val?.email = value;
      });
    }else if (editAttr == EditAttr.enterprise) {
      if (!IMUtils.isValidEnterpriseName(value)) {
        IMViews.showToast(StrRes.enterpriseNameLengthInvalid);
        return;
      }
      await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.updateUserInfo(
          userID: OpenIM.iMManager.userID,
          enterpriseName: value,
        ),
      );
      imLogic.userInfo.update((val) {
        val?.enterprise = value;
      });
    } else if (editAttr == EditAttr.enterpriseWebsite) {
      if (!IMUtils.isValidWebsite(value)) {
        IMViews.showToast(StrRes.plsEnterValidWebsite);
        return;
      }
      await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.updateUserInfo(
          userID: OpenIM.iMManager.userID,
          website: value,
        ),
      );
      imLogic.userInfo.update((val) {
        val?.enterpriseWebsite = value;
      });
    }
    Get.back();
  }
}
