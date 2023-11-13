import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  }

  Future<List<dynamic>> getBookmarks() async {
    if (!initialized) await init();
    return bookmarkLinksBox.get('bookmarkLinks') ?? [];
  }
}
