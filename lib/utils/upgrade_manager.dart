import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../widgets/upgrade_view.dart';

mixin UpgradeManger {
  PackageInfo? packageInfo;
  UpgradeInfoV2? upgradeInfoV2;
  var isShowUpgradeDialog = false;
  var isNowIgnoreUpdate = false;
  final subject = PublishSubject<double>();
  final notificationService = NotificationService();

  void closeSubject() {
    subject.close();
  }

  void ignoreUpdate() {
    DataSp.putIgnoreVersion(upgradeInfoV2!.buildVersion! + upgradeInfoV2!.buildVersionNo!);
    Get.back();
  }

  void laterUpdate() {
    isNowIgnoreUpdate = true;
    Get.back();
  }

  getAppInfo() async {
    packageInfo ??= await PackageInfo.fromPlatform();
  }

  void nowUpdate() async {
    final appUrl = upgradeInfoV2?.appURl;

    if (appUrl != null && await canLaunchUrlString(appUrl)) {
      launchUrlString(appUrl);
      return;
    }
  }

  void checkUpdate() async {
    LoadingView.singleton.wrap(asyncFunction: () async {
      await getAppInfo();
      return Apis.checkUpgradeFromApp();
    }).then((value) {
      upgradeInfoV2 = value;
      if (!canUpdate) {
        IMViews.showToast('已是最新版本');
        return;
      }
      Get.dialog(
        UpgradeViewV2(
          upgradeInfo: upgradeInfoV2!,
          packageInfo: packageInfo!,
          onNow: nowUpdate,
          subject: subject,
        ),
        routeSettings: const RouteSettings(name: 'upgrade_dialog'),
      );
    });
  }


  Future<bool> isNewVersion() async {
    try {
      // 使用 await 确保等待整个流程完成
      final result = await LoadingView.singleton.wrap(
        asyncFunction: () async {
          await getAppInfo(); // 明确等待前置操作
          return Apis.checkUpgradeFromApp(); // 直接返回 API 结果
        },
      );

      // 根据 API 返回结果判断是否需要更新
      upgradeInfoV2 = result;
      return canUpdate; // 假设 API 返回对象包含 shouldUpdate 属性
    } catch (e) {
      // 统一错误处理
      print('版本检查失败: $e');
      return false;
    }
  }

  autoCheckVersionUpgrade() async {
    if (isShowUpgradeDialog || isNowIgnoreUpdate) return;
    await getAppInfo();
    upgradeInfoV2 = await Apis.checkUpgradeFromPgyer();

    if (!canUpdate) return;
    isShowUpgradeDialog = true;
    Get.dialog(
      UpgradeViewV2(
        upgradeInfo: upgradeInfoV2!,
        packageInfo: packageInfo!,
        onLater: laterUpdate,
        onIgnore: ignoreUpdate,
        onNow: nowUpdate,
        subject: subject,
      ),
      routeSettings: const RouteSettings(name: 'upgrade_dialog'),
    ).whenComplete(() => isShowUpgradeDialog = false);
  }

  bool get canUpdate =>
      packageInfo!.version + packageInfo!.buildNumber != upgradeInfoV2!.buildVersion! + upgradeInfoV2!.buildVersionNo!;
}

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AndroidInitializationSettings _androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal() {
    if (Platform.isAndroid) {
      init();
    }
  }

  void init() async {
    final InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future createNotification(int count, int i, int id, String status) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails('progress channel', 'progress channel',
        channelDescription: 'progress channel description',
        channelShowBadge: false,
        importance: Importance.max,
        priority: Priority.high,
        onlyAlertOnce: true,
        showProgress: true,
        maxProgress: count,
        progress: i);
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(id, status, '$i%', platformChannelSpecifics, payload: 'item x');

    return;
  }
}
