import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hacker_news/bookmark_service.dart';
import 'package:hacker_news/qr_code_scanner.dart';
import 'package:hacker_news/webview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

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

  import() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result !=null) {
      try {
        final platformFile = result.files.single;
        final contents = await File(platformFile.path!).readAsString();
        var data = jsonDecode(contents);
        if (data is List<dynamic>) {
          importDataToBookmarks(data);
        }
      } catch (error) {
        print('Error importing file: $error');
      }
    }
  }

  Future<bool> showImportOptionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Import Options'),
          content: Text('Choose how you want to import the data'),
          actions: <Widget>[
            TextButton(
              child: Text('Replace'),
              onPressed: () {
                Navigator.of(context).pop(true); // Return true for replace
              },
            ),
            TextButton(
              child: Text('Append'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false for append
              },
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed without choosing an option
  }

  importDataToBookmarks(List<dynamic> data) async {
    try {
      bool replace = await showImportOptionDialog(context);
      // Call your data import function here, passing replace as a parameter
      if (replace) {
        await widget.bookmarkService.saveBookmarks(data);
        setState(() {
          bookmarks = data.reversed.toList();
        });
      } else {
        var list = await widget.bookmarkService.getBookmarks();
        list.addAll(data);
        await widget.bookmarkService.saveBookmarks(list);
        setState(() {
          bookmarks = list.reversed.toList();
        });
      }
    } catch (error) {
      print('Error importing file: $error');
    }
  }

  export() async {
    // convert bookmarks list to json array of key value objects
    var list = await widget.bookmarkService.getBookmarks();
    var data = jsonEncode(list);
    logger.d("Export: ${data}");
    exportFileAndShare(data);
  }

  Future<void> exportFileAndShare(String data) async {
    try {
    // Get the application documents directory (private)
    final directory = await getApplicationDocumentsDirectory();

    // Generate a unique filename with timestamp
    final filename = 'hnb_${DateTime.now().millisecondsSinceEpoch}.txt';
    final filePath = '${directory.path}/$filename';
    logger.d("Exporting file as ${filePath}");

    // Write data to the file

      final file = File(filePath);
      await file.writeAsString(data);

      // Share the created file
      await Share.shareXFiles([XFile(filePath)], text: 'Exported file');
    } catch (error) {
      // Handle errors gracefully, e.g., show a snackbar to the user
      print('Error creating and sharing file: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
        actions: [
          IconButton(
            tooltip: "Scan QR code",
            icon: Icon(Icons.qr_code, color: Colors.white),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => QRScannerScreen()))
                  .then((value) => loadData());
            }
          ),
          IconButton(
            tooltip: "Import bookmarks",
            icon: Icon(Icons.upload, color: Colors.white),
            onPressed: () {
              import();
            },
          ),
          IconButton(
            tooltip: "Export bookmarks",
            icon: Icon(Icons.download, color: Colors.white),
            onPressed: () {
              export();
            },
          )
        ],
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
    String? url = post["url"];
    if (url == null) {
      url = "https://news.ycombinator.com/item?id=${post["id"]}";
    }
    var tapPosition;
    var openMenuTxt = kIsWeb ? "Open" : "Open in browser";
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
                value: "qr",
                child: Row(
                  children: <Widget>[
                    Text("QR Code"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "open",
                child: Row(
                  children: <Widget>[
                    Text(openMenuTxt),
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
        subtitle: Text("$url"),
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
    } else if (value == "qr") {
      String? url = post["url"];
      if (url == null) {
        url = "https://news.ycombinator.com/item?id=${post["id"]}";
      }
      _generateQrCode(url);
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
    String? url = post["url"];
    if (isPdfPost(url)) {
      _launchURL(url);
      return;
    }

    // If url is null, it is then Ask HN post.
    if (url == null) {
      url = "https://news.ycombinator.com/item?id=${post["id"]}";
    }
    if (kIsWeb) {
      _launchURL(url);
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WebViewScreen(post["title"], url, post)))
    .then((value) => loadData());
  }

  isPdfPost(url) {
    return url != null && url.endsWith(".pdf");
  }

  void _generateQrCode(link) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(textAlign: TextAlign.center,"Scan to open link"),
            backgroundColor: Colors.white,
            content: Container(
              width: 300.0,
              height: 300.0,
              child: QrImageView(
                data: link,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ),
    );
  }
}
