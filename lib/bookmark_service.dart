import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookmarkService {
  late Box<List<dynamic>> bookmarkLinksBox;
  var initialized = false;

  Future<void> init() async {
    await Hive.initFlutter();
    bookmarkLinksBox = await Hive.openBox('bookmarkLinks');
    initialized = true;
  }

  Future<void> saveBookmarks(List<dynamic> bookmarks) async {
    if (!initialized) await init();
    bookmarkLinksBox.put('bookmarkLinks', bookmarks);
    await Fluttertoast.showToast(
        msg: "Bookmark saved!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.deepOrange,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future<List<dynamic>> getBookmarks() async {
    if (!initialized) await init();
    return bookmarkLinksBox.get('bookmarkLinks') ?? [];
  }
}
