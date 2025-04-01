import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';

import '../contacts/contacts_view.dart';
import '../conversation/conversation_view.dart';
import '../mine/mine_view.dart';
import '../discover/discover_view.dart';
import 'home_logic.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePage extends StatelessWidget {
  final logic = Get.find<HomeLogic>();
  DateTime? _lastBackTime;
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return
   Scaffold(
      backgroundColor: Styles.c_FFFFFF,
      body: Obx(
            () => IndexedStack(
          index: logic.currentIndex.value,
          children: [
            _keepAliveWrapper(ConversationPage()),
            _keepAliveWrapper(ContactsPage()),
            _keepAliveWrapper(DiscoverPage()),
            _keepAliveWrapper(MinePage()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  //   PopScope(
  //     canPop: false, // 禁用自动弹栈
  //       onPopInvokedWithResult: (didPop,_) async {
  //   if (!didPop) {
  //     _handleGlobalBack(context);
  //   }
  // },
  // child:

  void _handleGlobalBack(BuildContext context) {
    // 处理非首页标签页
    if (logic.currentIndex.value != 0) {
      logic.switchTab(0);
      return;
    }

    // 首页二次返回退出逻辑
    final now = DateTime.now();
    final shouldExit = _lastBackTime != null &&
        now.difference(_lastBackTime!) < Duration(seconds: 2);

    if (shouldExit) {
      SystemNavigator.pop(); // 退出应用
    } else {
      _lastBackTime = now;
      IMViews.showInfoToast("再按一次退出");
      }
  }

  Widget _keepAliveWrapper(Widget child) => KeepAliveWrapper(child: child);

  Widget _buildBottomNavBar() {
    return Obx(
          () => BottomNavigationBar(
        currentIndex: logic.currentIndex.value,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Styles.c_0089FF,
        unselectedItemColor: Styles.c_8E9AB0,
        selectedFontSize: 10.sp,
        unselectedFontSize: 10.sp,
        onTap: logic.switchTab,
        items: [
          _buildNavItem(
            activeIcon: ImageRes.homeTab1Sel.toImage
              ..width= 24.w
              ..height=24.h,
            normalIcon: ImageRes.homeTab1Nor.toImage
              ..width=24.w
              ..height=24.h,
            label: StrRes.home,
            unreadCount: logic.unreadMsgCount.value,
            onDoubleTap: logic.scrollToUnreadMessage,
          ),
          _buildNavItem(
            activeIcon: ImageRes.homeTab2Sel.toImage
              ..width=24.w
              ..height=24.h,
            normalIcon: ImageRes.homeTab2Nor.toImage
              ..width=24.w
              ..height=24.h,
            label: StrRes.contacts,
            unreadCount: logic.unhandledCount.value,
          ),
          _buildNavItem(
            activeIcon: ImageRes.homeTab3Sel.toImage
              ..width=24.w
              ..height=24.h,
            normalIcon: ImageRes.homeTab3Nor.toImage
              ..width=24.w
              ..height=24.h,
            label: StrRes.brand,
          ),
          _buildNavItem(
            activeIcon: ImageRes.homeTab4Sel.toImage
              ..width=24.w
              ..height=24.h,
            normalIcon: ImageRes.homeTab4Nor.toImage
              ..width=24.w
              ..height=24.h,
            label: StrRes.mine,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required Widget activeIcon,
    required Widget normalIcon,
    required String label,
    int unreadCount = 0,
    VoidCallback? onDoubleTap,
  }) {
    return BottomNavigationBarItem(
      icon: GestureDetector(
        onDoubleTap: onDoubleTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            normalIcon,
            if (unreadCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Transform.translate(
                  offset: const Offset(2, -2),
                  child: UnreadCountView(count: unreadCount),
                ),
              ),
          ],
        ),
      ),
      activeIcon: activeIcon,
      label: label,
    );
  }


  Widget _setupIcon(Widget icon, int unReadCount) {
    return Stack(
      alignment: Alignment.center,
      children: [
        icon,
        Positioned(
          top: 0,
          right: 0,
          child: Transform.translate(
            offset: const Offset(2, -2),
            child: UnreadCountView(count: unReadCount),
          ),
        ),
      ],
    );
  }


}


class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}