import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hacker_news/main.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookmarkService {
  late Box<List<dynamic>> bookmarkLinksBox;
  late List<dynamic> bookmarkUrls;
  var initialized = false;

  Future<void> init() async {
    await Hive.initFlutter();
    bookmarkLinksBox = await Hive.openBox('bookmarkLinks');
    initialized = true;
    updateBookmarkUrls();
  }

  Future<void> updateBookmarkUrls() async {
    var bookmarks = bookmarkLinksBox.get('bookmarkLinks') ?? [];
    bookmarkUrls = bookmarks.map((e) => e['url']).toList();
  }

  Future<bool> isBookmarked(String url) async {
    if (!initialized) await init();
    return bookmarkUrls.contains(url);
  }

  Future<void> bookmark(dynamic post) async {
    var list = await getBookmarks();
    var url = post['url'];
    logger.d('Bookmarking post with url: $url');
    // Check if the post is already bookmarked
    if (bookmarkUrls.contains(url)) {
      await Fluttertoast.showToast(
          msg: "Bookmark already exists!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.deepOrange,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    list.add(post);
    await saveBookmarks(list);
  }

  Future<void> saveBookmarks(List<dynamic> bookmarks) async {
    if (!initialized) await init();
    bookmarkLinksBox.put('bookmarkLinks', bookmarks);
    await updateBookmarkUrls();
    await Fluttertoast.showToast(
        msg: "Bookmark saved!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrange,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<List<dynamic>> getBookmarks() async {
    if (!initialized) await init();
    return bookmarkLinksBox.get('bookmarkLinks') ?? [];
  }
}
