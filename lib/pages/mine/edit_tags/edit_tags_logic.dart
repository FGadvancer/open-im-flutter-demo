import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import '../../../core/controller/im_controller.dart';

const maxTagsNum = 5;

class EditTagsLogic extends GetxController {
  final imLogic = Get.find<IMController>();
  var tags = <String>[].obs;
  final TextEditingController controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  FocusNode get focusNode => _focusNode;

  @override
  void onInit() {
    tags.assignAll(imLogic.userInfo.value.tags ?? []);
    super.onInit();
  }


  /// 添加标签
  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      if (tags.length >= maxTagsNum) {
        IMViews.showToast(StrRes.maxTagsLimit);
      }else{
        tags.insert(0, tag); // 新增标签放在顶部
        controller.clear(); // 清空输入框
      }
      _focusNode.requestFocus();
    }
  }

  /// 删除标签
  void removeTag(String tag) {
    tags.remove(tag);
  }


  void save() async {
    var clearTags = tags.isEmpty;
      await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.updateUserInfo(
          userID: OpenIM.iMManager.userID,
          clearTags: clearTags,
          tags: tags,
        ),
      );
      imLogic.userInfo.update((val) {
        val?.tags = tags;
      });
    Get.back();
  }
}
