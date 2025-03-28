import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/login/login_logic.dart';
import 'package:openim_common/openim_common.dart';
import 'package:uuid/uuid.dart';

import '../../../core/controller/im_controller.dart';
import '../../../routes/app_navigator.dart';

class SetPasswordLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  final nicknameCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final pwdAgainCtrl = TextEditingController();
  final enterpriseNameCtrl = TextEditingController();
  final enabled = false.obs;
  final selectedGender = 1.obs;
  final faceURL = ''.obs; // 服务器上的头像 URL
  final selectedAvatarFile = Rx<File?>(null); // 本地选中的头像（但未上传）
  String? phoneNumber;
  String? email;
  late String areaCode;
  late int usedFor;
  late String verificationCode;
  String? invitationCode;




  bool get isMale => selectedGender == 1;
  @override
  void onClose() {
    nicknameCtrl.dispose();
    pwdCtrl.dispose();
    pwdAgainCtrl.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    phoneNumber = Get.arguments['phoneNumber'];
    email = Get.arguments['email'];
    areaCode = Get.arguments['areaCode'];
    usedFor = Get.arguments['usedFor'];
    verificationCode = Get.arguments['verificationCode'];
    invitationCode = Get.arguments['invitationCode'];
    nicknameCtrl.addListener(_onChanged);
    pwdCtrl.addListener(_onChanged);
    pwdAgainCtrl.addListener(_onChanged);
    enterpriseNameCtrl.addListener(_onChanged);
    super.onInit();
  }

  _onChanged() {
    enabled.value =
        nicknameCtrl.text.trim().isNotEmpty && pwdCtrl.text.trim().isNotEmpty && pwdAgainCtrl.text.trim().isNotEmpty;
  }

  bool _checkingInput() {
    if (nicknameCtrl.text.trim().isEmpty) {
      IMViews.showToast(StrRes.plsEnterYourNickname);
      return false;
    }
    if (!IMUtils.isValidNickname(nicknameCtrl.text.trim())) {
      IMViews.showToast(StrRes.nicknameLengthInvalid); // 提示昵称长度无效
      return false;
    }
    if (!IMUtils.isValidPassword(pwdCtrl.text)) {
      IMViews.showToast(StrRes.wrongPasswordFormat);
      return false;
    } else if (pwdCtrl.text != pwdAgainCtrl.text) {
      IMViews.showToast(StrRes.twicePwdNoSame);
      return false;
    }
    if (enterpriseNameCtrl.text.trim().isEmpty) {
      IMViews.showToast(StrRes.plsEnterEnterpriseName);
      return false;
    }
    if (!IMUtils.isValidEnterpriseName(enterpriseNameCtrl.text.trim())) {
      IMViews.showToast(StrRes.enterpriseNameLengthInvalid); // 提示企业名称长度无效
      return false;
    }
    if (selectedAvatarFile.value == null) {
      IMViews.showToast(StrRes.plsSelectAvatar);
      return false;
    }
    return true;
  }


  void openPhotoSheet() {
    IMViews.openPhotoSheet(onData: (path, url) {
      if (path != null) {
        selectedAvatarFile.value = File(path);
      }
    },toUrl: false);
  }

  void selectGender() {
    Get.bottomSheet(
      BottomSheetView(
        items: [
          SheetItem(
            label: StrRes.man,
            onTap: () => _updateGender(1),
          ),
          SheetItem(
            label: StrRes.woman,
            onTap: () => _updateGender(2),
          ),
        ],
      ),
    );
  }

  void _updateGender(int gender) {
    selectedGender.value= gender;
  }

  void nextStep() {
    if (_checkingInput()) {
      register();
    }
  }

  void register() async {
    final operateType = Get.find<LoginLogic>().operateType;
    await LoadingView.singleton.wrap(asyncFunction: () async {
      final data = await Apis.register(
        nickname: nicknameCtrl.text.trim(),
        areaCode: areaCode,
        phoneNumber: operateType == LoginType.phone ? phoneNumber : null,
        email: email,
        account: operateType == LoginType.account ? phoneNumber : null,
        password: pwdCtrl.text,
        verificationCode: verificationCode,
        invitationCode: invitationCode,
        gender: selectedGender.value, enterpriseName: enterpriseNameCtrl.text,
      );
      if (null == IMUtils.emptyStrToNull(data.imToken) || null == IMUtils.emptyStrToNull(data.chatToken)) {
        AppNavigator.startLogin();
        return;
      }
      final account = {"areaCode": areaCode, "phoneNumber": phoneNumber, 'email': email};
      await DataSp.putLoginCertificate(data);
      await DataSp.putLoginAccount(account);
      DataSp.putLoginType(email != null ? 1 : 0);
      await imLogic.login(data.userID, data.imToken);
      Logger.print('---------im login success-------');
      PushController.login(data.userID);
      Logger.print('---------jpush login success----');

      String putID = const Uuid().v4();
      final image = await IMUtils.compressImageAndGetFile(selectedAvatarFile.value!);
      final uploadResult = await OpenIM.iMManager.uploadFile(
        id: putID,
        filePath: image!.path,
        fileName: image.path,
      );

      if (uploadResult is String) {
        final url = jsonDecode(uploadResult)['url'];
        Logger.print('url:$url');
        await Apis.updateUserInfo(
          faceURL: url,
          userID: data.userID,
        );
      }
    });
    AppNavigator.startMain();
  }
}
