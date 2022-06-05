import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// 打开网址
Future<void> launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await url_launcher.canLaunchUrl(uri)) {
    await url_launcher.launchUrl(uri);
  } else {
    throw Exception('Could not launch $url');
  }
}
