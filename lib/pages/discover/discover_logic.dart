import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/app_controller.dart';
import 'package:openim_common/openim_common.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class DiscoverLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final url = ''.obs;

  final controller = Rx<WebViewController?>(null);
  final isError = false.obs;
  final hasPageFinished = false.obs;
  final progress = 0.0.obs;
  final errorConfig = Rxn<ErrorConfig>();

  @override
  void onReady() {
    super.onReady();
    final temp = appLogic.clientConfigMap['discoverPageURL'];
    if (temp == null) {
      appLogic.queryClientConfig().then((value) {
        url.value = value['discoverPageURL'] ?? 'https://www.yunquetai.com';
        initWebView();
      });
    } else {
      url.value = temp;
      initWebView();
    }
  }

  void initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final webCtrl = WebViewController.fromPlatformCreationParams(params);

    webCtrl
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => progress.value = p / 100,
        onPageStarted: (url) {
          hasPageFinished.value = false;
          isError.value = false;
          if (Platform.isAndroid) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
          }
        },
        onPageFinished: (url) {
          if (!isError.value) hasPageFinished.value = true;
          if (Platform.isAndroid) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
          }
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? false) {
            errorConfig.value = ErrorConfig.network;
            isError.value = true;
            hasPageFinished.value = false;
          }
        },
        onHttpError: (error) {
          final status = error.response?.statusCode;
          isError.value = true;
          hasPageFinished.value = false;
          errorConfig.value = switch (status) {
            404 => ErrorConfig.notFound404,
            500 => ErrorConfig.serverError500,
            _ when status != null => ErrorConfig.otherHttp(status),
            _ => ErrorConfig.network,
          };
        },
        onNavigationRequest: (req) {
          return req.url.startsWith('https://www.youtube.com/')
              ? NavigationDecision.prevent
              : NavigationDecision.navigate;
        },
      ))
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (message) {
          Get.rawSnackbar(message: message.message);
        },
      )
      ..loadRequest(Uri.parse(url.value));

    if (!Platform.isMacOS) {
      webCtrl.setBackgroundColor(Styles.c_F8F9FA);
    }

    if (webCtrl.platform is AndroidWebViewController) {
      (webCtrl.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
      AndroidWebViewController.enableDebugging(true);
    }

    controller.value = webCtrl;
  }

  void reload() {
    errorConfig.value = null;
    isError.value = false;
    controller.value?.reload();
  }

  Future<bool> goBack() async {
    if (await controller.value?.canGoBack() ?? false) {
      controller.value?.goBack();
      return true;
    }
    return false;
  }
}
class DiscoverWebView extends GetView<DiscoverLogic> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
        final ctrl = controller.controller.value;
        if (ctrl == null) return const Center(child: CircularProgressIndicator());

        return Stack(
          children: [
            Opacity(
              opacity: controller.hasPageFinished.value ? 1 : 0,
              child: WebViewWidget(controller: ctrl),
            ),
            if (controller.isError.value) _buildErrorView(),
            if (controller.progress.value < 1.0)
              LinearProgressIndicator(
                value: controller.progress.value,
                color: Colors.green,
                backgroundColor: Styles.c_F8F9FA,
                minHeight: 2,
              ),
          ],
        );
      });
  }

  Widget _buildErrorView() {
    final config = controller.errorConfig.value ?? ErrorConfig.network;
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(config.icon, size: 60, color: _getIconColor(config.type)),
            const SizedBox(height: 20),
            Text(config.title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(config.subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
              onPressed: controller.reload,
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(ErrorType type) {
    return switch (type) {
      ErrorType.network => Colors.grey,
      ErrorType.notFound404 => Colors.orange[600]!,
      ErrorType.serverError500 => Colors.red[600]!,
      ErrorType.otherHttp => Colors.amber[800]!,
    };
  }
}
