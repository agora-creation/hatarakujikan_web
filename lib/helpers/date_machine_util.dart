import 'package:common_utils/common_utils.dart';

class DateMachineUtil {
  static Map<String, String> getMonthDate(DateTime dateTime, int i) {
    var current = dateTime;
    if (i + current.month > 0) {
      return timeConversion(i + current.month, (current.year).toString());
    } else {
      int beforeYear = (i + current.month) ~/ 12;
      String yearNew = (current.year + beforeYear - 1).toString();
      int monthNew = (i + current.month) - beforeYear * 12;
      return timeConversion(12 + monthNew, yearNew);
    }
  }

  static Map<String, String> timeConversion(int monthTime, String yearTime) {
    Map<String, String> dateMap = Map();
    dateMap['start'] = '$yearTime' +
        '-' +
        (monthTime < 10 ? '0' + monthTime.toString() : '$monthTime') +
        '-' +
        '01';
    dateMap['start'] = DateUtil.formatDate(
      DateTime.fromMillisecondsSinceEpoch(turnTimestamp(dateMap['start']!)),
      format: 'yyyy-MM-dd',
    );
    String endMonth = '$yearTime' +
        '-' +
        ((monthTime + 1) < 10
                ? '0' + (monthTime + 1).toString()
                : (monthTime + 1))
            .toString() +
        '-' +
        '00';
    var endMonthTimeStamp = turnTimestamp(endMonth);
    endMonth = DateUtil.formatDate(
      DateTime.fromMillisecondsSinceEpoch(endMonthTimeStamp),
      format: 'yyyy-MM-dd',
    );
    dateMap['end'] = endMonth;
    return dateMap;
  }

  static int turnTimestamp(String timestamp) {
    return DateTime.parse(timestamp).millisecondsSinceEpoch;
  }
}
