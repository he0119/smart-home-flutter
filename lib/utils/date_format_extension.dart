import 'package:intl/intl.dart';

extension LocalDatetimeExtension on DateTime {
  /// 时间格式
  /// 时分秒（24小时制）
  DateFormat get localFormat {
    return DateFormat.yMMMd().add_Hms();
  }

  /// 转换成本地时间，包含时分秒（24小时制）
  String toLocalStr() {
    return localFormat.format(toLocal());
  }

  /// 获得本地习惯的时间差距表示
  String differenceStr(DateTime other) {
    final localNow = toLocal();
    final localOther = other.toLocal();
    // 同是一天，显示小时，或者分钟
    if (localNow.day == localOther.day &&
        localNow.month == localOther.month &&
        localNow.year == localOther.year) {
      final difference = localNow.difference(localOther);
      assert(difference.inDays == 0);
      if (difference.inHours == 0 && difference.inMinutes > 0) {
        return '${difference.inMinutes} 分钟前';
      }
      if (difference.inHours == 0 && difference.inMinutes < 0) {
        return '${difference.inMinutes.abs()} 分钟后';
      }
      if (difference.inHours == 0 && difference.inMinutes == 0) {
        return '1 分钟内';
      }
      if (difference.inHours > 0) {
        return '${difference.inHours} 小时前';
      }
      if (difference.inHours < 0) {
        return '${difference.inHours.abs()} 小时后';
      }
    }
    // 不在同一天
    final nowDay = DateTime(localNow.year, localNow.month, localNow.day);
    final otherDay =
        DateTime(localOther.year, localOther.month, localOther.day);
    final differenceDay = nowDay.difference(otherDay).inDays;
    assert(differenceDay != 0);
    if (differenceDay == 1) {
      return '昨天';
    }
    if (differenceDay == -1) {
      return '明天';
    }
    if (differenceDay > 0) {
      return '$differenceDay 天前';
    }
    if (differenceDay < 0) {
      return '${differenceDay.abs()} 天后';
    }
    return '';
  }

  /// 时间与现在的差距
  String differenceFromNowStr() {
    return DateTime.now().differenceStr(this);
  }
}
