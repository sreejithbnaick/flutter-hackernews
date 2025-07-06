# Simple HackerNews App Using Flutter

<img src="./images/screen1.jpg" width="180"> <img src="./images/screen2.jpg" width="180"> <img src="./images/screen3.jpg" width="180">

Try the Web app from here: https://flutterhackernews.web.app/

or 
Find playstore app: https://play.google.com/store/apps/details?id=in.codesmell.hacker_news

or
Try the APK from here: https://github.com/sreejithbnaick/flutter-hackernews/releases

Sor far this app can do:

1. List 100 top, best & new stories from HackerNews.
2. Open the Story url in a webview.
3. Long press on List Item
    + To open the story url in a Browser.
    + To share the story url.
    + To bookmark the story.
    + Share link as QR code.
    + Open HN page.
4. From Webview screen do the following:
    + Edge swipe from Left to Go Backwards or use "Back" button at bottom.
    + Edge swipe from right to Go Forwards or use "Forward" button at bottom.
    + Backpress will exit the Webview screen to top stories list.
    + Using menu in action bar: 
        + Open the current link a browser.
        + Share the current link.
        + Bookmark the story.
5. Bookmark stories locally to re-visit later.
6. Search & Filter articles.
7. QR code to open link on external devices.
8. Export & Import bookmarks.
9. Bookmark other webpage links too. Any weblink from webview can be bookmarked.


### TODO:

1. ~~PDF links does not work. Need to add support for PDF.~~ Now will open external PDF Viewer. 
2. ~~Ask HN discussion link does not open. Need to fix it.~~ Will go straight to the page.
3. ~~Bookmark stories locally, bookmark list screen.~~ Can bookmark stories now.
4. ~~Search & Filter articles.~~ Can search & filter articles now.
5. ~~Share links via QR code.~~ Can generate QR code now.
6. ~~Export & Import Bookmarks.~~ Can export and import bookmarks.
7. ~~Bookmark other webpages.~~ Can bookmark other web pages too.
8. ~~Open webpage from QR code~~. Can open webpage from Flutter HackerNews website or any QR code to web url.
9. Bookmark from QR code.
10. Dark Theme support.
11. Error State Handling: Refresh Page, Refresh Item, Retry, Offline support.
