import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hacker_news/links.dart';
import 'package:hacker_news/main.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

const int KEY_UP = 19;
const int KEY_DOWN = 20;
const int KEY_LEFT = 21;
const int KEY_RIGHT = 22;
const int KEY_CENTER = 23;

class WebViewScreen extends StatelessWidget {
  final url;
  final title;

  WebViewScreen(this.title, this.url);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return WebViewContainer(title, url);
  }
}

class WebViewContainer extends StatefulWidget {
  final url;
  final title;

  WebViewContainer(this.title, this.url);

  @override
  createState() => _WebViewContainerState(this.title, this.url);
}

class _WebViewContainerState extends State<WebViewContainer> {
  var _url;
  final title;
  late WebViewController _controller;

  _WebViewContainerState(this.title, this._url);

  @override
  void initState() {
    super.initState();

    PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            logger.d("onWebResourceError: " + error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            /*if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }*/
            logger.d("onNavigationRequest: " + request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      var platform = (controller.platform as AndroidWebViewController);
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
    logger.d("Loading url: $_url");
  }

  @override
  Widget build(BuildContext context) {
    openLinks() async {
      var js =
          "var tags = document.getElementsByTagName('a'); var links=[]; for(i=0;i<tags.length;i++){ if(tags[i].href.startsWith('https:'))links.push({url:tags[i].href, title: tags[i].innerText.replaceAll('\"','')})}; JSON.stringify(links)";
      String response =
          await _controller.platform.runJavaScriptReturningResult(js) as String;
      response = response.substring(1, response.length-1).replaceAll("\\", '');
      logger.d("Links: " + response);
      var links = jsonDecode(response) as List<dynamic>;
      logger.d(links);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => Links(links: links)));
    }

    FocusNode focusNode = FocusNode();
    return Scaffold(
      body: new RawKeyboardListener(
          focusNode: focusNode,
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent &&
                event.data is RawKeyEventDataAndroid) {
              RawKeyDownEvent rawKeyDownEvent = event;
              RawKeyEventDataAndroid data =
                  rawKeyDownEvent.data as RawKeyEventDataAndroid;
              print("Focus Node 0: ${data.keyCode}");
              switch (data.keyCode) {
                case KEY_CENTER:
                  logger.d("KeyListener: KEY_CENTER");
                  openLinks();
                  break;
                case KEY_UP:
                  _controller.scrollBy(0, -100);
                  break;
                case KEY_DOWN:
                  _controller.scrollBy(0, 100);
                  break;
                case KEY_LEFT:
                  _controller.scrollBy(-100, 0);
                  break;
                case KEY_RIGHT:
                  _controller.scrollBy(100, 0);
                  break;
                default:
                  break;
              }
              setState(() {});
            }
          },
          child: WebViewWidget(controller: _controller)),
    );
  }
}
