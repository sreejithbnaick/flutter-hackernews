import 'package:flutter/material.dart';
import 'package:hacker_news/main.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;

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
  final _key = UniqueKey();
  final title;
  WebViewController _controller;

  _WebViewContainerState(this.title, this._url);

  @override
  void initState() {
    super.initState();
    logger.d("Loading url: $_url");
  }

  void _settleLeft(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      if (_controller != null) {
        _controller.canGoBack().then<void>((onValue) {
          if (onValue) _controller.goBack();
        });
      }
    }
  }

  void _settleRight(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx.abs() >= _kMinFlingVelocity) {
      if (_controller != null) {
        _controller.canGoForward().then<void>((onValue) {
          if (onValue) _controller.goForward();
        });
      }
    }
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _share(url) async{
    Share.share(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title), actions: <Widget>[
          // action button
          IconButton(
            icon: Icon(Icons.open_in_browser),
            onPressed: () {
              _launchURL(_url);
            },
          ),
          // action button
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _share(_url);
            },
          )
        ]),
        body: Column(
          children: [
            Expanded(
                child: Stack(
              children: <Widget>[
                WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: _url,
                    onWebViewCreated: (WebViewController webViewController) {
                      _controller = webViewController;
                    }),
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
