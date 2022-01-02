import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_browser.dart';

Future<void> configureApp() async {
  setUrlStrategy(PathUrlStrategy());
  Intl.defaultLocale = await findSystemLocale();
}
