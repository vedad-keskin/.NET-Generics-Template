import 'package:intl/intl.dart';

String formatNumber(dynamic number) {
  var f = NumberFormat("#,##0.00", "en_US");
  if (number == null) {
    return "";
  }
  return f.format(number);

}

