import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:openim_common/openim_common.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class H5Container extends StatefulWidget {
  const H5Container({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<H5Container> createState() => _H5ContainerState();
}

enum ErrorType {
  network,
  notFound404,
  serverError500,
  otherHttp,
}

class ErrorConfig {
  final ErrorType type;
  final IconData icon;
  final String title;
  final String subtitle;

  const ErrorConfig({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  static const network = ErrorConfig(
    type: ErrorType.network,
    icon: Icons.wifi_off,
    title: '网络连接失败',
    subtitle: '请检查网络设置后重试',
  );

  static const  notFound404 = ErrorConfig(
    type: ErrorType.notFound404,
    icon: Icons.link_off,
    title: '页面不存在 (404)',
    subtitle: '您访问的内容可能已被移除',
  );

  static const serverError500 = ErrorConfig(
    type: ErrorType.serverError500,
    icon: Icons.cloud_off,
    title: '服务器开小差了 (500)',
    subtitle: '工程师正在紧急修复中',
  );

  static ErrorConfig otherHttp(int? statusCode) => ErrorConfig(
    type: ErrorType.otherHttp,
    icon: Icons.warning,
    title: '请求失败 (${statusCode ?? '未知'})',
    subtitle: '请稍后重试或联系管理员',
  );
}



class _H5ContainerState extends State<H5Container> {
  late final WebViewController _controller;
  bool _isError = false;
  bool _hasPageFinished = false;
  double progress = 0;
  ErrorConfig? _errorConfig;
  @override
  void initState() {
    super.initState();
    Logger.print('H5Container: ${widget.url}');

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
            setState(() {
              this.progress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() {
              _hasPageFinished = false; // 页面开始加载时重置标志
              _isError = false;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url $_isError');
            if (!_isError) {
              setState(() => _hasPageFinished = true);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
               Page resource error:
               code: ${error.errorCode}
               description: ${error.description}
               errorType: ${error.errorType}
               isForMainFrame: ${error.isForMainFrame}
               ''');
            _handleError(null);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (HttpResponseError error) {
            debugPrint('Error occurred on page: ${error.response?.statusCode}');
            _handleError(error);
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {},
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(widget.url));

    if (!Platform.isMacOS) {
      controller.setBackgroundColor(Styles.c_F8F9FA);
    }

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);


      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }
  void _handleError(HttpResponseError? error) {
    final statusCode = error?.response?.statusCode;
    setState(() {
      if (!_isError) {
          _isError = true;
          _hasPageFinished = false;
      }
      _errorConfig = switch (statusCode) {
        404 => ErrorConfig.notFound404,
        500 => ErrorConfig.serverError500,
        _ when statusCode != null => ErrorConfig.otherHttp(statusCode),
        _ => ErrorConfig.network, // 无状态码时视为网络错误
      };
    });
  }

  Future<bool> _handleWebViewBack() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Logger.print('H5Container: ${widget.url},${_isError},${_hasPageFinished}');
    return Scaffold(
      appBar: widget.title != null ? TitleBar.back(title: widget.title) : null,
      body:  Stack(
            children: [
              Opacity(
                // 0关闭，1打开
                opacity: _hasPageFinished? 1 : 0,
                child: WebViewWidget(controller: _controller),
              ),
              if (_isError) _buildErrorView(),
              progress < 1.0
                  ? LinearProgressIndicator(
                value: progress,
                color: Colors.green,
                backgroundColor: Styles.c_F8F9FA,
              )
                  : const SizedBox(),
            ],
          ),

    );
  }

  // Widget _buildErrorView() {
  //   return Container(
  //     color: Colors.white,
  //     child: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
  //           const SizedBox(height: 20),
  //           const Text('网络连接失败', style: TextStyle(fontSize: 18)),
  //           const SizedBox(height: 10),
  //           const Text('请检查网络设置后重试', style: TextStyle(color: Colors.grey)),
  //           const SizedBox(height: 30),
  //           ElevatedButton.icon(
  //             icon: const Icon(Icons.refresh),
  //             label: const Text('重新加载'),
  //             onPressed: () {
  //               setState(() => _isError = false);
  //               _controller.reload();
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildErrorView() {
    final config = _errorConfig ?? ErrorConfig.network;
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              config.icon,
              size: 60,
              color: _getIconColor(config.type), // 根据类型微调颜色
            ),
            const SizedBox(height: 20),
            Text(config.title, style:  const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(config.subtitle,  style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            _buildRetryButton(),
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

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
        icon: const Icon(Icons.refresh, size: 20),
    label: const Text('重新加载', style: TextStyle(fontSize: 16)),
    onPressed: () {
    setState(() {
      _errorConfig = null;_isError = false;
    });
    _controller.reload();
    },
    );
  }
}
