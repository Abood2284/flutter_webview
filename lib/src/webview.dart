/*
The WebView widget enables programmatic control with a WebViewController. 
This controller is made available after the construction of the WebView widget through a callback. 
The asynchronous nature of the availability of this controller makes it a prime candidate for Dart's asynchronous Completer<T> class.
 */
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewWidget extends StatefulWidget {
  final Completer<WebViewController> controller;
  // late Completer<WebViewController> controller;

  const WebViewWidget({Key? key, required this.controller}) : super(key: key);

  @override
  State<WebViewWidget> createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebViewWidget> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  final CookieManager cookieManager = CookieManager();

  final sessionCookie = const WebViewCookie(
    name: 'SthubWebView',
    value: '1',
    domain: 'develop.studentshub.in',
  );

  // Future<void> _onSetCookie() async {
  //   await cookieManager.setCookie(
  //     const WebViewCookie(
  //         name: 'sthubWebView', value: '1', domain: 'develop.studentshub.in'),
  //   );
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Custom cookie is set.'),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    int loadingPercentage = 0;
    return SafeArea(
      child: Stack(
        children: [
          WebView(
            initialCookies: [sessionCookie],
            initialUrl: 'https://develop.studentshub.in',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (webViewController) {
              widget.controller.complete(webViewController);
            },
            onPageStarted: (url) {
              setState(() {
                loadingPercentage = 0;
              });
            },
            onProgress: (progress) {
              setState(() {
                loadingPercentage = progress;
              });
            },
            onPageFinished: (url) {
              setState(() {
                loadingPercentage = 100;
              });
            },
            navigationDelegate: (navigation) {
              final host = Uri.parse(navigation.url).host;
              if (host.contains('youtube.com')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Blocking navigation to $host',
                    ),
                  ),
                );
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              value: loadingPercentage / 100.0,
              color: Colors.yellow,
              minHeight: 15,
            ),
        ],
      ),
    );
  }
}
