import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:openim/core/controller/app_controller.dart';
import 'package:openim_common/openim_common.dart';

class DiscoverLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final url = ''.obs;

  final controller = Rx<InAppWebViewController?>(null);
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
      });
    } else {
      url.value = temp;
    }
  }

  void returnToInitialUrl() {
    if (url.isNotEmpty) {
      controller.value?.loadUrl(urlRequest: URLRequest(url: WebUri(url.value)));
    }
  }

  void reload() {
    errorConfig.value = null;
    isError.value = false;
    controller.value?.reload();
  }

  Future<bool> goBack() async {
    final currentUrl = await controller.value?.getUrl();
    print("current url $currentUrl   ${url.value}");
    if (currentUrl.toString() == url.value) {
      return false; // 已经在主页，不再进行返回
    }
    print("current url 111 $currentUrl   ${url.value}");
    if (await controller.value?.canGoBack() ?? false) {
      print("current url 222 $currentUrl   ${url.value}");
      controller.value?.goBack();
      return true;
    }
    return false;
  }
}
class DiscoverWebView extends GetView<DiscoverLogic> {
  String? _currentMainUrl;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final url = controller.url.value;
      if (url.isEmpty) return const Center(child: CircularProgressIndicator());

      return Stack(
        children: [
          AnimatedOpacity(
            opacity: controller.hasPageFinished.value ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child:
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri.uri(Uri.parse(url)),
                headers: {
                  'Accept-Encoding': 'gzip, deflate, br',
                  // 'User-Agent':
                  // 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                },
              ),

              initialSettings: InAppWebViewSettings(
                disableDefaultErrorPage: false,
                cacheEnabled: true,
                javaScriptEnabled: true,
                hardwareAcceleration: true,
                cacheMode: CacheMode.LOAD_DEFAULT,
                useHybridComposition:true,

                // transparentBackground: true,
              ),
              onReceivedError: (webCtrl, request, error) {
                final isMainFrame = request.url.toString() == _currentMainUrl;
                if (isMainFrame) {
                print('WebView Error: $error');
                controller.errorConfig.value = ErrorConfig.network;
                controller.isError.value = true;
                controller.hasPageFinished.value = false;
                }
              },
              onReceivedHttpError: (webCtrl, request, error) {
                final isMainFrame = request.url.toString() == _currentMainUrl;
                if (isMainFrame) {
                print('WebView HTTP Error: $error');
                controller.errorConfig.value = switch (error.statusCode) {
                  404 => ErrorConfig.notFound404,
                  500 => ErrorConfig.serverError500,
                  _ when error.statusCode != null => ErrorConfig.otherHttp(error.statusCode),
                  _ => ErrorConfig.network,
                };
                controller.isError.value = true;
                controller.hasPageFinished.value = false;
                }
              },
              onWebViewCreated: (webCtrl) {
                controller.controller.value = webCtrl;
                _enableWebViewDebugging(webCtrl);
              },
              onLoadStart: (webCtrl, url) {
                _currentMainUrl = url?.toString();
                controller.hasPageFinished.value = false;
                controller.isError.value = false;
              },
              // onLoadStop: (webCtrl, url) {
              //   print('Page finished loading: $url');
              //
              // },
              onPageCommitVisible:(webCtrl, url) {
                print('Page finished loading: $url');
                if (!controller.isError.value) {
                  controller.hasPageFinished.value = true;
                }
              },
              onProgressChanged: (webCtrl, progress) {
                print('Page loading progress: $progress');

                  controller.progress.value = progress / 100;
                 // if (progress > 50) {
                 //   if (!controller.isError.value) {
                 //     controller.hasPageFinished.value = true;
                 //   }
                 // }

              },
              shouldOverrideUrlLoading: (webCtrl, navigationAction) async {
                final url = navigationAction.request.url.toString();
                if (url.startsWith('https://www.youtube.com/')) {
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),

          ),
          if (controller.isError.value) _buildErrorView(),
          if (controller.progress.value < 1.0&&  controller.controller.value?.getUrl().toString() != controller.url.value)
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

  // 在 DiscoverWebView 类中添加此方法
  void _enableWebViewDebugging(InAppWebViewController webCtrl) async {
    if (Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled (true);
    }
    // iOS 自动支持 Safari 远程调试，无需额外代码
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