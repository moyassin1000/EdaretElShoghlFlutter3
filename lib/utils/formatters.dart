import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _number = NumberFormat('#,##0.##', 'ar');
  static final DateFormat _date = DateFormat('yyyy-MM-dd', 'en');
  static final DateFormat _arabicMonth = DateFormat('MMMM yyyy', 'ar');

  static String money(num value) => '${_number.format(value)} ج.م';
  static String number(num value) => _number.format(value);
  static String date(DateTime value) => _date.format(value);
  static String month(DateTime value) => _arabicMonth.format(value);

  static DateTime? parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}
