import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hacker_news/main.dart';
import 'package:hacker_news/webview.dart';

class Links extends StatefulWidget {
  Links({Key? key, required this.links}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final List<dynamic> links;

  @override
  _LinkPageState createState() => _LinkPageState();
}

class _LinkPageState extends State<Links> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Links"),
        ),
        body: ListView.builder(
            itemCount: widget.links.length,
            itemBuilder: (BuildContext context, int position) {
              return getRow(context, position);
            }));
  }

  Widget getRow(BuildContext context, int i) {
    logger.d("getRow $i");
    var link = widget.links[i];
    logger.d("Data: $link");
    String title = link["title"];
    String url = link["url"];

    var tapPosition;
    return GestureDetector(
        onTapDown: (TapDownDetails details) {
          tapPosition = details.globalPosition;
        },
        child: ListTile(
          title: Text("$title ($url)",
              textDirection: TextDirection.ltr,
              maxLines: 2,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.bold)),
          onTap: () => onTapped(title, url),
        ));
  }

  onTapped(title, url) {
    // If url is null, it is then Ask HN post.
    if (url == null) return null;
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewScreen(title, url)));
  }
}
