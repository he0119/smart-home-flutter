import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart';

Future<void> configureApp() async {
  // 设置初始的语言
  Intl.defaultLocale = await findSystemLocale();
}
