import 'package:flutter/material.dart';
import 'package:hacker_news/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'bookmark_service.dart';

const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;

class WebViewScreen extends StatelessWidget {
  final url;
  final title;
  final post;

  WebViewScreen(this.title, this.url, this.post);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return WebViewContainer(title, url, post);
  }
}

class WebViewContainer extends StatefulWidget {
  final url;
  final title;
  final post;

  WebViewContainer(this.title, this.url, this.post);

  @override
  createState() => _WebViewContainerState(this.title, this.url, this.post);
}

class _WebViewContainerState extends State<WebViewContainer> {
  final bookmarkService = BookmarkService();
  var _url;
  final title;
  final post;
  late WebViewController _controller;

  _WebViewContainerState(this.title, this._url, this.post);

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
    WebViewCookieManager().clearCookies();
    controller.clearCache();
    controller.clearLocalStorage();

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

  void _settleLeft(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      _controller.canGoBack().then<void>((onValue) {
        if (onValue) _controller.goBack();
      });
    }
  }

  void _settleRight(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      _controller.canGoForward().then<void>((onValue) {
        if (onValue) _controller.goForward();
      });
    }
  }

  _launchURL(url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  _share(url) async {
    Share.share(url);
  }

  _bookmark(post) async {
    var list = await bookmarkService.getBookmarks();
    list.add(post);
    await bookmarkService.saveBookmarks(list);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title), actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () async {
              var url = await _controller.currentUrl();
              _launchURL(url);
            },
          ),
          // action button
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              var url = await _controller.currentUrl();
              _share(url);
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () async {
              _bookmark(post);
            },
          )
        ]),
        body: Column(
          children: [
            Expanded(
                child: Stack(
              children: <Widget>[
                WebViewWidget(controller: _controller),
                new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onHorizontalDragEnd: _settleLeft,
                        child: Container(
                          width: _kEdgeDragWidth,
                          color: Colors.transparent,
                        ),
                      ),
                      GestureDetector(
                        onHorizontalDragEnd: _settleRight,
                        child: Container(
                          width: _kEdgeDragWidth,
                          color: Colors.transparent,
                        ),
                      )
                    ])
              ],
            ))
          ],
        ));
  }
}
