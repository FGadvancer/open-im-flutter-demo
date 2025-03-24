import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/contacts/group_profile_panel/group_profile_panel_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh_new/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

enum SearchType {
  user,
  group,
}

class AddContactsBySearchLogic extends GetxController {
  final refreshCtrl = RefreshController();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final userInfoList = <UserFullInfo>[].obs;
  final groupInfoList = <GroupInfo>[].obs;
  late SearchType searchType;
  int pageNo = 0;

  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    searchType = Get.arguments['searchType'] ?? SearchType.user;
    searchCtrl.addListener(() {
      if (searchKey.isEmpty) {
        focusNode.requestFocus();
        userInfoList.clear();
        groupInfoList.clear();
      }
    });
    super.onInit();
  }

  bool get isSearchUser => searchType == SearchType.user;

  String get searchKey => searchCtrl.text.trim();

  bool get isNotFoundUser => userInfoList.isEmpty && searchKey.isNotEmpty;

  bool get isNotFoundGroup => groupInfoList.isEmpty && searchKey.isNotEmpty;

  void search() {
    if (searchKey.isEmpty) return;
    if (isSearchUser) {
      searchUser();
    } else {
      searchGroup();
    }
  }

  void searchUser() async {
    var list = await LoadingView.singleton.wrap(
      asyncFunction: () => Apis.searchUserFullInfo(
        content: searchKey,
        pageNumber: pageNo = 1,
        showNumber: 20,
      ),
    );
    userInfoList.assignAll(list ?? []);
    refreshCtrl.refreshCompleted();
    if (null == list || list.isEmpty || list.length < 20) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
  }

  void loadMoreUser() async {
    var list = await LoadingView.singleton.wrap(
      asyncFunction: () => Apis.searchUserFullInfo(
        content: searchKey,
        pageNumber: ++pageNo,
        showNumber: 20,
      ),
    );
    userInfoList.addAll(list ?? []);
    refreshCtrl.refreshCompleted();
    if (null == list || list.isEmpty || list.length < 20) {
      refreshCtrl.loadNoData();
    } else {
      refreshCtrl.loadComplete();
    }
  }

  void searchGroup() async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [searchKey],
    );
    groupInfoList.assignAll(list);
  }

  String getMatchContent(UserFullInfo userInfo) {
    final keyword = searchCtrl.text;

    return sprintf(StrRes.searchNicknameIs, [userInfo.nickname]);
  }

  void viewInfo(dynamic info) {
    if (info is UserFullInfo) {
      AppNavigator.startUserProfilePane(
        userID: info.userID!,
        nickname: info.nickname,
        faceURL: info.faceURL,
      );
    } else if (info is GroupInfo) {
      AppNavigator.startGroupProfilePanel(
        groupID: info.groupID,
        joinGroupMethod: JoinGroupMethod.search,
      );
    }
  }



  InlineSpan getMergedMatchedSpan(dynamic info, String searchKey) {
    final List<InlineSpan> children = [];
    final keywordLower = searchKey.toLowerCase();

    void tryAddText(String? value, String label) {
      if (value != null && value.toLowerCase().contains(keywordLower)) {
        children.add(TextSpan(
          text: "$label: ",
          style: Styles.ts_0C1C33_17sp,
        ));
        children.addAll(_highlightMatch(value, searchKey));
        children.add(TextSpan(text: "  ", style: Styles.ts_0C1C33_17sp));
      }
    }

    void tryAddList(List<String>? values, String label) {
      if (values == null || values.isEmpty) return;

      final matched = values.where((e) => e.toLowerCase().contains(keywordLower)).toList();
      if (matched.isNotEmpty) {
        children.add(TextSpan(
          text: "$label: ",
          style: Styles.ts_0C1C33_17sp,
        ));
        for (var i = 0; i < matched.length; i++) {
          children.addAll(_highlightMatch(matched[i], searchKey));
          if (i < matched.length - 1) {
            children.add(TextSpan(text: ', ', style: Styles.ts_0C1C33_17sp));
          }
        }
        children.add(TextSpan(text: "  ", style: Styles.ts_0C1C33_17sp));
      }
    }

    if (info is GroupInfo) {
      if (info.groupName!.toLowerCase().contains(keywordLower)) {
        children.addAll(_highlightMatch(info.groupName!, searchKey));
      } else {
        children.add(TextSpan(text: info.groupName, style: Styles.ts_0C1C33_17sp));
      }
      return TextSpan(children: children);
    }


    final UserFullInfo user = info;

    tryAddText(user.nickname, StrRes.nickname);
    tryAddText(user.phoneNumber, StrRes.phoneNumber);
    tryAddText(user.enterprise, StrRes.enterpriseName);
    tryAddList(user.tags, StrRes.tags);

    return TextSpan(children: children);
  }




  List<TextSpan> _highlightMatch(String source, String keyword) {
    final List<TextSpan> spans = [];
    final pattern = RegExp(RegExp.escape(keyword), caseSensitive: false);
    final matches = pattern.allMatches(source);

    if (matches.isEmpty) {
      spans.add(TextSpan(text: source, style: Styles.ts_0C1C33_17sp));
      return spans;
    }

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: source.substring(lastIndex, match.start),
          style: Styles.ts_0C1C33_17sp,
        ));
      }
      spans.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: Styles.ts_0089FF_17sp, // ← 高亮样式
      ));
      lastIndex = match.end;
    }

    if (lastIndex < source.length) {
      spans.add(TextSpan(
        text: source.substring(lastIndex),
        style: Styles.ts_0C1C33_17sp,
      ));
    }

    return spans;
  }


}
