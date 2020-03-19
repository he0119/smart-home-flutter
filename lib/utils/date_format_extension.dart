import 'package:intl/intl.dart';

extension LocalDatetime on DateTime {
  /// 转换成本地时间
  String toLocalStr() {
    return DateFormat.yMMMd().add_jm().format(this.toLocal());
  }
}
