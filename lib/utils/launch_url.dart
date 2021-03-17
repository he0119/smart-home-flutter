import 'package:url_launcher/url_launcher.dart';

Future launchUrl(String? url) async {
  if (url != null && await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
