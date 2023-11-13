import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hacker_news/bookmark_service.dart';
import 'package:hacker_news/webview.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class BookmarksScreen extends StatelessWidget {
  final BookmarkService bookmarkService = BookmarkService();

  @override
  Widget build(BuildContext context) {
    return Bookmarks(bookmarkService);
  }
}

class Bookmarks extends StatefulWidget {
  final BookmarkService bookmarkService;

  Bookmarks(BookmarkService bookmarkService)
      : this.bookmarkService = bookmarkService;

  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  List bookmarks = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    var data = await widget.bookmarkService.getBookmarks();
    setState(() {
      bookmarks = data.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      body: ListView.builder(
          itemCount: bookmarks.length,
          itemBuilder: (BuildContext context, int position) {
            return getRow(context, position);
          }),
    );
  }

  Widget getRow(BuildContext context, int position) {
    var post = bookmarks[position];
    String title = post["title"];
    String url = post["url"];
    var tapPosition;
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        tapPosition = details.globalPosition;
      },
      onLongPress: () {
        showMenu(
            context: context,
            position: RelativeRect.fromRect(
                tapPosition & Size(40, 40),
                Offset.zero &
                    (Overlay.of(context).context.findRenderObject()
                            as RenderBox)
                        .size),
            items: <PopupMenuEntry>[
              PopupMenuItem(
                value: "open",
                child: Row(
                  children: <Widget>[
                    Text("Open in browser"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "share",
                child: Row(
                  children: <Widget>[
                    Text("Share"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "remove",
                child: Row(
                  children: <Widget>[
                    Text("Remove"),
                  ],
                ),
              )
            ]).then<void>((value) {
          if (value == null) return;
          onPopupMenuSelect(value, post);
        });
      },
      child: ListTile(
        title: Text("$title",
            textDirection: TextDirection.ltr,
            style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold)),
        subtitle: Text(url),
        onTap: () => onTapped(post),
      ),
    );
  }

  onPopupMenuSelect(value, post) {
    logger.d("Open in browser: ${post["url"]}");
    if (value == "open") {
      _launchURL(post["url"]);
    } else if (value == "share") {
      Share.share(post["url"]);
    } else if (value == "remove") {
      _removeBookmark(post);
    }
  }

  _removeBookmark(post) async {
    var list = await widget.bookmarkService.getBookmarks();
    list.remove(post);
    await widget.bookmarkService.saveBookmarks(list);
    loadData();
  }

  _launchURL(url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  onTapped(post) {
    String url = post["url"];
    if (isPdfPost(url)) {
      _launchURL(url);
      return;
    }

    // If url is null, it is then Ask HN post.
    if (url == null) {
      url = "https://news.ycombinator.com/item?id=${post["id"]}";
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewScreen(post["title"], url)));
  }

  isPdfPost(url) {
    return url != null && url.endsWith(".pdf");
  }
}
