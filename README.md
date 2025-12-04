# A simple, fast & clean article browser for Hacker News (Built using Flutter)

<img src="./images/screen1.jpg" width="180"> <img src="./images/screen2.jpg" width="180"> <img src="./images/screen3.jpg" width="180">

Find playstore app: https://play.google.com/store/apps/details?id=in.codesmell.hacker_news

or
Try the Web app from here: https://flutterhackernews.web.app/

or 
Try the APK from here: https://github.com/sreejithbnaick/flutter-hackernews/releases

<p>
    Simple Hacker News is your personal app for browsing the top, best & latest stories published in HackerNews. This app is for one purpose: to give you a clean, fast, and simple way to browse HackerNews articles. 

Unlike other HackerNews mobile apps, this app doesn't give much focus on writing or liking articles and comments. If you are looking for pure reading articles from HackerNews, trying to stay update on latest or best stories on HackerNews, this app will help you achieve. You can bookmark the articles you like it or read later, share it with your peers.

Core Features:
* Browse with Ease: Quickly access the Best, Top, and Latest 100 stories from HackerNews.
* Clean Reading Experience: A minimalist interface designed to put the content first. Read articles using the convenient in-app browser.
* Local Bookmarks: Save your favorite articles for later. All bookmarks are stored securely on your device and are deleted when you uninstall the app.
* Export & Import: You have full control of your data. Export your bookmarks to a text file for backup or transfer, and import them back anytime.

Your Privacy Comes First:
This app is built on a foundation of respect for your privacy. We believe you should be able to read the articles without being the product.

    ✅ Absolutely No Tracking: We do not use any analytics services. Your reading habits are your own business.
    ✅ Zero Advertisements: Enjoy a 100% ad-free experience. Forever.
    ✅ No User Accounts: No sign-up or login is required. We don't collect any of your personal information.
    ✅ Minimal Permissions: The app only asks for Internet access to fetch the stories. That's it.

Enjoy reading HackerNews articles in simple & clean way !!
</p>



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
9. ~~Bookmark from QR code~~. Supports reading QR code from bookmark listing screen.
10. ~~Dark Theme support.~~ Supports dark theme
11. Error State Handling: Refresh Page, Refresh Item, Retry, Offline support.
