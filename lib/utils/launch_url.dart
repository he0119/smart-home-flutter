import 'package:url_launcher/url_launcher.dart';

/// 打开网址
Future launchUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw Exception('Could not launch $url');
  }
}
