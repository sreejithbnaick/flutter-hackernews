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

bool isDarkMode(BuildContext context) {
  return MediaQuery.of(context).platformBrightness == Brightness.dark;
}

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
  var showSearchBox = false;

  var actualWebBgColor = "";
  var webBgChanged = false;

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
          onPageFinished: (String url) {
            // Get the background color of the web page
            controller
                .runJavaScriptReturningResult(
                    "document.body.style.backgroundColor")
                .then((value) => actualWebBgColor = value.toString());
          },
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
    SharePlus.instance.share(ShareParams(text: url));
  }

  _bookmark(post) async {
    String? url = post["url"];
    if (url == null) {
      url = "https://news.ycombinator.com/item?id=${post["id"]}";
    }
    String webUrl = await _controller.currentUrl() ?? "";
    var bookmarkPost;
    if (url != webUrl) {
      String title = await _controller.getTitle() ?? "";
      Map<String, dynamic> customPost = {
        "title": title,
        "url": webUrl,
      };
      bookmarkPost = customPost;
    } else {
      if (post["title"] == null || post["title"] == "") {
        String title = await _controller.getTitle() ?? "";
        post["title"] = title;
      }
      bookmarkPost = post;
    }
    await bookmarkService.bookmark(bookmarkPost);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title), actions: <Widget>[
          IconButton(
              tooltip: "Search in page",
              icon: Icon(Icons.search),
              onPressed: () async {
                if (showSearchBox) {
                  setState(() {
                    showSearchBox = false;
                  });
                } else {
                  setState(() {
                    showSearchBox = true;
                  });
                }
              }),
          // action button
          IconButton(
            tooltip: "Open in browser",
            icon: Icon(Icons.open_in_browser),
            onPressed: () async {
              var url = await _controller.currentUrl();
              _launchURL(url);
            },
          ),
          // action button
          IconButton(
            tooltip: "Share",
            icon: Icon(Icons.share),
            onPressed: () async {
              var url = await _controller.currentUrl();
              _share(url);
            },
          ),
          IconButton(
            tooltip: "Bookmark",
            icon: Icon(Icons.bookmark),
            onPressed: () async {
              _bookmark(post);
            },
          )
        ]),
        body: Container(
            child: Column(children: <Widget>[
          Visibility(
            visible: showSearchBox,
            child: Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: 24
              ),
              child: TextField(
                maxLines: 1,
                autofocus: true,
                showCursor: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search in page',
                ),
                onSubmitted: (String value) async {
                  if (value.trim() == "") {
                    return;
                  }
                  _controller.runJavaScript("self.find('${value.trim()}')");
                },
              ),
            ),
          ),
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
          )),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  onPressed: () {
                    _controller.canGoBack().then<void>((onValue) {
                      if (onValue) _controller.goBack();
                    });
                  },
                  icon: Icon(Icons.arrow_back),
                  label: Text('Back'),
                ),
                IconButton(
                    tooltip: 'Toggle Theme Mode',
                    onPressed: () {
                      if (webBgChanged) {
                        _controller.runJavaScript(
                            "document.body.style.backgroundColor = $actualWebBgColor;");
                        webBgChanged = false;
                      } else {
                        var color;
                        if (isDarkMode(context)) {
                          color = 'white';
                        } else {
                          color = 'black';
                        }
                        _controller.runJavaScript(
                            "document.body.style.backgroundColor = '$color';");
                        webBgChanged = true;
                      }
                    },
                    icon: Icon(Icons.light_mode)),
                // Forward button with icon on right end
                TextButton.icon(
                  onPressed: () {
                    _controller.canGoForward().then<void>((onValue) {
                      if (onValue) _controller.goForward();
                    });
                  },
                  label: Text('Forward'),
                  icon: Icon(Icons.arrow_forward),
                  iconAlignment: IconAlignment.end,
                ),
              ],
            ),
          )
        ])));
  }
}
