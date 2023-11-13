import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hacker_news/bookmark_service.dart';
import 'package:hacker_news/bookmarks.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'webview.dart';

void main() => runApp(MyApp());
var logger = Logger();

const String topStories =
    "https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty";
const String newStories =
    "https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty";
const String bestStories =
    "https://hacker-news.firebaseio.com/v0/beststories.json?print=pretty";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HackerNews',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'HackerNews'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BookmarkService bookmarkService = BookmarkService();
  String currentURL = topStories;
  List widgets = [];
  Map post = Map();
  Map loadingState = Map();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
          actions: [
            // Top stories
            IconButton(
              icon: Icon(Icons.vertical_align_top_sharp),
              onPressed: () async {
                currentURL = topStories;
                loadData();
              },
            ),
            // Best stories
            IconButton(
              icon: Icon(Icons.star),
              onPressed: () async {
                currentURL = bestStories;
                loadData();
              },
            ),
            // New stories
            IconButton(
              icon: Icon(Icons.new_releases),
              onPressed: () async {
                currentURL = newStories;
                loadData();
              },
            ),
            // Bookmarks
            IconButton(
              icon: Icon(Icons.bookmarks),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BookmarksScreen()));
              },
            ),
          ],
        ),
        body: ListView.builder(
            itemCount: widgets.length,
            itemBuilder: (BuildContext context, int position) {
              return getRow(context, position);
            }));
  }

  Widget getRow(BuildContext context, int i) {
    logger.d("getRow $i");
    var postId = widgets[i];
    var postData = post[postId];
    logger.d("Data: $postData");
    String title =
        postData == null ? "Loading" : "${i + 1}. ${postData["title"]}";
    int score = postData == null ? 0 : postData["score"];
    if (postData == null) {
      loadPost(postId);
    }
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
                  value: "bookmark",
                  child: Row(
                    children: <Widget>[
                      Text("Bookmark"),
                    ],
                  ),
                )
              ]).then<void>((value) {
            if (value == null) return;
            onPopupMenuSelect(value, postData);
          });
        },
        child: ListTile(
          title: Text("$title",
              textDirection: TextDirection.ltr,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold)),
          subtitle: Text("Points: $score"),
          onTap: () => onTapped(postData),
        ));
  }

  onPopupMenuSelect(value, post) {
    logger.d("Open in browser: ${post["url"]}");
    if (value == "open") {
      _launchURL(post["url"]);
    } else if (value == "share") {
      Share.share(post["url"]);
    } else if (value == "bookmark") {
      _bookmark(post);
    }
  }

  _bookmark(post) async {
    var list = await bookmarkService.getBookmarks();
    list.add(post);
    await bookmarkService.saveBookmarks(list);
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

  loadData() async {
    logger.d("Loading stories");
    http.Response response =
        await http.get(Uri.parse(currentURL)).catchError((error) {
      print(error);
      return null;
    });
    setState(() {
      widgets = json.decode(response.body).take(100).toList();
    });
  }

  loadPost(int item) async {
    if (loadingState[item] == true) {
      logger.d("Already loading post: $item, skipping...");
      return;
    }
    loadingState[item] = true;
    String dataURL =
        "https://hacker-news.firebaseio.com/v0/item/$item.json?print=pretty";
    logger.d("Loading post: $dataURL");
    http.Response response =
        await http.get(Uri.parse(dataURL)).catchError((error) {
      print(error);
      return null;
    });
    setState(() {
      post[item] = json.decode(response.body);
    });
    loadingState[item] = false;
    logger.d("Post loaded for $item: ${post[item]}");
  }
}
