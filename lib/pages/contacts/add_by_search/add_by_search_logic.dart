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
  userDiscovery
}

class AddContactsBySearchLogic extends GetxController {
  final refreshCtrl = RefreshController();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final userInfoList = <UserFullInfo>[].obs;
  final groupInfoList = <GroupInfo>[].obs;
  late SearchType searchType;
  int pageNo = 0;
  bool isSearched = false;


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
        if (isSearchUser) {
          userInfoList.clear();
        }
        groupInfoList.clear();
        if (isUserDiscovery) {
          if (isSearched) {
            userInfoList.clear();
            getFirstPageUsers();
            isSearched = false;
          }
        }
      }
    });
    if (isUserDiscovery) {
      getFirstPageUsers();
    }
    super.onInit();
  }

  bool get isSearchUser => searchType == SearchType.user;

  bool get isUserDiscovery => searchType == SearchType.userDiscovery;

  String get searchKey => searchCtrl.text.trim();

  bool get isNotFoundUser => userInfoList.isEmpty && searchKey.isNotEmpty;

  bool get isNotFoundGroup => groupInfoList.isEmpty && searchKey.isNotEmpty;





  void search() {
    if (searchKey.isEmpty) return;
    if (isSearchUser||isUserDiscovery) {
      searchUser();
      isSearched = true;
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

  void getFirstPageUsers() async {
    var list = await LoadingView.singleton.wrap(
      asyncFunction: () => Apis.searchUserFullInfo(
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
    if (userInfoList.isEmpty) {
      return;
    }
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

  String getAvatar(dynamic info) {
    if (info is UserFullInfo) {
      return info.faceURL ?? '';
    } else if (info is GroupInfo) {
      return info.faceURL ?? '';
    }
    return '';
  }

  String getNickname(dynamic info) {
    if (info is UserFullInfo) {
      return info.nickname ?? '';
    } else if (info is GroupInfo) {
      return info.groupName ?? '';
    }
    return '';
  }

  String getEnterpriseName(dynamic info) {
    String enterpriseName = '';

    if (info is UserFullInfo) {
      enterpriseName = info.enterprise ?? '';
    }

    if (enterpriseName.length > 15) {
      return '${enterpriseName.substring(0, 15)}...';
    }

    return enterpriseName;
  }





  InlineSpan getMergedMatchedSpan(dynamic info, String searchKey) {
    final List<InlineSpan> children = [];
    final keywordLower = searchKey.toLowerCase();

    void tryAddText(String? value, String label) {
      if (value != null && value.toLowerCase().contains(keywordLower)) {
        children.add(TextSpan(
          text: "$label: ",
          style: Styles.ts_0C1C33_14sp,
        ));
        children.addAll(_highlightMatch(value, searchKey));
        children.add(TextSpan(text: "  ", style: Styles.ts_0C1C33_14sp));
      }
    }

    void tryAddList(List<String>? values, String label) {
      if (values == null || values.isEmpty) return;

      final matched = values.where((e) => e.toLowerCase().contains(keywordLower)).toList();
      if (matched.isNotEmpty) {
        children.add(TextSpan(
          text: "$label: ",
          style: Styles.ts_0C1C33_14sp,
        ));
        for (var i = 0; i < matched.length; i++) {
          children.addAll(_highlightMatch(matched[i], searchKey));
          if (i < matched.length - 1) {
            children.add(TextSpan(text: ', ', style: Styles.ts_0C1C33_14sp));
          }
        }
        children.add(TextSpan(text: "  ", style: Styles.ts_0C1C33_14sp));
      }
    }

    if (info is GroupInfo) {
      if (info.groupName!.toLowerCase().contains(keywordLower)) {
        children.addAll(_highlightMatch(info.groupName!, searchKey));
      } else {
        children.add(TextSpan(text: info.groupName, style: Styles.ts_0C1C33_14sp));
      }
      return TextSpan(children: children);
    }


    final UserFullInfo user = info;
    tryAddText(user.enterprise, StrRes.enterpriseName);
    tryAddList(user.tags, StrRes.tags);
    tryAddText(user.nickname, StrRes.nickname);


    return TextSpan(children: children);
  }




  List<TextSpan> _highlightMatch(String source, String keyword) {
    final List<TextSpan> spans = [];
    final pattern = RegExp(RegExp.escape(keyword), caseSensitive: false);
    final matches = pattern.allMatches(source);

    if (matches.isEmpty) {
      spans.add(TextSpan(text: source, style: Styles.ts_0C1C33_14sp));
      return spans;
    }

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: source.substring(lastIndex, match.start),
          style: Styles.ts_0C1C33_14sp,
        ));
      }
      spans.add(TextSpan(
        text: source.substring(match.start, match.end),
        style: Styles.ts_0089FF_14sp,
      ));
      lastIndex = match.end;
    }

    if (lastIndex < source.length) {
      spans.add(TextSpan(
        text: source.substring(lastIndex),
        style: Styles.ts_0C1C33_14sp,
      ));
    }

    return spans;
  }

  bool isTextSpanEmpty(TextSpan span) {
    // 基础判断：当前节点的 text 是否非空
    if (span.text?.isNotEmpty == true) return false;

    // 递归检查子节点
    if (span.children != null) {
      for (final child in span.children!) {
        if (child is TextSpan && !isTextSpanEmpty(child)) {
          return false;
        }
      }
    }

    return true;
  }
}



