import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoScreen extends StatelessWidget {
  final String websiteUrl = 'https://sreejithbnaick.github.io/flutter-hackernews/';
  final String githubUrl = 'https://github.com/sreejithbnaick/flutter-hackernews';
  final String privacyPolicyUrl = 'https://sreejithbnaick.github.io/flutter-hackernews/privacy-policy.html';

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Website'),
            onTap: () => _launchURL(context, websiteUrl),
          ),
          ListTile(
            leading: Icon(Icons.code),
            title: Text('GitHub'),
            onTap: () => _launchURL(context, githubUrl),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            onTap: () => _launchURL(context, privacyPolicyUrl),
          ),
        ],
      ),
    );
  }
}

